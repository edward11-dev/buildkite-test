const request = require('supertest');
const { createServer } = require('./server');

describe('Buildkite Sample App', () => {
  let app;

  beforeAll(() => {
    app = createServer();
  });

  describe('GET /', () => {
    it('should return welcome message', async () => {
      const response = await request(app)
        .get('/')
        .expect(200);

      expect(response.body).toMatchObject({
        message: 'Welcome to Buildkite Sample App! 🎉',
        version: expect.any(String),
        environment: expect.any(String),
        timestamp: expect.any(String)
      });
    });
  });

  describe('GET /health', () => {
    it('should return health status', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body).toMatchObject({
        status: 'healthy',
        uptime: expect.any(Number),
        timestamp: expect.any(String),
        service: 'buildkite-sample-app'
      });
    });
  });

  describe('GET /api/users', () => {
    it('should return list of users', async () => {
      const response = await request(app)
        .get('/api/users')
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body).toHaveLength(3);
      expect(response.body[0]).toMatchObject({
        id: expect.any(Number),
        name: expect.any(String),
        email: expect.any(String)
      });
    });
  });

  describe('POST /api/users', () => {
    it('should create a new user', async () => {
      const newUser = {
        name: 'Test User',
        email: 'test@example.com'
      };

      const response = await request(app)
        .post('/api/users')
        .send(newUser)
        .expect(201);

      expect(response.body).toMatchObject({
        id: expect.any(Number),
        name: newUser.name,
        email: newUser.email,
        createdAt: expect.any(String)
      });
    });

    it('should return 400 for invalid user data', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({ name: 'Test User' }) // Missing email
        .expect(400);

      expect(response.body).toMatchObject({
        error: 'Name and email are required'
      });
    });
  });

  describe('404 Handler', () => {
    it('should return 404 for unknown routes', async () => {
      const response = await request(app)
        .get('/unknown-route')
        .expect(404);

      expect(response.body).toMatchObject({
        error: 'Route not found',
        path: '/unknown-route'
      });
    });
  });
});