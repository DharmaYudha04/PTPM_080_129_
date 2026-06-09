const express = require('express');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth: requireAuth } = require('../middleware/auth');


function googleMapsUrl(destination) {
  const lat = destination.latitude;
  const lon = destination.longitude;
  if (typeof lat === 'number' && typeof lon === 'number') {
    return `https://www.google.com/maps/search/?api=1&query=${lat},${lon}`;
  }
  return `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${destination.name} Yogyakarta`)}`;
}

function openStreetMapUrl(destination) {
  const lat = destination.latitude;
  const lon = destination.longitude;
  if (typeof lat === 'number' && typeof lon === 'number') {
    return `https://www.openstreetmap.org/?mlat=${lat}&mlon=${lon}#map=17/${lat}/${lon}`;
  }
  return `https://www.openstreetmap.org/search?query=${encodeURIComponent(`${destination.name} Yogyakarta`)}`;
}

function enrichDestination(destination) {
  return {
    ...destination,
    mapsUrl: googleMapsUrl(destination),
    osmUrl: openStreetMapUrl(destination),
    dataSource: 'CURATED_LOCAL_DATABASE',
  };
}

const router = express.Router();
router.use(requireAuth);

router.get('/bootstrap', asyncHandler(async (req, res) => {
  const [destinations, favorites, visitedPlaces, preferences, itineraries] = await Promise.all([
    prisma.destination.findMany({ where: { isActive: true }, orderBy: [{ isFeatured: 'desc' }, { name: 'asc' }] }),
    prisma.userFavorite.findMany({ where: { userId: req.user.id }, select: { destinationId: true, createdAt: true } }),
    prisma.userVisitedPlace.findMany({ where: { userId: req.user.id }, select: { destinationId: true, visitedAt: true, visitMethod: true } }),
    prisma.userPreference.findUnique({ where: { userId: req.user.id } }),
    prisma.itinerary.findMany({
      where: { userId: req.user.id, isActive: true },
      include: { stops: { include: { destination: true }, orderBy: [{ dayIndex: 'asc' }, { orderIndex: 'asc' }] } },
      orderBy: { updatedAt: 'desc' },
    }),
  ]);

  res.json({
    syncedAt: new Date().toISOString(),
    destinations: destinations.map(enrichDestination),
    favorites,
    visitedPlaces,
    preferences,
    itineraries,
  });
}));

router.post('/push', asyncHandler(async (req, res) => {
  const operations = Array.isArray(req.body.operations) ? req.body.operations : [];
  const results = [];

  for (const op of operations) {
    try {
      if (op.type === 'favorite.add') {
        await prisma.userFavorite.upsert({
          where: { userId_destinationId: { userId: req.user.id, destinationId: op.destinationId } },
          update: {},
          create: { userId: req.user.id, destinationId: op.destinationId },
        });
      } else if (op.type === 'favorite.remove') {
        await prisma.userFavorite.deleteMany({ where: { userId: req.user.id, destinationId: op.destinationId } });
      } else if (op.type === 'visited.add') {
        await prisma.userVisitedPlace.upsert({
          where: { userId_destinationId: { userId: req.user.id, destinationId: op.destinationId } },
          update: { visitedAt: op.visitedAt ? new Date(op.visitedAt) : new Date() },
          create: { userId: req.user.id, destinationId: op.destinationId, visitedAt: op.visitedAt ? new Date(op.visitedAt) : new Date() },
        });
      } else if (op.type === 'preferences.update') {
        await prisma.userPreference.upsert({
          where: { userId: req.user.id },
          update: op.payload || {},
          create: { userId: req.user.id, ...(op.payload || {}) },
        });
      } else {
        throw new Error(`Unknown operation type: ${op.type}`);
      }
      results.push({ clientId: op.clientId || null, status: 'ok' });
    } catch (error) {
      results.push({ clientId: op.clientId || null, status: 'error', message: error.message });
    }
  }

  res.json({ syncedAt: new Date().toISOString(), results });
}));

module.exports = router;
