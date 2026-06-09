const express = require('express');
const fs = require('fs');
const path = require('path');
const router = express.Router();

router.get('/openapi.json', (req, res) => {
  res.sendFile(path.join(process.cwd(), 'docs/openapi.json'));
});

router.get('/', (req, res) => {
  res.type('html').send(`<!doctype html><html><head><title>JogjaSplorasi API Docs</title><meta name="viewport" content="width=device-width,initial-scale=1" /></head><body style="font-family:system-ui;padding:32px;max-width:920px;margin:auto"><h1>JogjaSplorasi API Docs</h1><p>OpenAPI spec tersedia di <a href="/api/docs/openapi.json">/api/docs/openapi.json</a>.</p><p>Import file tersebut ke Postman, Insomnia, Swagger Editor, atau Scalar.</p></body></html>`);
});

module.exports = router;
