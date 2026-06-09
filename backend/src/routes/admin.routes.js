const express = require('express');
const { z } = require('zod');
const slugify = require('slugify');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth, requireAdmin } = require('../middleware/auth');

const router = express.Router();
router.use(auth, requireAdmin);

const destinationSchema = z.object({
  name: z.string().min(2),
  slug: z.string().min(2).optional(),
  type: z.enum(['TOURISM', 'CULINARY', 'CULTURE']),
  category: z.string().min(2),
  description: z.string().min(10),
  story: z.string().optional().nullable(),
  localInsight: z.string().optional().nullable(),
  address: z.string().min(3),
  latitude: z.coerce.number(),
  longitude: z.coerce.number(),
  imageUrl: z.string().url().optional().nullable().or(z.literal('')),
  rating: z.coerce.number().min(0).max(5).optional(),
  ticketPrice: z.string().optional().nullable(),
  openingHours: z.string().optional().nullable(),
  bestTimeToVisit: z.string().optional().nullable(),
  recommendedDuration: z.string().optional().nullable(),
  culturalValue: z.coerce.number().int().min(0).max(5).optional(),
  isFeatured: z.boolean().optional(),
  isVerified: z.boolean().optional(),
  isActive: z.boolean().optional(),
  tags: z.array(z.string()).optional(),
});

const quizQuestionSchema = z.object({
  questionText: z.string().min(5),
  category: z.string().min(2),
  difficulty: z.string().default('normal'),
  explanation: z.string().optional().nullable(),
  isActive: z.boolean().optional(),
  options: z.array(z.object({
    optionText: z.string().min(1),
    isCorrect: z.boolean().default(false),
  })).min(2).refine((options) => options.filter((o) => o.isCorrect).length === 1, {
    message: 'Exactly one option must be correct',
  }),
});

function makeSlug(name, slug) {
  return slugify(slug || name, { lower: true, strict: true });
}

router.get('/summary', asyncHandler(async (req, res) => {
  const [users, destinations, activeDestinations, quizQuestions, feedback] = await Promise.all([
    prisma.user.count(),
    prisma.destination.count(),
    prisma.destination.count({ where: { isActive: true } }),
    prisma.quizQuestion.count(),
    prisma.feedback.count(),
  ]);
  res.json({ users, destinations, activeDestinations, quizQuestions, feedback });
}));

router.get('/destinations', asyncHandler(async (req, res) => {
  const { search, type, active } = req.query;
  const where = {};
  if (type) where.type = String(type).toUpperCase();
  if (active === 'true') where.isActive = true;
  if (active === 'false') where.isActive = false;
  if (search) {
    where.OR = [
      { name: { contains: String(search), mode: 'insensitive' } },
      { category: { contains: String(search), mode: 'insensitive' } },
      { description: { contains: String(search), mode: 'insensitive' } },
    ];
  }
  const rows = await prisma.destination.findMany({ where, orderBy: [{ updatedAt: 'desc' }, { name: 'asc' }], take: 200 });
  res.json(rows);
}));

router.post('/destinations', asyncHandler(async (req, res) => {
  const body = destinationSchema.parse(req.body);
  const slug = makeSlug(body.name, body.slug);
  const row = await prisma.destination.create({
    data: {
      ...body,
      slug,
      imageUrl: body.imageUrl || null,
      rating: body.rating ?? 4,
      culturalValue: body.culturalValue ?? 0,
      isFeatured: body.isFeatured ?? false,
      isVerified: body.isVerified ?? true,
      isActive: body.isActive ?? true,
      tags: body.tags ?? [],
    },
  });
  res.status(201).json(row);
}));

router.patch('/destinations/:id', asyncHandler(async (req, res) => {
  const partial = destinationSchema.partial().parse(req.body);
  const data = { ...partial };
  if (partial.name || partial.slug) data.slug = makeSlug(partial.name || partial.slug, partial.slug);
  if (data.imageUrl === '') data.imageUrl = null;
  const row = await prisma.destination.update({ where: { id: req.params.id }, data });
  res.json(row);
}));

router.delete('/destinations/:id', asyncHandler(async (req, res) => {
  const row = await prisma.destination.update({ where: { id: req.params.id }, data: { isActive: false } });
  res.json({ message: 'Destination disabled', destination: row });
}));

router.get('/quiz/questions', asyncHandler(async (req, res) => {
  const rows = await prisma.quizQuestion.findMany({ include: { options: true }, orderBy: { createdAt: 'desc' }, take: 200 });
  res.json(rows);
}));

router.post('/quiz/questions', asyncHandler(async (req, res) => {
  const body = quizQuestionSchema.parse(req.body);
  const row = await prisma.quizQuestion.create({
    data: {
      questionText: body.questionText,
      category: body.category,
      difficulty: body.difficulty,
      explanation: body.explanation,
      isActive: body.isActive ?? true,
      options: { create: body.options },
    },
    include: { options: true },
  });
  res.status(201).json(row);
}));

router.patch('/quiz/questions/:id', asyncHandler(async (req, res) => {
  const body = quizQuestionSchema.partial().parse(req.body);
  const { options, ...questionData } = body;
  const row = await prisma.$transaction(async (tx) => {
    if (options) {
      await tx.quizOption.deleteMany({ where: { questionId: req.params.id } });
    }
    return tx.quizQuestion.update({
      where: { id: req.params.id },
      data: {
        ...questionData,
        ...(options ? { options: { create: options } } : {}),
      },
      include: { options: true },
    });
  });
  res.json(row);
}));

router.delete('/quiz/questions/:id', asyncHandler(async (req, res) => {
  const row = await prisma.quizQuestion.update({ where: { id: req.params.id }, data: { isActive: false } });
  res.json({ message: 'Question disabled', question: row });
}));

router.get('/feedback', asyncHandler(async (req, res) => {
  const rows = await prisma.feedback.findMany({
    include: { user: { select: { email: true, profile: true } } },
    orderBy: { createdAt: 'desc' },
    take: 100,
  });
  res.json(rows);
}));

module.exports = router;
