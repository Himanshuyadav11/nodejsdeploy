// app.js
const express = require('express');
const morgan = require('morgan');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(morgan('dev'));
app.use(express.static(path.join(__dirname, 'public')));

// Health check endpoint for Kubernetes
app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

// Home page
app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Welcome to Node.js Deployment</title>
            <style>
                body {
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    background: linear-gradient(to right, #00c6ff, #0072ff);
                    color: white;
                    text-align: center;
                    padding-top: 100px;
                }
                h1 {
                    font-size: 3em;
                    margin-bottom: 20px;
                }
                p {
                    font-size: 1.2em;
                }
                footer {
                    position: fixed;
                    bottom: 20px;
                    width: 100%;
                    text-align: center;
                    font-size: 0.9em;
                }
            </style>
        </head>
        <body>
            <h1>🚀 Deployed with Jenkins + Docker + K8s</h1>
            <p>This Node.js app is running beautifully on your cloud infrastructure.</p>
            <footer>Made by Himanshu Yadav | DevOps Project</footer>
        </body>
        </html>
    `);
});

// Start server
app.listen(PORT, () => {
    console.log(`🌐 Server is running on http://localhost:${PORT}`);
});
