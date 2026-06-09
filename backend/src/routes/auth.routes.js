const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { z } = require('zod');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth } = require('../middleware/auth');
const { authLimiter } = require('../middleware/rateLimiters');
const AppError = require('../utils/AppError');
const router = express.Router();

const registerSchema = z.object({
  fullName: z.string({ required_error: 'Nama wajib diisi.' }).trim().min(2, 'Nama minimal 2 karakter.').max(80, 'Nama maksimal 80 karakter.'),
  email: z.string({ required_error: 'Email wajib diisi.' }).trim().email('Format email tidak valid.'),
  password: z.string({ required_error: 'Password wajib diisi.' }).min(8, 'Password minimal 8 karakter.').max(128, 'Password maksimal 128 karakter.'),
});
const loginSchema = z.object({
  email: z.string({ required_error: 'Email wajib diisi.' }).trim().email('Format email tidak valid.'),
  password: z.string({ required_error: 'Password wajib diisi.' }).min(1, 'Password wajib diisi.').max(128, 'Password maksimal 128 karakter.'),
});

function sign(user) {
  if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
    throw new AppError('Konfigurasi JWT_SECRET belum aman. Isi minimal 32 karakter di .env.', 500, 'JWT_SECRET_INVALID');
  }
  return jwt.sign({ sub: user.id, role: user.role }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
}

function publicUser(user) {
  return {
    id: user.id,
    email: user.email,
    role: user.role,
    isActive: user.isActive,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
    profile: user.profile,
    preferences: user.preferences,
    quizBestScore: user.quizAttempts?.[0]?.totalScore || 0,
    visitedCount: user.visitedPlaces?.length || 0,
  };
}

const userInclude = {
  profile: true,
  preferences: true,
  visitedPlaces: { select: { destinationId: true } },
  quizAttempts: { orderBy: { totalScore: 'desc' }, take: 1, select: { totalScore: true } },
};

router.post('/register', authLimiter, asyncHandler(async (req, res) => {
  const body = registerSchema.parse(req.body);
  const email = body.email.toLowerCase();
  const exists = await prisma.user.findUnique({ where: { email } });
  if (exists) throw new AppError('Email sudah terdaftar. Silakan masuk atau gunakan email lain.', 409, 'EMAIL_ALREADY_REGISTERED');

  const passwordHash = await bcrypt.hash(body.password, 12);
  const user = await prisma.user.create({
    data: {
      email,
      passwordHash,
      profile: { create: { fullName: body.fullName } },
      preferences: { create: { language: 'id' } },
    },
    include: userInclude,
  });

  res.status(201).json({
    success: true,
    message: 'Registrasi berhasil.',
    token: sign(user),
    user: publicUser(user),
  });
}));

router.post('/login', authLimiter, asyncHandler(async (req, res) => {
  const body = loginSchema.parse(req.body);
  const user = await prisma.user.findUnique({ where: { email: body.email.toLowerCase() }, include: userInclude });
  if (!user || !user.isActive || !(await bcrypt.compare(body.password, user.passwordHash))) {
    throw new AppError('Email atau password salah.', 401, 'INVALID_CREDENTIALS');
  }

  res.json({
    success: true,
    message: 'Login berhasil.',
    token: sign(user),
    user: publicUser(user),
  });
}));

router.get('/me', auth, asyncHandler(async (req, res) => {
  const user = await prisma.user.findUnique({ where: { id: req.user.id }, include: userInclude });
  if (!user || !user.isActive) throw new AppError('Sesi tidak valid. Silakan masuk kembali.', 401, 'SESSION_INVALID');
  res.json({ success: true, user: publicUser(user) });
}));

router.post('/logout', auth, (req, res) => {
  res.json({ success: true, message: 'Logout berhasil. Hapus token di aplikasi.' });
});

module.exports = router;
