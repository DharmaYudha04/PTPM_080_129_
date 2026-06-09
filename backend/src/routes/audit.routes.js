const express = require('express');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth: requireAuth, requireAdmin } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth, requireAdmin);

router.get('/', asyncHandler(async (req, res) => {
  const take = Math.min(Number(req.query.limit || 50), 200);
  const logs = await prisma.auditLog.findMany({
    take,
    orderBy: { createdAt: 'desc' },
    include: { actor: { select: { id: true, email: true, role: true, profile: true } } },
  });
  res.json({ logs });
}));

module.exports = router;
