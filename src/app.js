const { createServer } = require('./server');

const app = createServer();
const PORT = process.env.PORT || 3000;

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/health`);
    console.log(`🏠 Home: http://localhost:${PORT}/`);
  });
}

module.exports = app;