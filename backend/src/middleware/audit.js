const prisma = require('../config/prisma');

async function writeAuditLog({ actorId, action, entity, entityId, metadata, ipAddress, userAgent }) {
  try {
    await prisma.auditLog.create({
      data: {
        actorId: actorId || null,
        action,
        entity,
        entityId: entityId || null,
        metadata: metadata || {},
        ipAddress: ipAddress || null,
        userAgent: userAgent || null,
      },
    });
  } catch (error) {
    console.error('[audit-log-failed]', error.message);
  }
}

function audit(action, entity, getEntityId) {
  return async (req, res, next) => {
    const originalJson = res.json.bind(res);
    res.json = (body) => {
      if (res.statusCode >= 200 && res.statusCode < 400) {
        writeAuditLog({
          actorId: req.user?.id,
          action,
          entity,
          entityId: typeof getEntityId === 'function' ? getEntityId(req, body) : req.params.id,
          metadata: { method: req.method, path: req.originalUrl },
          ipAddress: req.ip,
          userAgent: req.get('user-agent'),
        });
      }
      return originalJson(body);
    };
    next();
  };
}

module.exports = { audit, writeAuditLog };
