const express = require('express');
const { z } = require('zod');
const slugify = require('slugify');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth, optionalAuth, requireAdmin } = require('../middleware/auth');
const AppError = require('../utils/AppError');
const router = express.Router();

const destinationSelect = {
  id: true,
  slug: true,
  name: true,
  type: true,
  category: true,
  description: true,
  story: true,
  localInsight: true,
  address: true,
  latitude: true,
  longitude: true,
  imageUrl: true,
  rating: true,
  ticketPrice: true,
  openingHours: true,
  bestTimeToVisit: true,
  recommendedDuration: true,
  culturalValue: true,
  isFeatured: true,
  isVerified: true,
  tags: true,
  createdAt: true,
  updatedAt: true,
};


async function withFavoriteFlags(req, destinations) {
  if (!req.user || !destinations.length) return destinations;
  const ids = destinations.map((item) => item.id);
  const favorites = await prisma.userFavorite.findMany({
    where: { userId: req.user.id, destinationId: { in: ids } },
    select: { destinationId: true },
  });
  const favoriteIds = new Set(favorites.map((item) => item.destinationId));
  return destinations.map((item) => ({ ...item, isFavorite: favoriteIds.has(item.id) }));
}

function normalizeType(type) {
  if (!type) return undefined;
  return String(type).toUpperCase();
}

function normalizeText(value) {
  return String(value || '')
    .toLowerCase()
    .replace(/[_-]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function categoryAliases(value) {
  const v = normalizeText(value);
  const map = {
    budaya: ['budaya', 'culture', 'cultural', 'heritage', 'keraton', 'tradisi', 'jawa'],
    culture: ['budaya', 'culture', 'cultural', 'heritage', 'keraton', 'tradisi', 'jawa'],
    sejarah: ['sejarah', 'history', 'historical', 'heritage', 'museum', 'kolonial'],
    history: ['sejarah', 'history', 'historical', 'heritage', 'museum'],
    alam: ['alam', 'nature', 'natural', 'pantai', 'gunung', 'goa', 'hutan', 'bukit'],
    nature: ['alam', 'nature', 'natural', 'pantai', 'gunung', 'goa', 'hutan', 'bukit'],
    kuliner: ['kuliner', 'culinary', 'food', 'makanan', 'gudeg', 'kopi', 'sate'],
    culinary: ['kuliner', 'culinary', 'food', 'makanan', 'gudeg', 'kopi', 'sate'],
    belanja: ['belanja', 'shopping', 'oleh oleh', 'oleh-oleh', 'pasar', 'gift'],
    shopping: ['belanja', 'shopping', 'oleh oleh', 'oleh-oleh', 'pasar', 'gift'],
    seni: ['seni', 'art', 'museum', 'galeri', 'batik', 'lukisan'],
    art: ['seni', 'art', 'museum', 'galeri', 'batik', 'lukisan'],
    aktivitas: ['aktivitas', 'activity', 'adventure', 'outbound', 'camping', 'hiking'],
    activity: ['aktivitas', 'activity', 'adventure', 'outbound', 'camping', 'hiking'],
    foto: ['foto', 'photo', 'photospot', 'spot foto', 'instagramable', 'view'],
    photo: ['foto', 'photo', 'photospot', 'spot foto', 'instagramable', 'view'],
    keluarga: ['keluarga', 'family', 'edukasi', 'anak', 'rekreasi'],
    family: ['keluarga', 'family', 'edukasi', 'anak', 'rekreasi'],
  };
  return [...new Set([v, ...(map[v] || [])])].filter(Boolean);
}

function typeValuesFor(value) {
  const aliases = categoryAliases(value);
  const values = new Set();
  if (aliases.some((alias) => ['budaya', 'culture', 'cultural', 'heritage', 'sejarah', 'history', 'museum', 'seni', 'art'].includes(alias))) values.add('CULTURE');
  if (aliases.some((alias) => ['kuliner', 'culinary', 'food', 'makanan', 'gudeg', 'kopi', 'sate'].includes(alias))) values.add('CULINARY');
  if (aliases.some((alias) => ['alam', 'nature', 'natural', 'pantai', 'gunung', 'goa', 'hutan', 'bukit', 'aktivitas', 'activity', 'foto', 'photo', 'belanja', 'shopping', 'keluarga', 'family'].includes(alias))) values.add('TOURISM');
  const upper = String(value || '').toUpperCase();
  if (['TOURISM', 'CULINARY', 'CULTURE'].includes(upper)) values.add(upper);
  return [...values];
}

function categoryWhere(value) {
  const aliases = categoryAliases(value);
  if (!aliases.length) return undefined;
  return {
    OR: [
      ...aliases.map((alias) => ({ category: { contains: alias, mode: 'insensitive' } })),
      ...typeValuesFor(value).map((type) => ({ type })),
      ...aliases.map((alias) => ({ tags: { has: alias } })),
    ],
  };
}

async function uniqueSlug(name, ignoredId) {
  const base = slugify(name, { lower: true, strict: true }) || `destinasi-${Date.now()}`;
  let slug = base;
  let count = 2;
  while (true) {
    const exists = await prisma.destination.findUnique({ where: { slug } });
    if (!exists || exists.id === ignoredId) return slug;
    slug = `${base}-${count++}`;
  }
}

router.get('/', optionalAuth, asyncHandler(async (req, res) => {
  const { search, type, category, tag, featured } = req.query;
  const where = { isActive: true };
  const andFilters = [];
  const normalizedType = normalizeType(type);

  if (normalizedType) where.type = normalizedType;
  if (category) andFilters.push(categoryWhere(category));
  if (tag) andFilters.push(categoryWhere(tag));
  if (featured === 'true') where.isFeatured = true;

  if (search) {
    const value = String(search);
    const aliases = categoryAliases(value);
    andFilters.push({
      OR: [
        { name: { contains: value, mode: 'insensitive' } },
        { description: { contains: value, mode: 'insensitive' } },
        { story: { contains: value, mode: 'insensitive' } },
        { localInsight: { contains: value, mode: 'insensitive' } },
        { address: { contains: value, mode: 'insensitive' } },
        { category: { contains: value, mode: 'insensitive' } },
        ...typeValuesFor(value).map((itemType) => ({ type: itemType })),
        ...aliases.map((alias) => ({ tags: { has: alias } })),
      ],
    });
  }

  const cleanedFilters = andFilters.filter(Boolean);
  if (cleanedFilters.length) where.AND = cleanedFilters;

  const data = await prisma.destination.findMany({
    where,
    select: destinationSelect,
    orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }, { name: 'asc' }],
  });
  res.json(await withFavoriteFlags(req, data));
}));

router.get('/featured', optionalAuth, asyncHandler(async (req, res) => {
  const data = await prisma.destination.findMany({
    where: { isActive: true, isFeatured: true },
    select: destinationSelect,
    orderBy: { rating: 'desc' },
  });
  res.json(await withFavoriteFlags(req, data));
}));


router.get('/meta/categories', asyncHandler(async (req, res) => {
  res.json([
    { label: 'Budaya', query: 'Budaya' },
    { label: 'Sejarah', query: 'Sejarah' },
    { label: 'Alam', query: 'Alam' },
    { label: 'Kuliner', query: 'Kuliner' },
    { label: 'Belanja', query: 'Belanja' },
    { label: 'Seni', query: 'Seni' },
    { label: 'Aktivitas', query: 'Aktivitas' },
    { label: 'Foto', query: 'Foto' },
    { label: 'Keluarga', query: 'Keluarga' },
  ]);
}));

router.get('/meta/tags', asyncHandler(async (req, res) => {
  const rows = await prisma.destination.findMany({ where: { isActive: true }, select: { tags: true } });
  const tags = [...new Set(rows.flatMap((row) => row.tags || []))].sort((a, b) => a.localeCompare(b));
  res.json(tags);
}));

router.get('/:idOrSlug', optionalAuth, asyncHandler(async (req, res) => {
  const idOrSlug = req.params.idOrSlug;
  const item = await prisma.destination.findFirst({
    where: {
      isActive: true,
      OR: [{ id: idOrSlug }, { slug: idOrSlug }],
    },
    select: destinationSelect,
  });
  if (!item) throw new AppError('Destinasi tidak ditemukan.', 404, 'DESTINATION_NOT_FOUND');
  const [flagged] = await withFavoriteFlags(req, [item]);
  res.json(flagged);
}));

const destinationSchema = z.object({
  name: z.string().min(2),
  type: z.enum(['TOURISM', 'CULINARY', 'CULTURE']),
  category: z.string().min(2),
  description: z.string().min(3),
  story: z.string().optional().nullable(),
  localInsight: z.string().optional().nullable(),
  address: z.string().min(3),
  latitude: z.number(),
  longitude: z.number(),
  imageUrl: z.string().url().optional().nullable(),
  rating: z.number().min(0).max(5).optional(),
  ticketPrice: z.string().optional().nullable(),
  openingHours: z.string().optional().nullable(),
  bestTimeToVisit: z.string().optional().nullable(),
  recommendedDuration: z.string().optional().nullable(),
  culturalValue: z.number().int().min(0).max(5).optional(),
  isFeatured: z.boolean().optional(),
  tags: z.array(z.string()).optional(),
});

router.post('/', auth, requireAdmin, asyncHandler(async (req, res) => {
  const body = destinationSchema.parse(req.body);
  const item = await prisma.destination.create({
    data: { ...body, slug: await uniqueSlug(body.name) },
    select: destinationSelect,
  });
  res.status(201).json(item);
}));

router.patch('/:id', auth, requireAdmin, asyncHandler(async (req, res) => {
  const body = destinationSchema.partial().parse(req.body);
  const data = { ...body };
  if (body.name) data.slug = await uniqueSlug(body.name, req.params.id);
  const item = await prisma.destination.update({
    where: { id: req.params.id },
    data,
    select: destinationSelect,
  });
  res.json(item);
}));

router.delete('/:id', auth, requireAdmin, asyncHandler(async (req, res) => {
  await prisma.destination.update({ where: { id: req.params.id }, data: { isActive: false } });
  res.json({ success: true, message: 'Destinasi berhasil dinonaktifkan.' });
}));

module.exports = router;
