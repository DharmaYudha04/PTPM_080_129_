const express = require('express');
const { z } = require('zod');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth } = require('../middleware/auth');
const { scoreAnswer } = require('../utils/scoring');

const router = express.Router();

function shuffle(arr) {
  return [...arr].sort(() => Math.random() - 0.5);
}

function safeQuestion(q) {
  return {
    id: q.id,
    questionText: q.questionText,
    category: q.category,
    difficulty: q.difficulty,
    options: shuffle(q.options).map((o) => ({
      id: o.id,
      optionText: o.optionText,
    })),
  };
}

function normalizeCsv(value) {
  if (!value) return undefined;
  if (Array.isArray(value)) return value.map(String).filter(Boolean);
  return String(value).split(',').map((v) => v.trim()).filter(Boolean);
}

router.post('/start', auth, asyncHandler(async (req, res) => {
  const body = z.object({
    totalQuestions: z.coerce.number().int().min(1).max(20).default(5),
    category: z.string().optional(),
    difficulty: z.string().optional(),
    avoidRecent: z.boolean().optional().default(true),
  }).parse(req.body || {});

  const where = { isActive: true };
  if (body.category) where.category = { equals: body.category, mode: 'insensitive' };
  if (body.difficulty) where.difficulty = { equals: body.difficulty, mode: 'insensitive' };

  let recentQuestionIds = [];
  if (body.avoidRecent) {
    const recentAttempts = await prisma.quizAttempt.findMany({
      where: { userId: req.user.id, finishedAt: { not: null } },
      include: { answers: { select: { questionId: true } } },
      orderBy: { startedAt: 'desc' },
      take: 5,
    });
    recentQuestionIds = [...new Set(recentAttempts.flatMap((a) => a.answers.map((x) => x.questionId)))];
  }

  let questions = await prisma.quizQuestion.findMany({
    where: recentQuestionIds.length > 0 ? { ...where, id: { notIn: recentQuestionIds } } : where,
    include: { options: true },
  });

  if (questions.length < body.totalQuestions) {
    questions = await prisma.quizQuestion.findMany({ where, include: { options: true } });
  }

  questions = shuffle(questions.filter((q) => q.options.length >= 2)).slice(0, body.totalQuestions);
  if (questions.length === 0) return res.status(409).json({ message: 'No active quiz questions available' });

  const attempt = await prisma.quizAttempt.create({
    data: {
      userId: req.user.id,
      totalQuestions: questions.length,
      questionSet: {
        createMany: {
          data: questions.map((q, index) => ({ questionId: q.id, orderIndex: index })),
        },
      },
    },
  });

  res.status(201).json({
    attemptId: attempt.id,
    timeLimitSeconds: questions.length * 15,
    perQuestionSeconds: 15,
    questions: questions.map(safeQuestion),
  });
}));

router.post('/submit', auth, asyncHandler(async (req, res) => {
  const body = z.object({
    attemptId: z.string().min(1),
    answers: z.array(z.object({
      questionId: z.string().min(1),
      selectedOptionId: z.string().min(1),
      timeTakenSeconds: z.coerce.number().int().min(0).max(3600).default(0),
    })).default([]),
  }).parse(req.body || {});

  const attempt = await prisma.quizAttempt.findFirst({
    where: { id: body.attemptId, userId: req.user.id },
    include: { questionSet: true },
  });
  if (!attempt) return res.status(404).json({ message: 'Attempt not found' });
  if (attempt.finishedAt) return res.status(409).json({ message: 'Attempt already submitted' });

  const allowedQuestionIds = new Set(attempt.questionSet.map((q) => q.questionId));
  const uniqueAnswers = new Map();
  for (const answer of body.answers) {
    if (allowedQuestionIds.has(answer.questionId) && !uniqueAnswers.has(answer.questionId)) {
      uniqueAnswers.set(answer.questionId, answer);
    }
  }

  let correct = 0;
  let totalScore = 0;
  const details = [];

  for (const questionId of allowedQuestionIds) {
    const submitted = uniqueAnswers.get(questionId);
    const question = await prisma.quizQuestion.findUnique({
      where: { id: questionId },
      include: { options: true },
    });
    const selectedOption = submitted
      ? question.options.find((option) => option.id === submitted.selectedOptionId)
      : null;
    const isCorrect = Boolean(selectedOption?.isCorrect);
    const timeTakenSeconds = submitted ? Number(submitted.timeTakenSeconds || 0) : 15;
    const score = scoreAnswer(isCorrect, timeTakenSeconds);

    if (isCorrect) correct += 1;
    totalScore += score;

    const row = await prisma.quizAttemptAnswer.upsert({
      where: { attemptId_questionId: { attemptId: body.attemptId, questionId } },
      create: {
        attemptId: body.attemptId,
        questionId,
        selectedOptionId: selectedOption?.id || null,
        isCorrect,
        timeTakenSeconds,
        score,
      },
      update: {
        selectedOptionId: selectedOption?.id || null,
        isCorrect,
        timeTakenSeconds,
        score,
      },
    });

    details.push({
      questionId: row.questionId,
      selectedOptionId: row.selectedOptionId,
      correctOptionId: question.options.find((option) => option.isCorrect)?.id || null,
      isCorrect,
      score,
      explanation: question.explanation,
    });
  }

  const finished = await prisma.quizAttempt.update({
    where: { id: body.attemptId },
    data: { finishedAt: new Date(), correctAnswers: correct, totalScore },
    include: { answers: true },
  });

  res.json({ attempt: finished, details });
}));

router.get('/history', auth, asyncHandler(async (req, res) => {
  const rows = await prisma.quizAttempt.findMany({
    where: { userId: req.user.id },
    include: { answers: true },
    orderBy: { startedAt: 'desc' },
    take: 50,
  });
  res.json(rows);
}));

router.get('/attempts/:attemptId/review', auth, asyncHandler(async (req, res) => {
  const attempt = await prisma.quizAttempt.findFirst({
    where: { id: req.params.attemptId, userId: req.user.id },
    include: {
      questionSet: { include: { question: { include: { options: true } } }, orderBy: { orderIndex: 'asc' } },
      answers: true,
    },
  });
  if (!attempt) return res.status(404).json({ message: 'Attempt not found' });

  const answersByQuestionId = new Map(attempt.answers.map((a) => [a.questionId, a]));
  res.json({
    id: attempt.id,
    startedAt: attempt.startedAt,
    finishedAt: attempt.finishedAt,
    totalQuestions: attempt.totalQuestions,
    correctAnswers: attempt.correctAnswers,
    totalScore: attempt.totalScore,
    questions: attempt.questionSet.map((item) => {
      const answer = answersByQuestionId.get(item.questionId);
      return {
        id: item.question.id,
        questionText: item.question.questionText,
        category: item.question.category,
        difficulty: item.question.difficulty,
        explanation: item.question.explanation,
        selectedOptionId: answer?.selectedOptionId || null,
        isCorrect: answer?.isCorrect || false,
        score: answer?.score || 0,
        options: item.question.options.map((option) => ({
          id: option.id,
          optionText: option.optionText,
          isCorrect: option.isCorrect,
        })),
      };
    }),
  });
}));

router.get('/stats', auth, asyncHandler(async (req, res) => {
  const attempts = await prisma.quizAttempt.findMany({
    where: { userId: req.user.id, finishedAt: { not: null } },
    include: { answers: { include: { question: true } } },
    orderBy: { startedAt: 'desc' },
  });

  const categoryMap = new Map();
  for (const attempt of attempts) {
    for (const answer of attempt.answers) {
      const category = answer.question.category;
      const current = categoryMap.get(category) || { category, answered: 0, correct: 0, score: 0 };
      current.answered += 1;
      current.correct += answer.isCorrect ? 1 : 0;
      current.score += answer.score;
      categoryMap.set(category, current);
    }
  }

  const bestScore = attempts.reduce((max, attempt) => Math.max(max, attempt.totalScore), 0);
  const totalScore = attempts.reduce((sum, attempt) => sum + attempt.totalScore, 0);
  const totalCorrect = attempts.reduce((sum, attempt) => sum + attempt.correctAnswers, 0);
  const totalQuestions = attempts.reduce((sum, attempt) => sum + attempt.totalQuestions, 0);

  res.json({
    attempts: attempts.length,
    bestScore,
    totalScore,
    averageScore: attempts.length ? Math.round(totalScore / attempts.length) : 0,
    totalCorrect,
    totalQuestions,
    accuracy: totalQuestions ? Number(((totalCorrect / totalQuestions) * 100).toFixed(1)) : 0,
    categories: [...categoryMap.values()].map((item) => ({
      ...item,
      accuracy: item.answered ? Number(((item.correct / item.answered) * 100).toFixed(1)) : 0,
    })),
  });
}));

router.get('/leaderboard', auth, asyncHandler(async (req, res) => {
  const limit = Math.min(Number(req.query.limit || 20), 100);
  const categories = normalizeCsv(req.query.category);
  const where = { finishedAt: { not: null } };
  if (categories?.length) {
    where.answers = { some: { question: { category: { in: categories } } } };
  }

  const rows = await prisma.quizAttempt.findMany({
    where,
    include: { user: { select: { id: true, profile: true } } },
    orderBy: [{ totalScore: 'desc' }, { finishedAt: 'asc' }],
    take: limit,
  });

  res.json(rows.map((row, index) => ({
    rank: index + 1,
    attemptId: row.id,
    userId: row.userId,
    name: row.user.profile?.fullName || 'User',
    avatarUrl: row.user.profile?.avatarUrl || null,
    totalScore: row.totalScore,
    correctAnswers: row.correctAnswers,
    totalQuestions: row.totalQuestions,
    finishedAt: row.finishedAt,
  })));
}));

module.exports = router;
