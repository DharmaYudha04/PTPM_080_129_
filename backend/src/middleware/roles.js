function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) return res.status(401).json({ success: false, code: 'UNAUTHENTICATED', message: 'Authentication required', requestId: req.id });
    if (!roles.includes(req.user.role)) return res.status(403).json({ success: false, code: 'FORBIDDEN', message: 'You do not have permission to access this resource', requestId: req.id });
    next();
  };
}
module.exports = { requireRole };
