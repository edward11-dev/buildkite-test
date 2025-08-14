const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

function createServer() {
  const app = express();

  // Security middleware
  app.use(helmet());
  app.use(cors());
  app.use(express.json());

  // Routes
  app.get('/', (req, res) => {
    res.json({
      message: 'Welcome to Buildkite Sample App! 🎉',
      version: process.env.npm_package_version || '1.0.0',
      environment: process.env.NODE_ENV || 'development',
      timestamp: new Date().toISOString()
    });
  });

  app.get('/health', (req, res) => {
    res.json({
      status: 'healthy',
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      service: 'buildkite-sample-app'
    });
  });

  app.get('/api/users', (req, res) => {
    const users = [
      { id: 1, name: 'Alice Johnson', email: 'alice@example.com' },
      { id: 2, name: 'Bob Smith', email: 'bob@example.com' },
      { id: 3, name: 'Charlie Brown', email: 'charlie@example.com' }
    ];
    res.json(users);
  });

  app.post('/api/users', (req, res) => {
    const { name, email } = req.body;
    
    if (!name || !email) {
      return res.status(400).json({
        error: 'Name and email are required'
      });
    }

    const newUser = {
      id: Date.now(),
      name,
      email,
      createdAt: new Date().toISOString()
    };

    res.status(201).json(newUser);
  });

  // 404 handler
  app.use('*', (req, res) => {
    res.status(404).json({
      error: 'Route not found',
      path: req.originalUrl
    });
  });

  // Error handler
  app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
      error: 'Internal server error'
    });
  });

  return app;
}

module.exports = { createServer };