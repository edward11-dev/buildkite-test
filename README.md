# 🚀 Buildkite Sample App

A complete CI/CD pipeline example using Buildkite, Docker, and Node.js. This project demonstrates best practices for automated testing, building, security scanning, and deployment.

## 📋 Features

- **Node.js API** with Express.js
- **Comprehensive Testing** with Jest
- **Multi-stage Docker Build** for optimized production images
- **Complete Buildkite Pipeline** with parallel steps
- **Security Scanning** with Trivy
- **Automated Deployment** to staging and production
- **Health Checks** and monitoring
- **ESLint** code quality checks

## 🏗️ Project Structure

```
buildkite-sample-app/
├── .buildkite/
│   └── pipeline.yml           # Buildkite pipeline configuration
├── src/
│   ├── app.js                 # Application entry point
│   ├── server.js              # Express server setup
│   └── server.test.js         # Test suite
├── scripts/
│   ├── deploy.sh              # Deployment script
│   └── setup-buildkite.sh     # Buildkite setup script
├── Dockerfile                 # Multi-stage Docker build
├── package.json               # Node.js dependencies and scripts
└── README.md                  # This file
```

## 🚦 Pipeline Stages

### 1. 🔍 Code Quality
- **Install Dependencies**: Install npm packages
- **Lint Code**: ESLint code quality checks
- **Run Tests**: Jest unit tests with coverage

### 2. 🐳 Build & Security
- **Build Docker Image**: Multi-stage optimized build
- **Security Scan**: Trivy container vulnerability scanning

### 3. 🚀 Deploy
- **Deploy to Staging**: Automated staging deployment
- **Manual Approval**: Production deployment gate
- **Deploy to Production**: Production deployment (main branch only)

### 4. 📊 Post-Deploy
- **Integration Tests**: API endpoint testing
- **Performance Tests**: Basic load testing

## 🛠️ Quick Start

### Prerequisites

- Node.js 18+
- Docker
- Git
- Buildkite account

### 1. Local Development

```bash
# Clone the repository
git clone <your-repo-url>
cd buildkite-sample-app

# Install dependencies
npm install

# Run tests
npm test

# Run with coverage
npm run test:coverage

# Start development server
npm run dev

# Start production server
npm start
```

### 2. Docker Development

```bash
# Build the image
docker build -t buildkite-sample-app .

# Run the container
docker run -p 3000:3000 buildkite-sample-app

# Or use npm scripts
npm run docker:build
npm run docker:run
```

### 3. Buildkite Setup

```bash
# Set your Buildkite agent token
export BUILDKITE_AGENT_TOKEN="your_token_here"

# Run the setup script
./scripts/setup-buildkite.sh
```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment mode | `development` |
| `PORT` | Server port | `3000` |
| `BUILDKITE_AGENT_TOKEN` | Buildkite agent token | Required for CI |

### Buildkite Pipeline

The pipeline is configured in `.buildkite/pipeline.yml` and includes:

- **Parallel execution** for tests and linting
- **Conditional deployment** based on branch
- **Manual approval** for production
- **Artifact management** for Docker images
- **Slack notifications** for build status

### Docker Configuration

- **Multi-stage build** for optimized images
- **Non-root user** for security
- **Health checks** for container monitoring
- **Minimal Alpine base** for small image size

## 📊 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Welcome message with app info |
| `/health` | GET | Health check endpoint |
| `/api/users` | GET | List all users |
| `/api/users` | POST | Create a new user |

### Example Usage

```bash
# Health check
curl http://localhost:3000/health

# Get users
curl http://localhost:3000/api/users

# Create user
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
```

## 🚀 Deployment

### Manual Deployment

```bash
# Deploy to staging
./scripts/deploy.sh staging 3001

# Deploy to production
./scripts/deploy.sh production 3000
```

### Buildkite Deployment

1. Push code to your repository
2. Buildkite automatically triggers the pipeline
3. Monitor the build at your Buildkite dashboard
4. Approve production deployment when prompted

## 🔐 Security Features

- **Container security scanning** with Trivy
- **Non-root container execution**
- **Security headers** with Helmet.js
- **Input validation** and error handling
- **Dependency vulnerability checks**

## 📈 Monitoring

### Health Checks

The application includes comprehensive health checks:

```bash
# Container health check (built-in)
docker ps  # Shows healthy status

# Application health check
curl http://localhost:3000/health
```

### Logging

```bash
# View container logs
docker logs -f buildkite-sample-staging

# View production logs
docker logs -f buildkite-sample-prod
```

## 🧪 Testing

### Unit Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

### Integration Tests

Integration tests are automatically run against the staging environment during the pipeline.

## 🔄 Pipeline Optimization Tips

1. **Parallel Execution**: Tests and linting run in parallel
2. **Docker Layer Caching**: Multi-stage builds optimize layer reuse
3. **Artifact Sharing**: Docker images are saved and shared between steps
4. **Conditional Steps**: Production deployment only on main branch
5. **Fail Fast**: Pipeline stops on first failure

## 🛠️ Customization

### Adding New Tests

Add test files in the `src/` directory with `.test.js` extension:

```javascript
// src/newFeature.test.js
const request = require('supertest');
const { createServer } = require('./server');

describe('New Feature', () => {
  // Your tests here
});
```

### Adding Pipeline Steps

Edit `.buildkite/pipeline.yml` to add new steps:

```yaml
- label: "🔍 New Check"
  command: |
    echo "Running new check"
    # Your commands here
  agents:
    queue: "default"
```

### Environment-Specific Configuration

Create environment-specific configuration files:

```bash
# config/staging.json
{
  "database": "staging_db",
  "logLevel": "debug"
}

# config/production.json
{
  "database": "prod_db",
  "logLevel": "info"
}
```

## 🐛 Troubleshooting

### Common Issues

1. **Docker not running**
   ```bash
   # Start Docker
   sudo systemctl start docker  # Linux
   open -a Docker               # macOS
   ```

2. **Buildkite agent not connecting**
   ```bash
   # Check agent status
   buildkite-agent status
   
   # Verify token
   echo $BUILDKITE_AGENT_TOKEN
   ```

3. **Port already in use**
   ```bash
   # Find and kill process using port
   lsof -ti:3000 | xargs kill -9
   ```

4. **Tests failing**
   ```bash
   # Check Node.js version
   node --version  # Should be 18+
   
   # Clear npm cache
   npm cache clean --force
   ```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run tests: `npm test`
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## 📚 Learning Resources

- [Buildkite Documentation](https://buildkite.com/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Node.js Testing Best Practices](https://github.com/goldbergyoni/javascript-testing-best-practices)
- [Express.js Security](https://expressjs.com/en/advanced/best-practice-security.html)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎯 Next Steps

After setting up this pipeline, consider:

1. **Add more comprehensive tests** (integration, e2e)
2. **Implement database integration** with migrations
3. **Add monitoring and alerting** (Prometheus, Grafana)
4. **Implement blue-green deployments**
5. **Add Kubernetes deployment configurations**
6. **Set up automatic dependency updates**

---

**Happy Building! 🚀**