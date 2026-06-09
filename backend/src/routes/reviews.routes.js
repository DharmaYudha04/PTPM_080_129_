const express = require('express');
const { z } = require('zod');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth } = require('../middleware/auth');
const router = express.Router();

router.get('/destinations/:destinationId', asyncHandler(async (req, res) => {
  const rows = await prisma.destinationReview.findMany({
    where: { destinationId: req.params.destinationId },
    include: { user: { select: { id: true, profile: true } } },
    orderBy: { createdAt: 'desc' },
  });
  const avg = rows.length ? rows.reduce((sum, row) => sum + row.rating, 0) / rows.length : 0;
  res.json({ averageRating: Number(avg.toFixed(2)), totalReviews: rows.length, reviews: rows });
}));

router.post('/destinations/:destinationId', auth, asyncHandler(async (req, res) => {
  const body = z.object({
    rating: z.number().int().min(1).max(5),
    comment: z.string().max(1000).optional().nullable(),
    visitDate: z.string().datetime().optional().nullable(),
  }).parse(req.body);

  const destination = await prisma.destination.findUnique({ where: { id: req.params.destinationId } });
  if (!destination) return res.status(404).json({ message: 'Destination not found' });

  const review = await prisma.destinationReview.upsert({
    where: { userId_destinationId: { userId: req.user.id, destinationId: req.params.destinationId } },
    create: {
      userId: req.user.id,
      destinationId: req.params.destinationId,
      rating: body.rating,
      comment: body.comment,
      visitDate: body.visitDate ? new Date(body.visitDate) : null,
    },
    update: {
      rating: body.rating,
      comment: body.comment,
      visitDate: body.visitDate ? new Date(body.visitDate) : null,
    },
  });

  const aggregate = await prisma.destinationReview.aggregate({
    where: { destinationId: req.params.destinationId },
    _avg: { rating: true },
  });
  if (aggregate._avg.rating) {
    await prisma.destination.update({
      where: { id: req.params.destinationId },
      data: { rating: Number(aggregate._avg.rating.toFixed(2)) },
    });
  }

  res.status(201).json(review);
}));

router.delete('/:id', auth, asyncHandler(async (req, res) => {
  const review = await prisma.destinationReview.findUnique({ where: { id: req.params.id } });
  if (!review) return res.status(404).json({ message: 'Review not found' });
  if (review.userId !== req.user.id && req.user.role !== 'ADMIN') return res.status(403).json({ message: 'Forbidden' });
  await prisma.destinationReview.delete({ where: { id: req.params.id } });
  res.json({ message: 'Review deleted' });
}));

module.exports = router;
