const express = require('express');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');

const router = express.Router();

router.get('/', asyncHandler(async (req, res) => {
  res.json({
    status: 'ok',
    service: 'jogjasplorasi-backend',
    mode: process.env.NODE_ENV || 'development',
    apiBase: '/api',
    timestamp: new Date().toISOString(),
  });
}));

router.get('/ready', asyncHandler(async (req, res) => {
  const checks = {
    database: false,
    destinations: 0,
    quizQuestions: 0,
  };

  try {
    await prisma.$queryRaw`SELECT 1`;
    checks.database = true;
    checks.destinations = await prisma.destination.count();
    checks.quizQuestions = await prisma.quizQuestion.count();
  } catch (error) {
    return res.status(503).json({
      status: 'not_ready',
      checks,
      error: error.message,
      hint: 'Run: docker compose up -d postgres, then npm run setup from backend folder.',
    });
  }

  res.json({
    status: 'ready',
    checks,
    timestamp: new Date().toISOString(),
  });
}));

module.exports = router;
