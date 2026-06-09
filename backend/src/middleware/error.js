function notFound(req, res) {
  res.status(404).json({
    success: false,
    code: 'NOT_FOUND',
    message: 'Route tidak ditemukan.',
    requestId: req.id,
  });
}

function mapPrismaError(err) {
  if (!err || !err.code) return null;
  if (err.code === 'P2002') {
    return { status: 409, code: 'DUPLICATE_DATA', message: 'Data sudah terdaftar.' };
  }
  if (err.code === 'P2025') {
    return { status: 404, code: 'DATA_NOT_FOUND', message: 'Data tidak ditemukan.' };
  }
  if (err.code === 'P2003') {
    return { status: 400, code: 'RELATION_INVALID', message: 'Data relasi tidak valid.' };
  }
  return null;
}

function formatZodErrors(err) {
  return err.errors.map((item) => ({
    path: item.path.join('.'),
    message: item.message,
  }));
}

function errorHandler(err, req, res, next) {
  const isZod = err && err.name === 'ZodError';
  const prismaError = mapPrismaError(err);
  const status = err.status || prismaError?.status || (isZod ? 422 : 500);
  const code = err.code || prismaError?.code || (isZod ? 'VALIDATION_ERROR' : 'INTERNAL_ERROR');

  const response = {
    success: false,
    code,
    message: isZod
      ? 'Data yang dikirim belum sesuai.'
      : prismaError?.message || err.message || 'Terjadi kesalahan pada server.',
    requestId: req.id,
  };

  if (isZod) response.errors = formatZodErrors(err);
  if (err.details) response.details = err.details;

  if (status >= 500) {
    console.error({ requestId: req.id, code, err });
    response.message = process.env.NODE_ENV === 'production'
      ? 'Server sedang bermasalah. Silakan coba lagi nanti.'
      : response.message;
  }

  res.status(status).json(response);
}

module.exports = { notFound, errorHandler };
