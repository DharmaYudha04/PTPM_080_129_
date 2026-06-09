function validate(schema) {
  return (req, res, next) => {
    const parsed = schema.safeParse({ body: req.body, params: req.params, query: req.query });
    if (!parsed.success) {
      parsed.error.status = 422;
      return next(parsed.error);
    }
    req.validated = parsed.data;
    next();
  };
}
module.exports = validate;
