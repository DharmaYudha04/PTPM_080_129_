require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const path = require('path');
const requestId = require('./middleware/requestId');
const { apiLimiter } = require('./middleware/rateLimiters');
const { notFound, errorHandler } = require('./middleware/error');

const app = express();
const allowedOrigins = (process.env.CORS_ORIGIN || '*').split(',').map((v) => v.trim());
const isDevelopment = process.env.NODE_ENV !== 'production';

function corsOrigin(origin, callback) {
  if (!origin) return callback(null, true);
  if (allowedOrigins.includes('*') || allowedOrigins.includes(origin)) return callback(null, true);
  if (isDevelopment && /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)) return callback(null, true);
  return callback(new Error(`CORS origin not allowed: ${origin}`));
}
app.use(requestId);
app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(cors({ origin: corsOrigin, credentials: true }));
app.use(compression());
app.use(express.json({ limit: process.env.JSON_LIMIT || '2mb' }));
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));
app.use('/health', require('./routes/health.routes'));
app.use('/api/docs', require('./routes/docs.routes'));
app.use('/api', apiLimiter);
app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/me', require('./routes/me.routes'));
app.use('/api/destinations', require('./routes/destinations.routes'));
app.use('/api/recommendations', require('./routes/recommendations.routes'));
app.use('/api/ai', require('./routes/ai.routes'));
app.use('/api/quiz', require('./routes/quiz.routes'));
app.use('/api/feedback', require('./routes/feedback.routes'));
app.use('/api/reviews', require('./routes/reviews.routes'));
app.use('/api/itineraries', require('./routes/itineraries.routes'));
app.use('/api/stats', require('./routes/stats.routes'));
app.use('/api/sync', require('./routes/sync.routes'));
app.use('/api/export', require('./routes/export.routes'));
app.use('/api/audit-logs', require('./routes/audit.routes'));
app.use('/api/admin', require('./routes/admin.routes'));
app.use('/admin', express.static(path.join(process.cwd(), 'public/admin')));
app.use(notFound);
app.use(errorHandler);
module.exports = app;
