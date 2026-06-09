const express = require('express');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { z } = require('zod');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth } = require('../middleware/auth');
const { uploadLimiter } = require('../middleware/rateLimiters');
const AppError = require('../utils/AppError');
const router = express.Router();
fs.mkdirSync(path.join(process.cwd(), 'uploads/avatars'), { recursive: true });
const upload = multer({
  storage: multer.diskStorage({
    destination: 'uploads/avatars',
    filename: (req, file, cb) => cb(null, `${req.user.id}-${Date.now()}${path.extname(file.originalname).toLowerCase()}`),
  }),
  limits: { fileSize: Number(process.env.AVATAR_MAX_SIZE || 2 * 1024 * 1024) },
  fileFilter: (req, file, cb) => {
    if (!['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype)) return cb(new Error('Avatar harus berupa JPG, PNG, atau WEBP.'));
    cb(null, true);
  },
});

router.use(auth);
router.patch('/profile', asyncHandler(async (req, res) => {
  const body = z.object({ fullName: z.string().min(2).optional(), username: z.string().min(3).max(30).optional().nullable(), bio: z.string().max(240).optional().nullable(), phone: z.string().optional().nullable(), birthdate: z.string().datetime().optional().nullable() }).parse(req.body);
  const profile = await prisma.userProfile.upsert({ where: { userId: req.user.id }, create: { userId: req.user.id, fullName: body.fullName || 'Pengguna', username: body.username, bio: body.bio, phone: body.phone, birthdate: body.birthdate ? new Date(body.birthdate) : null }, update: { ...body, birthdate: body.birthdate ? new Date(body.birthdate) : body.birthdate } });
  res.json(profile);
}));
router.patch('/email', asyncHandler(async (req, res) => {
  const body = z.object({ email: z.string().email() }).parse(req.body);
  const email = body.email.toLowerCase().trim();
  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing && existing.id !== req.user.id) {
    throw new AppError('Email ini sudah dipakai akun lain.', 409, 'EMAIL_ALREADY_USED');
  }
  const user = await prisma.user.update({ where: { id: req.user.id }, data: { email, emailVerifiedAt: null } });
  res.json({ id: user.id, email: user.email });
}));
router.patch('/password', asyncHandler(async (req, res) => {
  const body = z.object({ currentPassword: z.string(), newPassword: z.string().min(8) }).parse(req.body);
  if (!(await bcrypt.compare(body.currentPassword, req.user.passwordHash))) throw new AppError('Password saat ini salah.', 401, 'CURRENT_PASSWORD_WRONG');
  await prisma.user.update({ where: { id: req.user.id }, data: { passwordHash: await bcrypt.hash(body.newPassword, 12) } });
  res.json({ success: true, message: 'Password berhasil diperbarui.' });
}));
router.post('/avatar', uploadLimiter, upload.single('avatar'), asyncHandler(async (req, res) => {
  if (!req.file) throw new AppError('File avatar wajib diunggah.', 400, 'AVATAR_REQUIRED');
  const avatarUrl = `${process.env.PUBLIC_BASE_URL || ''}/uploads/avatars/${req.file.filename}`;
  const profile = await prisma.userProfile.update({ where: { userId: req.user.id }, data: { avatarUrl } });
  res.json(profile);
}));
router.delete('/avatar', asyncHandler(async (req, res) => { const profile = await prisma.userProfile.update({ where: { userId: req.user.id }, data: { avatarUrl: null } }); res.json(profile); }));
router.get('/preferences', asyncHandler(async (req, res) => { const pref = await prisma.userPreference.upsert({ where: { userId: req.user.id }, create: { userId: req.user.id }, update: {} }); res.json(pref); }));
router.patch('/preferences', asyncHandler(async (req, res) => {
  const body = z.object({ themeMode: z.enum(['LIGHT','DARK','SYSTEM']).optional(), accentColor: z.string().optional(), language: z.string().optional(), notificationEnabled: z.boolean().optional(), recommendationRadiusKm: z.number().int().min(1).max(100).optional(), preferredCategories: z.array(z.string()).optional(), preferredMoods: z.array(z.string()).optional() }).parse(req.body);
  const pref = await prisma.userPreference.upsert({ where: { userId: req.user.id }, create: { userId: req.user.id, ...body }, update: body });
  res.json(pref);
}));
router.get('/favorites', asyncHandler(async (req, res) => {
  const rows = await prisma.userFavorite.findMany({
    where: { userId: req.user.id, destination: { is: { isActive: true } } },
    include: { destination: true },
    orderBy: { createdAt: 'desc' },
  });
  res.json(rows.map((row) => row.destination));
}));

router.post('/favorites/:destinationId', asyncHandler(async (req, res) => {
  const destination = await prisma.destination.findFirst({
    where: { id: req.params.destinationId, isActive: true },
    select: { id: true },
  });
  if (!destination) throw new AppError('Destinasi tidak ditemukan.', 404, 'DESTINATION_NOT_FOUND');

  await prisma.userFavorite.upsert({
    where: { userId_destinationId: { userId: req.user.id, destinationId: req.params.destinationId } },
    create: { userId: req.user.id, destinationId: req.params.destinationId },
    update: {},
  });
  res.status(201).json({ success: true, message: 'Destinasi berhasil ditambahkan ke favorit.' });
}));

router.delete('/favorites/:destinationId', asyncHandler(async (req, res) => {
  await prisma.userFavorite.deleteMany({
    where: { userId: req.user.id, destinationId: req.params.destinationId },
  });
  res.json({ success: true, message: 'Destinasi berhasil dihapus dari favorit.' });
}));
router.get('/visited-places', asyncHandler(async (req, res) => { const rows = await prisma.userVisitedPlace.findMany({ where: { userId: req.user.id }, include: { destination: true }, orderBy: { visitedAt: 'desc' } }); res.json(rows); }));
router.post('/visited-places/:destinationId', asyncHandler(async (req, res) => { const row = await prisma.userVisitedPlace.upsert({ where: { userId_destinationId: { userId: req.user.id, destinationId: req.params.destinationId } }, create: { userId: req.user.id, destinationId: req.params.destinationId, visitMethod: req.body.visitMethod || 'MANUAL_CHECKIN' }, update: { visitedAt: new Date(), visitMethod: req.body.visitMethod || 'MANUAL_CHECKIN' } }); res.status(201).json(row); }));
module.exports = router;
