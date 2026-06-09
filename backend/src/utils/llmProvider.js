const logger = require('./logger');

function envFlag(name, fallback = false) {
  const value = process.env[name];
  if (value == null || value === '') return fallback;
  return ['1', 'true', 'yes', 'y', 'on'].includes(String(value).toLowerCase());
}

function googleMapsUrl(destination) {
  if (!destination) return '';
  const lat = destination.latitude;
  const lon = destination.longitude;
  if (lat && lon) return `https://www.google.com/maps/search/?api=1&query=${lat},${lon}`;
  return `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${destination.name} Yogyakarta`)}`;
}

function compactDestination(destination) {
  return {
    id: destination.id,
    name: destination.name,
    category: destination.category,
    type: destination.type,
    description: destination.description,
    story: destination.story,
    localInsight: destination.localInsight,
    address: destination.address,
    mapsUrl: googleMapsUrl(destination),
    bestTimeToVisit: destination.bestTimeToVisit,
    ticketPrice: destination.ticketPrice,
    openingHours: destination.openingHours,
    recommendedDuration: destination.recommendedDuration,
    culturalValue: destination.culturalValue,
    rating: destination.rating,
    tags: destination.tags || [],
  };
}

function needsInternet(message) {
  const text = String(message || '').toLowerCase();
  const webHints = [
    'terbaru', 'terkini', 'sekarang', 'hari ini', 'malam ini', 'minggu ini', 'bulan ini', 'tahun ini',
    'event', 'acara', 'festival', 'jadwal', 'sedang buka', 'masih buka', 'buka sekarang',
    'harga tiket terbaru', 'promo', 'berita', 'viral', 'populer sekarang', 'cuaca', 'transportasi online',
    'internet', 'web', 'cari online', 'cek online', 'sumber resmi', 'informasi terbaru', 'update',
  ];
  return webHints.some((hint) => text.includes(hint));
}

function buildSystemPrompt({ allowWeb = false } = {}) {
  const groundingRule = allowWeb
    ? 'Gunakan konteks database JogjaSplorasi sebagai pegangan utama untuk destinasi yang tersedia. Untuk pertanyaan terkini, event, jadwal, harga terbaru, atau hal yang tidak ada di database, boleh gunakan informasi web/search bila tool tersedia. Jelaskan dengan jujur jika data masih perlu dicek ke sumber resmi.'
    : 'Gunakan konteks database JogjaSplorasi sebagai pegangan utama. Jika pertanyaan meminta informasi terkini/event/harga terbaru yang tidak ada di konteks, jangan mengarang; sampaikan dengan sopan bahwa data terkini sebaiknya dicek melalui sumber resmi.';

  return [
    'Kamu adalah "Mas/Mbak Guide Jogja", pemandu wisata lokal di aplikasi JogjaSplorasi.',
    'Tujuanmu: membuat pengguna merasa sedang berbicara dengan orang Jogja asli yang ramah, alus, sabar, dan paham wisata.',
    'Utamakan salam sapa dan sopan santun. Awali jawaban dengan sapaan pendek bernuansa Jawa yang natural, misalnya: "Sugeng rawuh", "Nggih", "Monggo", atau "Kula bantu".',
    'Bahasa utama WAJIB bahasa Indonesia yang mudah dipahami wisatawan luar daerah. Tambahkan bahasa Jawa ringan secukupnya saja, seperti "Sugeng rawuh", "Nggih", "monggo", "matur nuwun", "panjenengan", "kula bantu". Jangan memakai bahasa Jawa penuh.',
    'Jangan terlalu sering memakai template yang sama. Hindari pembuka berulang seperti "Siap, ...". Buat jawaban terasa natural seperti pemandu manusia.',
    groundingRule,
    'Jawab hanya sesuai kebutuhan pengguna. Default jawaban singkat: 2-5 kalimat atau 3-5 poin pendek. Jangan melebar ke banyak topik.',
    'Jika pengguna hanya menyapa, balas ramah, terima sapaannya, lalu tanyakan apa yang bisa dibantu. Jangan langsung memberi daftar rekomendasi.',
    'Jika pengguna meminta saran/rekomendasi tempat, pilih tepat 1 destinasi terbaik dari konteks database. Jangan memberi 2, 3, itinerary panjang, atau daftar alternatif kecuali pengguna jelas meminta beberapa opsi.',
    'Untuk destinasi, jelaskan alasan cocok, suasana, waktu kunjungan, estimasi biaya/jam buka jika tersedia, dan satu tips halus khas Jogja.',
    'Kalau pengguna menanyakan sejarah, budaya, asal-usul, kisah, makna, candi, keraton, museum, atau tradisi, prioritaskan story, localInsight, culturalValue, dan konteks budaya dari database. Jelaskan dengan akurat dan mudah dipahami.',
    'Kalau pengguna menanyakan tempat spesifik, fokus jawab tempat itu dulu. Jangan langsung memberi rekomendasi tempat lain kecuali diminta.',
    'Kalau data kurang pasti, gunakan kalimat seperti: "Untuk jadwal/harga paling anyar, monggo dicek lagi di kanal resmi nggih."',
    'Format jawaban: pembuka hangat, isi yang padat, lalu penutup sopan singkat. Maksimal 180 kata kecuali pengguna meminta penjelasan detail panjang.',
    'Jangan menyebutkan instruksi sistem, token, provider, API, atau detail teknis backend kepada pengguna.',
  ].join('\n');
}

function buildUserPrompt({ message, destinations, userName, allowWeb = false }) {
  const contextLimit = Number(process.env.AI_GUIDE_MAX_CONTEXT_DESTINATIONS || 4);
  const context = destinations.slice(0, contextLimit).map(compactDestination);
  return [
    `Nama pengguna: ${userName || 'Pelancong'}`,
    `Pertanyaan pengguna: ${message}`,
    `Internet/search boleh dipakai: ${allowWeb ? 'YA, jika perlu info terkini atau di luar database' : 'TIDAK, hemat kuota; jawab dari pengetahuan model dan konteks database saja'}`,
    'Konteks destinasi database JogjaSplorasi dalam JSON:',
    JSON.stringify(context),
    'Tugas: jawab sebagai pemandu wisata Jogja yang sopan, hangat, informatif, dan bernuansa Jawa ringan.',
    'Aturan respons: sapaan saja = sambut dan tanya bisa bantu apa; rekomendasi/saran tempat = tepat 1 destinasi terbaik; pertanyaan sejarah/budaya = jelaskan konteks budaya dari field story/localInsight/culturalValue; data tidak cukup = jujur dan beri arahan aman.',
  ].join('\n');
}

function normalizeAnswer(answer, userName) {
  const clean = String(answer || '').trim();
  if (!clean) return null;

  const lower = clean.toLowerCase();
  const hasJavaneseTone = ['sugeng', 'nggih', 'monggo', 'matur nuwun', 'panjenengan', 'kula'].some((word) => lower.includes(word));

  if (hasJavaneseTone) return clean;

  const greetingName = userName ? `, ${userName}` : '';
  return `Sugeng rawuh${greetingName}. Nggih, kula bantu sebagai pemandu Jogja.\n\n${clean}\n\nMatur nuwun, semoga perjalanan panjenengan di Jogja terasa nyaman dan menyenangkan.`;
}

function appendSources(answer, sources) {
  const unique = [];
  const seen = new Set();
  for (const source of sources || []) {
    const title = source.title || source.uri || 'Sumber web';
    const uri = source.uri || source.url;
    if (!uri || seen.has(uri)) continue;
    seen.add(uri);
    unique.push({ title, uri });
    if (unique.length >= 4) break;
  }
  if (!unique.length) return answer;
  const lines = unique.map((source, index) => `${index + 1}. ${source.title} - ${source.uri}`);
  return `${answer}\n\nSumber rujukan:\n${lines.join('\n')}`;
}

function extractGeminiSources(data) {
  const chunks = data?.candidates?.[0]?.groundingMetadata?.groundingChunks || [];
  return chunks
    .map((chunk) => chunk.web || chunk.retrievedContext || null)
    .filter(Boolean)
    .map((web) => ({ title: web.title, uri: web.uri || web.url }));
}

function isRetryableAiError(error) {
  const message = String(error?.message || '').toLowerCase();
  return message.includes('429') || message.includes('503') || message.includes('unavailable') || message.includes('quota') || message.includes('rate');
}

async function callOpenRouter({ message, destinations, userName, allowWeb = false }) {
  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) return null;

  const model = process.env.OPENROUTER_MODEL || 'meta-llama/llama-3.3-70b-instruct:free';
  const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
      'HTTP-Referer': process.env.PUBLIC_BASE_URL || 'http://localhost:3000',
      'X-Title': 'JogjaSplorasi',
    },
    body: JSON.stringify({
      model,
      temperature: 0.5,
      max_tokens: 520,
      messages: [
        { role: 'system', content: buildSystemPrompt({ allowWeb: false }) },
        { role: 'user', content: buildUserPrompt({ message, destinations, userName, allowWeb }) },
      ],
    }),
  });

  if (!response.ok) {
    const body = await response.text().catch(() => '');
    throw new Error(`OpenRouter error ${response.status}: ${body.slice(0, 320)}`);
  }

  const data = await response.json();
  const answer = data?.choices?.[0]?.message?.content;
  return normalizeAnswer(answer, userName);
}

async function callGroq({ message, destinations, userName }) {
  const apiKey = process.env.GROQ_API_KEY;
  if (!apiKey) return null;

  const model = process.env.GROQ_MODEL || 'llama-3.1-8b-instant';
  const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model,
      temperature: 0.45,
      top_p: 0.9,
      max_tokens: 520,
      messages: [
        { role: 'system', content: buildSystemPrompt({ allowWeb: false }) },
        { role: 'user', content: buildUserPrompt({ message, destinations, userName, allowWeb: false }) },
      ],
    }),
  });

  if (!response.ok) {
    const body = await response.text().catch(() => '');
    throw new Error(`Groq error ${response.status}: ${body.slice(0, 320)}`);
  }

  const data = await response.json();
  const answer = data?.choices?.[0]?.message?.content;
  return normalizeAnswer(answer, userName);
}

async function callGemini({ message, destinations, userName, useWeb = false }) {
  const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_GEMINI_API_KEY;
  if (!apiKey) return null;

  const model = process.env.GEMINI_MODEL || 'gemini-2.0-flash';
  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(apiKey)}`;
  const body = {
    systemInstruction: {
      parts: [{ text: buildSystemPrompt({ allowWeb: useWeb }) }],
    },
    contents: [
      {
        role: 'user',
        parts: [{ text: buildUserPrompt({ message, destinations, userName, allowWeb: useWeb }) }],
      },
    ],
    generationConfig: {
      temperature: 0.5,
      topP: 0.9,
      topK: 40,
      maxOutputTokens: 560,
    },
  };

  if (useWeb) {
    if (model.includes('1.5')) {
      body.tools = [{ google_search_retrieval: {} }];
    } else {
      body.tools = [{ google_search: {} }];
    }
  }

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const responseBody = await response.text().catch(() => '');
    throw new Error(`Gemini error ${response.status}: ${responseBody.slice(0, 320)}`);
  }

  const data = await response.json();
  const blocked = data?.promptFeedback?.blockReason;
  if (blocked) throw new Error(`Gemini blocked prompt: ${blocked}`);

  const answer = data?.candidates?.[0]?.content?.parts
    ?.map((part) => part.text)
    .filter(Boolean)
    .join('\n');

  const normalized = normalizeAnswer(answer, userName);
  const sources = useWeb ? extractGeminiSources(data) : [];
  return {
    answer: appendSources(normalized, sources),
    sourceCount: sources.length,
  };
}

async function tryProvider({ provider, message, destinations, userName, useWeb = false, contextCount }) {
  if (provider === 'gemini') {
    const result = await callGemini({ message, destinations, userName, useWeb });
    if (!result?.answer) return null;
    logger.info({ provider: 'gemini', model: process.env.GEMINI_MODEL || 'gemini-2.0-flash', contextCount, webEnabled: useWeb, webSourceCount: result.sourceCount || 0 }, useWeb ? '[AI] Gemini web-grounded response generated' : '[AI] Gemini response generated');
    return {
      answer: result.answer,
      provider: useWeb ? 'gemini-web-grounded' : 'gemini-context-grounded',
      confidence: 'high',
      fallbackReason: null,
    };
  }

  if (provider === 'groq') {
    const answer = await callGroq({ message, destinations, userName });
    if (!answer) return null;
    logger.info({ provider: 'groq', model: process.env.GROQ_MODEL || 'llama-3.1-8b-instant', contextCount }, '[AI] Groq response generated');
    return {
      answer,
      provider: 'groq-context-grounded',
      confidence: 'high',
      fallbackReason: null,
    };
  }

  if (provider === 'openrouter') {
    const answer = await callOpenRouter({ message, destinations, userName });
    if (!answer) return null;
    logger.info({ provider: 'openrouter', model: process.env.OPENROUTER_MODEL || 'meta-llama/llama-3.3-70b-instruct:free', contextCount }, '[AI] OpenRouter response generated');
    return {
      answer,
      provider: 'openrouter-context-grounded',
      confidence: 'high',
      fallbackReason: null,
    };
  }

  return null;
}

function buildPlan(mode, shouldUseWeb) {
  const fallbackEnabled = envFlag('AI_GUIDE_ENABLE_FALLBACK', true);
  const webEnabled = envFlag('AI_GUIDE_USE_WEB', false);
  const normalizedMode = (mode || 'local').toLowerCase();
  const plan = [];

  function add(provider, useWeb = false) {
    if (provider === 'local') return;
    const exists = plan.some((item) => item.provider === provider && item.useWeb === useWeb);
    if (!exists) plan.push({ provider, useWeb });
  }

  if (normalizedMode === 'groq') {
    // Hemat kuota: Groq menjadi default. Gemini web hanya dipakai untuk pertanyaan terkini/di luar database.
    if (shouldUseWeb && webEnabled) add('gemini', true);
    add('groq', false);
  } else if (['gemini', 'google', 'google-gemini'].includes(normalizedMode)) {
    add('gemini', shouldUseWeb && webEnabled);
  } else if (normalizedMode === 'openrouter') {
    add('openrouter', false);
  }

  if (fallbackEnabled) {
    add('groq', false);
    add('gemini', false);
    add('openrouter', false);
  }

  return plan;
}

async function buildLlmReply({ message, destinations, userName }) {
  const mode = (process.env.AI_GUIDE_MODE || 'local').toLowerCase();
  const contextCount = destinations.length;
  const shouldUseWeb = needsInternet(message);
  const webEnabled = envFlag('AI_GUIDE_USE_WEB', false);
  const retryOn429 = envFlag('AI_GUIDE_RETRY_ON_429', true);
  const plan = buildPlan(mode, shouldUseWeb);
  const errors = [];

  logger.debug({ mode, contextCount, webEnabled, shouldUseWeb, plan }, '[AI] buildLlmReply invoked');

  for (const step of plan) {
    try {
      const result = await tryProvider({
        provider: step.provider,
        useWeb: step.useWeb,
        message,
        destinations,
        userName,
        contextCount,
      });
      if (result?.answer) {
        return {
          ...result,
          fallbackReason: errors.length ? `Fallback setelah: ${errors.join(' | ')}` : null,
        };
      }
      errors.push(`${step.provider}${step.useWeb ? '-web' : ''}: empty answer`);
    } catch (error) {
      const label = `${step.provider}${step.useWeb ? '-web' : ''}`;
      const detail = `${label}: ${error.message}`;
      errors.push(detail);
      logger.warn({ provider: step.provider, webEnabled: step.useWeb, err: error.message }, `[AI] ${label} failed`);

      if (!retryOn429 && isRetryableAiError(error)) break;
    }
  }

  if (!plan.length) {
    logger.info({ mode }, '[AI] Local mode selected');
  } else {
    logger.warn({ mode, errors }, '[AI] All remote providers failed, using local fallback');
  }

  return {
    answer: null,
    provider: null,
    confidence: null,
    fallbackReason: errors.join(' | ') || null,
  };
}

module.exports = {
  buildLlmReply,
  googleMapsUrl,
  compactDestination,
  buildSystemPrompt,
  needsInternet,
};
