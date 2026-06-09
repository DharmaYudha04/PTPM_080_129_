const jwt = require('jsonwebtoken');
const prisma = require('../config/prisma');

function unauthorized(req, res) {
  return res.status(401).json({
    success: false,
    code: 'UNAUTHORIZED',
    message: 'Sesi tidak valid atau sudah berakhir. Silakan masuk kembali.',
    requestId: req.id,
  });
}

async function auth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return unauthorized(req, res);
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    const user = await prisma.user.findUnique({ where: { id: payload.sub } });
    if (!user || !user.isActive) return unauthorized(req, res);
    req.user = user;
    next();
  } catch {
    return unauthorized(req, res);
  }
}

async function optionalAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return next();
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    const user = await prisma.user.findUnique({ where: { id: payload.sub } });
    if (user && user.isActive) req.user = user;
  } catch {
    // Public endpoints tetap berjalan tanpa status login.
  }
  next();
}

function requireAdmin(req, res, next) {
  if (req.user?.role !== 'ADMIN') {
    return res.status(403).json({
      success: false,
      code: 'ADMIN_ONLY',
      message: 'Akses admin diperlukan untuk tindakan ini.',
      requestId: req.id,
    });
  }
  next();
}

module.exports = { auth, optionalAuth, requireAdmin };
