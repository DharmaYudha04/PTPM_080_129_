const express = require('express');
const { z } = require('zod');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth } = require('../middleware/auth');
const { distanceKm, normalizeType, rankDestinations } = require('../utils/recommendationEngine');

const router = express.Router();

function publicDestination(item) {
  if (!item) return null;
  return {
    id: item.id,
    slug: item.slug,
    name: item.name,
    type: item.type,
    category: item.category,
    description: item.description,
    story: item.story,
    localInsight: item.localInsight,
    address: item.address,
    latitude: item.latitude,
    longitude: item.longitude,
    imageUrl: item.imageUrl,
    rating: item.rating,
    ticketPrice: item.ticketPrice,
    openingHours: item.openingHours,
    bestTimeToVisit: item.bestTimeToVisit,
    recommendedDuration: item.recommendedDuration,
    culturalValue: item.culturalValue,
    isFeatured: item.isFeatured,
    tags: item.tags,
    distanceKm: item.distanceKm,
    isOpenNow: item.isOpenNow,
    recommendationScore: item.recommendationScore,
    reason: item.reason,
  };
}

async function buildRecommendationContext(userId, lat, lng) {
  const [preferences, visited, shownLogs] = await Promise.all([
    prisma.userPreference.upsert({
      where: { userId },
      create: { userId },
      update: {},
    }),
    prisma.userVisitedPlace.findMany({
      where: { userId },
      select: { destinationId: true },
    }),
    prisma.recommendationLog.findMany({
      where: { userId },
      select: { destinationId: true },
    }),
  ]);

  const visitedIds = new Set(visited.map((item) => item.destinationId));
  const shownCounts = shownLogs.reduce((map, item) => {
    map.set(item.destinationId, (map.get(item.destinationId) || 0) + 1);
    return map;
  }, new Map());

  return {
    lat,
    lng,
    preferences,
    visitedIds,
    shownCounts,
    now: new Date(),
  };
}

async function logShownRecommendations(userId, items) {
  const validItems = items.filter(Boolean);
  await Promise.all(
    validItems.map((item) =>
      prisma.recommendationLog.create({
        data: {
          userId,
          destinationId: item.id,
          category: item.type,
        },
      }),
    ),
  );
}

router.get(
  '/today',
  auth,
  asyncHandler(async (req, res) => {
    const query = z
      .object({
        lat: z.coerce.number().min(-90).max(90).default(-7.7956),
        lng: z.coerce.number().min(-180).max(180).default(110.3695),
        limit: z.coerce.number().int().min(1).max(10).default(1),
      })
      .parse(req.query);

    const context = await buildRecommendationContext(req.user.id, query.lat, query.lng);
    const destinations = await prisma.destination.findMany({
      where: {
        isActive: true,
        id: { notIn: [...context.visitedIds] },
      },
    });

    const pick = (type) =>
      rankDestinations(
        destinations.filter((destination) => destination.type === type),
        context,
      ).slice(0, query.limit);

    const tourism = pick('TOURISM');
    const culinary = pick('CULINARY');
    const culture = pick('CULTURE');

    await logShownRecommendations(req.user.id, [tourism[0], culinary[0], culture[0]]);

    res.json({
      tourism: query.limit === 1 ? publicDestination(tourism[0]) : tourism.map(publicDestination),
      culinary: query.limit === 1 ? publicDestination(culinary[0]) : culinary.map(publicDestination),
      culture: query.limit === 1 ? publicDestination(culture[0]) : culture.map(publicDestination),
      meta: {
        lat: query.lat,
        lng: query.lng,
        radiusKm: context.preferences.recommendationRadiusKm,
        excludedVisitedCount: context.visitedIds.size,
      },
    });
  }),
);

router.get(
  '/nearby',
  auth,
  asyncHandler(async (req, res) => {
    const query = z
      .object({
        lat: z.coerce.number().min(-90).max(90),
        lng: z.coerce.number().min(-180).max(180),
        type: z.string().optional(),
        radiusKm: z.coerce.number().min(0.1).max(100).optional(),
        limit: z.coerce.number().int().min(1).max(30).default(10),
        includeVisited: z.coerce.boolean().default(false),
      })
      .parse(req.query);

    const type = normalizeType(query.type);
    const context = await buildRecommendationContext(req.user.id, query.lat, query.lng);
    if (query.radiusKm) context.preferences.recommendationRadiusKm = query.radiusKm;

    const destinations = await prisma.destination.findMany({
      where: {
        isActive: true,
        ...(type ? { type } : {}),
        ...(query.includeVisited ? {} : { id: { notIn: [...context.visitedIds] } }),
      },
    });

    const ranked = rankDestinations(destinations, context).slice(0, query.limit);
    res.json(ranked.map(publicDestination));
  }),
);

router.post(
  '/logs/:destinationId/click',
  auth,
  asyncHandler(async (req, res) => {
    const log = await prisma.recommendationLog.findFirst({
      where: {
        userId: req.user.id,
        destinationId: req.params.destinationId,
      },
      orderBy: { shownAt: 'desc' },
    });

    if (!log) return res.status(404).json({ message: 'Recommendation log not found' });

    const updated = await prisma.recommendationLog.update({
      where: { id: log.id },
      data: { clickedAt: new Date() },
    });

    res.json(updated);
  }),
);

router.post(
  '/logs/:destinationId/accept',
  auth,
  asyncHandler(async (req, res) => {
    const log = await prisma.recommendationLog.findFirst({
      where: {
        userId: req.user.id,
        destinationId: req.params.destinationId,
      },
      orderBy: { shownAt: 'desc' },
    });

    if (!log) return res.status(404).json({ message: 'Recommendation log not found' });

    const updated = await prisma.recommendationLog.update({
      where: { id: log.id },
      data: { acceptedAt: new Date(), clickedAt: log.clickedAt || new Date() },
    });

    res.json(updated);
  }),
);

router.post(
  '/auto-checkin',
  auth,
  asyncHandler(async (req, res) => {
    const body = z
      .object({
        lat: z.coerce.number().min(-90).max(90),
        lng: z.coerce.number().min(-180).max(180),
        radiusMeters: z.coerce.number().int().min(25).max(500).default(150),
      })
      .parse(req.body);

    const destinations = await prisma.destination.findMany({ where: { isActive: true } });
    const nearest = destinations
      .map((destination) => ({
        destination,
        distanceKm: distanceKm(body.lat, body.lng, destination.latitude, destination.longitude),
      }))
      .sort((a, b) => a.distanceKm - b.distanceKm)[0];

    if (!nearest || nearest.distanceKm * 1000 > body.radiusMeters) {
      return res.json({ checkedIn: false, message: 'No destination inside check-in radius' });
    }

    const visited = await prisma.userVisitedPlace.upsert({
      where: {
        userId_destinationId: {
          userId: req.user.id,
          destinationId: nearest.destination.id,
        },
      },
      create: {
        userId: req.user.id,
        destinationId: nearest.destination.id,
        visitMethod: 'AUTO_LOCATION',
      },
      update: {
        visitedAt: new Date(),
        visitMethod: 'AUTO_LOCATION',
      },
      include: { destination: true },
    });

    res.status(201).json({
      checkedIn: true,
      distanceMeters: Math.round(nearest.distanceKm * 1000),
      visited,
    });
  }),
);

module.exports = router;
