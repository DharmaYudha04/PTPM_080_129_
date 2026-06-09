const rateLimit = require('express-rate-limit');

const standardHandler = (req, res) => res.status(429).json({
  success: false,
  code: 'RATE_LIMITED',
  message: 'Terlalu banyak request. Coba lagi beberapa saat.',
  requestId: req.id,
});

const apiLimiter = rateLimit({
  windowMs: Number(process.env.RATE_LIMIT_WINDOW_MS || 15 * 60 * 1000),
  limit: Number(process.env.RATE_LIMIT_MAX || 600),
  standardHeaders: true,
  legacyHeaders: false,
  handler: standardHandler,
});

const authLimiter = rateLimit({
  windowMs: Number(process.env.AUTH_RATE_LIMIT_WINDOW_MS || 15 * 60 * 1000),
  limit: Number(process.env.AUTH_RATE_LIMIT_MAX || 20),
  standardHeaders: true,
  legacyHeaders: false,
  handler: standardHandler,
});

const uploadLimiter = rateLimit({
  windowMs: Number(process.env.UPLOAD_RATE_LIMIT_WINDOW_MS || 60 * 60 * 1000),
  limit: Number(process.env.UPLOAD_RATE_LIMIT_MAX || 40),
  standardHeaders: true,
  legacyHeaders: false,
  handler: standardHandler,
});

module.exports = { apiLimiter, authLimiter, uploadLimiter };
