const express = require('express');
const { z } = require('zod');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth } = require('../middleware/auth');
const { buildLocalGuideReply, buildItinerary } = require('../utils/aiGuideEngine');
const { buildLlmReply } = require('../utils/llmProvider');

const router = express.Router();

function publicDestination(item) {
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
    tags: item.tags,
  };
}

router.post('/guide/chat', auth, asyncHandler(async (req, res) => {
  const body = z.object({
    message: z.string().min(3).max(1200),
    conversationId: z.string().optional(),
    limitContext: z.coerce.number().int().min(3).max(12).default(8),
    userLatitude: z.coerce.number().optional(),
    userLongitude: z.coerce.number().optional(),
  }).parse(req.body);

  const [profile, destinations] = await Promise.all([
    prisma.userProfile.findUnique({ where: { userId: req.user.id } }),
    prisma.destination.findMany({ where: { isActive: true, isVerified: true } }),
  ]);

  const localReply = buildLocalGuideReply({
    message: body.message,
    destinations,
    userName: profile?.fullName,
  });

  const citedContext = destinations.filter((item) =>
    localReply.citedDestinationIds.includes(item.id),
  );

  const llmReply = await buildLlmReply({
    message: body.message,
    destinations: citedContext.length ? citedContext : destinations.slice(0, body.limitContext),
    userName: profile?.fullName,
  });

  const reply = llmReply?.answer
    ? {
        ...localReply,
        answer: llmReply.answer,
        confidence: llmReply.confidence,
        provider: llmReply.provider,
        fallbackReason: null,
      }
    : {
        ...localReply,
        provider: 'database-grounded-local',
        fallbackReason: llmReply?.fallbackReason || null,
      };

  const citedDestinations = destinations
    .filter((item) => reply.citedDestinationIds.includes(item.id))
    .map(publicDestination);

  let conversation = null;
  if (body.conversationId) {
    conversation = await prisma.aiConversation.findFirst({
      where: { id: body.conversationId, userId: req.user.id },
    });
  }

  if (!conversation) {
    conversation = await prisma.aiConversation.create({
      data: { userId: req.user.id, title: body.message.slice(0, 80) },
    });
  } else {
    conversation = await prisma.aiConversation.update({
      where: { id: conversation.id },
      data: { title: conversation.title || body.message.slice(0, 80) },
    });
  }

  await prisma.aiMessage.createMany({
    data: [
      { conversationId: conversation.id, role: 'USER', content: body.message },
      {
        conversationId: conversation.id,
        role: 'ASSISTANT',
        content: reply.answer,
        citedDestinationIds: reply.citedDestinationIds,
        metadata: {
          confidence: reply.confidence,
          mode: reply.provider,
          userLatitude: body.userLatitude,
          userLongitude: body.userLongitude,
        },
      },
    ],
  });

  const noteByProvider = {
    'gemini-web-grounded': 'Jawaban memakai Google Gemini dengan web grounding untuk informasi terkini, serta tetap membawa konteks JogjaSplorasi.',
    'gemini-context-grounded': 'Jawaban memakai Google Gemini dengan konteks database JogjaSplorasi tanpa web search agar lebih hemat kuota.',
    'groq-context-grounded': 'Jawaban memakai Groq sebagai AI utama yang hemat dan cepat, dengan konteks database JogjaSplorasi.',
    'openrouter-context-grounded': 'Jawaban memakai OpenRouter sebagai cadangan, dengan konteks database JogjaSplorasi.',
    'database-grounded-local': 'Jawaban memakai fallback lokal dan dibatasi pada data destinasi aktif/terverifikasi.',
  };

  res.json({
    conversationId: conversation.id,
    answer: reply.answer,
    confidence: reply.confidence,
    citedDestinations,
    guardrails: {
      groundedInDatabase: reply.provider !== 'gemini-web-grounded',
      mode: reply.provider,
      fallbackReason: reply.fallbackReason,
      note: noteByProvider[reply.provider] || 'Jawaban memakai AI Guide JogjaSplorasi dengan fallback aman.',
    },
  });
}));

router.get('/guide/conversations', auth, asyncHandler(async (req, res) => {
  const conversations = await prisma.aiConversation.findMany({
    where: { userId: req.user.id },
    orderBy: { updatedAt: 'desc' },
    take: 30,
    include: { messages: { orderBy: { createdAt: 'desc' }, take: 1 } },
  });
  res.json(conversations);
}));

router.get('/guide/conversations/:id', auth, asyncHandler(async (req, res) => {
  const conversation = await prisma.aiConversation.findFirst({
    where: { id: req.params.id, userId: req.user.id },
    include: { messages: { orderBy: { createdAt: 'asc' } } },
  });
  if (!conversation) return res.status(404).json({ message: 'Conversation not found' });
  res.json(conversation);
}));

router.post('/itinerary/suggest', auth, asyncHandler(async (req, res) => {
  const body = z.object({
    days: z.coerce.number().int().min(1).max(5).default(1),
    pace: z.enum(['slow', 'normal', 'fast']).default('normal'),
    types: z.array(z.enum(['TOURISM', 'CULINARY', 'CULTURE'])).optional(),
    keywords: z.array(z.string().min(1).max(40)).optional(),
    excludeVisited: z.boolean().default(true),
  }).parse(req.body);

  const visited = body.excludeVisited
    ? await prisma.userVisitedPlace.findMany({ where: { userId: req.user.id }, select: { destinationId: true } })
    : [];
  const visitedIds = visited.map((item) => item.destinationId);

  const destinations = await prisma.destination.findMany({
    where: {
      isActive: true,
      isVerified: true,
      ...(body.types?.length ? { type: { in: body.types } } : {}),
      ...(visitedIds.length ? { id: { notIn: visitedIds } } : {}),
    },
  });

  const keywordText = (body.keywords || []).join(' ').toLowerCase();
  const filtered = keywordText
    ? destinations.filter((item) => [
        item.name,
        item.category,
        item.description,
        item.story,
        item.localInsight,
        ...(item.tags || []),
      ].join(' ').toLowerCase().includes(keywordText))
    : destinations;

  const plan = buildItinerary({
    destinations: filtered.length ? filtered : destinations,
    days: body.days,
    pace: body.pace,
  });

  res.json({
    days: body.days,
    pace: body.pace,
    generatedFrom: 'database-grounded-local-engine',
    plan,
  });
}));

module.exports = router;
