const express = require('express');
const { z } = require('zod');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth } = require('../middleware/auth');
const router = express.Router();

router.use(auth);

const includeStops = {
  stops: {
    include: { destination: true },
    orderBy: [{ dayIndex: 'asc' }, { orderIndex: 'asc' }, { createdAt: 'asc' }],
  },
};

router.get('/', asyncHandler(async (req, res) => {
  const rows = await prisma.itinerary.findMany({
    where: { userId: req.user.id, isActive: true },
    include: includeStops,
    orderBy: { updatedAt: 'desc' },
  });
  res.json(rows);
}));

router.post('/', asyncHandler(async (req, res) => {
  const body = z.object({
    title: z.string().min(2).max(80),
    description: z.string().max(500).optional().nullable(),
    startDate: z.string().datetime().optional().nullable(),
    endDate: z.string().datetime().optional().nullable(),
  }).parse(req.body);
  const row = await prisma.itinerary.create({
    data: {
      userId: req.user.id,
      title: body.title,
      description: body.description,
      startDate: body.startDate ? new Date(body.startDate) : null,
      endDate: body.endDate ? new Date(body.endDate) : null,
    },
    include: includeStops,
  });
  res.status(201).json(row);
}));

router.get('/:id', asyncHandler(async (req, res) => {
  const row = await prisma.itinerary.findFirst({ where: { id: req.params.id, userId: req.user.id }, include: includeStops });
  if (!row) return res.status(404).json({ message: 'Itinerary not found' });
  res.json(row);
}));

router.patch('/:id', asyncHandler(async (req, res) => {
  const body = z.object({
    title: z.string().min(2).max(80).optional(),
    description: z.string().max(500).optional().nullable(),
    startDate: z.string().datetime().optional().nullable(),
    endDate: z.string().datetime().optional().nullable(),
    isActive: z.boolean().optional(),
  }).parse(req.body);
  const owned = await prisma.itinerary.findFirst({ where: { id: req.params.id, userId: req.user.id } });
  if (!owned) return res.status(404).json({ message: 'Itinerary not found' });
  const row = await prisma.itinerary.update({
    where: { id: req.params.id },
    data: {
      ...body,
      startDate: body.startDate ? new Date(body.startDate) : body.startDate,
      endDate: body.endDate ? new Date(body.endDate) : body.endDate,
    },
    include: includeStops,
  });
  res.json(row);
}));

router.delete('/:id', asyncHandler(async (req, res) => {
  const owned = await prisma.itinerary.findFirst({ where: { id: req.params.id, userId: req.user.id } });
  if (!owned) return res.status(404).json({ message: 'Itinerary not found' });
  await prisma.itinerary.update({ where: { id: req.params.id }, data: { isActive: false } });
  res.json({ message: 'Itinerary archived' });
}));

router.post('/:id/stops', asyncHandler(async (req, res) => {
  const body = z.object({
    destinationId: z.string().min(1),
    dayIndex: z.number().int().min(1).default(1),
    orderIndex: z.number().int().min(0).default(0),
    note: z.string().max(500).optional().nullable(),
    plannedAt: z.string().datetime().optional().nullable(),
  }).parse(req.body);
  const owned = await prisma.itinerary.findFirst({ where: { id: req.params.id, userId: req.user.id } });
  if (!owned) return res.status(404).json({ message: 'Itinerary not found' });
  const stop = await prisma.itineraryStop.create({
    data: {
      itineraryId: req.params.id,
      destinationId: body.destinationId,
      dayIndex: body.dayIndex,
      orderIndex: body.orderIndex,
      note: body.note,
      plannedAt: body.plannedAt ? new Date(body.plannedAt) : null,
    },
    include: { destination: true },
  });
  res.status(201).json(stop);
}));

router.patch('/:id/stops/:stopId', asyncHandler(async (req, res) => {
  const body = z.object({
    dayIndex: z.number().int().min(1).optional(),
    orderIndex: z.number().int().min(0).optional(),
    note: z.string().max(500).optional().nullable(),
    plannedAt: z.string().datetime().optional().nullable(),
  }).parse(req.body);
  const stop = await prisma.itineraryStop.findFirst({ where: { id: req.params.stopId, itinerary: { id: req.params.id, userId: req.user.id } } });
  if (!stop) return res.status(404).json({ message: 'Stop not found' });
  const row = await prisma.itineraryStop.update({
    where: { id: req.params.stopId },
    data: { ...body, plannedAt: body.plannedAt ? new Date(body.plannedAt) : body.plannedAt },
    include: { destination: true },
  });
  res.json(row);
}));

router.delete('/:id/stops/:stopId', asyncHandler(async (req, res) => {
  const stop = await prisma.itineraryStop.findFirst({ where: { id: req.params.stopId, itinerary: { id: req.params.id, userId: req.user.id } } });
  if (!stop) return res.status(404).json({ message: 'Stop not found' });
  await prisma.itineraryStop.delete({ where: { id: req.params.stopId } });
  res.json({ message: 'Stop removed' });
}));

router.post('/:id/stops/:stopId/check-in', asyncHandler(async (req, res) => {
  const stop = await prisma.itineraryStop.findFirst({ where: { id: req.params.stopId, itinerary: { id: req.params.id, userId: req.user.id } } });
  if (!stop) return res.status(404).json({ message: 'Stop not found' });
  const visited = await prisma.userVisitedPlace.upsert({
    where: { userId_destinationId: { userId: req.user.id, destinationId: stop.destinationId } },
    create: { userId: req.user.id, destinationId: stop.destinationId, visitMethod: 'MANUAL_CHECKIN' },
    update: { visitedAt: new Date(), visitMethod: 'MANUAL_CHECKIN' },
  });
  res.status(201).json(visited);
}));

module.exports = router;
