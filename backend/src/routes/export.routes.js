const express = require('express');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth: requireAuth, requireAdmin } = require('../middleware/auth');
const { writeAuditLog } = require('../middleware/audit');

const router = express.Router();

router.get('/me', requireAuth, asyncHandler(async (req, res) => {
  const [user, favorites, visitedPlaces, quizAttempts, reviews, feedback, itineraries] = await Promise.all([
    prisma.user.findUnique({ where: { id: req.user.id }, include: { profile: true, preferences: true } }),
    prisma.userFavorite.findMany({ where: { userId: req.user.id }, include: { destination: true } }),
    prisma.userVisitedPlace.findMany({ where: { userId: req.user.id }, include: { destination: true } }),
    prisma.quizAttempt.findMany({ where: { userId: req.user.id }, include: { answers: true, questionSet: true } }),
    prisma.destinationReview.findMany({ where: { userId: req.user.id }, include: { destination: true } }),
    prisma.feedback.findMany({ where: { userId: req.user.id } }),
    prisma.itinerary.findMany({ where: { userId: req.user.id }, include: { stops: true } }),
  ]);

  const payload = { exportedAt: new Date().toISOString(), user, favorites, visitedPlaces, quizAttempts, reviews, feedback, itineraries };
  await writeAuditLog({ actorId: req.user.id, action: 'EXPORT_SELF_DATA', entity: 'User', entityId: req.user.id, metadata: { sections: Object.keys(payload) }, ipAddress: req.ip, userAgent: req.get('user-agent') });
  res.setHeader('Content-Disposition', 'attachment; filename="jogjasplorasi-my-data.json"');
  res.json(payload);
}));

router.get('/admin/destinations', requireAuth, requireAdmin, asyncHandler(async (req, res) => {
  const destinations = await prisma.destination.findMany({ orderBy: { name: 'asc' } });
  await writeAuditLog({ actorId: req.user.id, action: 'EXPORT_DESTINATIONS', entity: 'Destination', metadata: { count: destinations.length }, ipAddress: req.ip, userAgent: req.get('user-agent') });
  res.setHeader('Content-Disposition', 'attachment; filename="jogjasplorasi-destinations-export.json"');
  res.json({ exportedAt: new Date().toISOString(), destinations });
}));

router.get('/admin/quiz', requireAuth, requireAdmin, asyncHandler(async (req, res) => {
  const questions = await prisma.quizQuestion.findMany({ include: { options: true }, orderBy: { createdAt: 'desc' } });
  await writeAuditLog({ actorId: req.user.id, action: 'EXPORT_QUIZ', entity: 'QuizQuestion', metadata: { count: questions.length }, ipAddress: req.ip, userAgent: req.get('user-agent') });
  res.setHeader('Content-Disposition', 'attachment; filename="jogjasplorasi-quiz-export.json"');
  res.json({ exportedAt: new Date().toISOString(), questions });
}));

module.exports = router;
