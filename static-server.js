const express = require('express');
const expressStaticGzip = require('express-static-gzip');
const path = require('path');

const app = express();
const PORT = 9090;

// Middleware pro statické soubory s gzip podporou
app.use('/', expressStaticGzip(path.join('/site', '.vuepress', 'dist'), {
  enableBrotli: true,
  customCompressions: [],
  fallthrough: false
}));

// Fallback pro SPA routing
app.get('*', (req, res) => {
  res.sendFile(path.join('/site', '.vuepress', 'dist', 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Static server running on http://0.0.0.0:${PORT}`);
});
