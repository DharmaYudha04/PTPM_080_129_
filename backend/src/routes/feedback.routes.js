const express = require('express');
const { z } = require('zod');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth, requireAdmin } = require('../middleware/auth');
const router = express.Router();

const feedbackSchema = z.object({
  category: z.enum(['GENERAL', 'BUG', 'FEATURE', 'DESTINATION', 'QUIZ']).default('GENERAL'),
  rating: z.number().int().min(1).max(5).optional(),
  message: z.string().trim().min(3, 'Pesan minimal 3 karakter.'),
});

router.post('/', auth, asyncHandler(async (req, res) => {
  const body = feedbackSchema.parse(req.body);
  const row = await prisma.feedback.create({ data: { ...body, userId: req.user.id } });
  res.status(201).json({ success: true, message: 'Masukan berhasil dikirim.', feedback: row });
}));

router.get('/', auth, requireAdmin, asyncHandler(async (req, res) => {
  const rows = await prisma.feedback.findMany({
    include: { user: { select: { email: true, profile: true } } },
    orderBy: { createdAt: 'desc' },
  });
  res.json(rows);
}));

module.exports = router;
