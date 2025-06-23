const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`<h1>🚀 Hello from Node.js App!</h1><p>Deployed successfully.</p>`);
});

app.get('/health', (req, res) => {
  res.json({ status: 'UP', time: new Date().toISOString() });
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
