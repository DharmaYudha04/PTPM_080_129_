const express = require('express');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth } = require('../middleware/auth');

const router = express.Router();
router.use(auth);

router.get('/me/summary', asyncHandler(async (req, res) => {
  const [favorites, visitedPlaces, quizAttempts, recommendationClicks] = await Promise.all([
    prisma.userFavorite.count({ where: { userId: req.user.id } }),
    prisma.userVisitedPlace.count({ where: { userId: req.user.id } }),
    prisma.quizAttempt.findMany({ where: { userId: req.user.id, finishedAt: { not: null } } }),
    prisma.recommendationLog.count({ where: { userId: req.user.id, clickedAt: { not: null } } }),
  ]);

  const bestQuizScore = quizAttempts.reduce((max, item) => Math.max(max, item.totalScore), 0);
  const totalQuizScore = quizAttempts.reduce((sum, item) => sum + item.totalScore, 0);

  res.json({
    favorites,
    visitedPlaces,
    quizAttempts: quizAttempts.length,
    bestQuizScore,
    averageQuizScore: quizAttempts.length ? Math.round(totalQuizScore / quizAttempts.length) : 0,
    recommendationClicks,
  });
}));

module.exports = router;
