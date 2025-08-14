# Missing Files for buildkite-test Repository

## 🔧 Required Files to Add

### 1. Create `.buildkite/pipeline.yml`

```bash
mkdir -p .buildkite
```

Create `.buildkite/pipeline.yml` with this content:

```yaml
env:
  NODE_ENV: "test"
  
steps:
  - group: "🔍 Code Quality"
    steps:
      - label: "📦 Install Dependencies"
        key: "install"
        command: |
          echo "--- 📦 Installing dependencies"
          npm ci
        agents:
          queue: "default"

      - label: "🧹 Lint Code"
        key: "lint"
        depends_on: "install"
        command: |
          echo "--- 🧹 Running ESLint"
          npm run lint
        agents:
          queue: "default"

      - label: "🧪 Run Tests"
        key: "test"
        depends_on: "install"
        command: |
          echo "--- 🧪 Running test suite"
          npm test
          npm run test:coverage
        agents:
          queue: "default"
        artifact_paths:
          - "coverage/**/*"

  - wait: "~"

  - group: "🐳 Build & Deploy"
    steps:
      - label: "🐳 Build Docker Image"
        key: "build"
        command: |
          echo "--- 🐳 Building Docker image"
          docker build -t buildkite-test:$BUILDKITE_COMMIT .
          docker tag buildkite-test:$BUILDKITE_COMMIT buildkite-test:latest
        agents:
          queue: "default"

      - label: "🚀 Deploy to Staging"
        key: "deploy-staging"
        depends_on: "build"
        command: |
          echo "--- 🚀 Deploying to staging"
          docker stop buildkite-test-staging 2>/dev/null || true
          docker rm buildkite-test-staging 2>/dev/null || true
          docker run -d --name buildkite-test-staging -p 3001:3000 -e NODE_ENV=staging buildkite-test:$BUILDKITE_COMMIT
          sleep 5
          curl -f http://localhost:3001/health
        agents:
          queue: "default"
        branches: "main develop"

      - block: "🎯 Deploy to Production?"
        prompt: "Deploy to production?"
        branches: "main"

      - label: "🌟 Deploy to Production"
        key: "deploy-production"
        depends_on: "deploy-staging"
        command: |
          echo "--- 🌟 Deploying to production"
          docker stop buildkite-test-prod 2>/dev/null || true
          docker rm buildkite-test-prod 2>/dev/null || true
          docker run -d --name buildkite-test-prod -p 3000:3000 -e NODE_ENV=production buildkite-test:$BUILDKITE_COMMIT
          sleep 5
          curl -f http://localhost:3000/health
        agents:
          queue: "default"
        branches: "main"
```

### 2. Create `.eslintrc.js`

```javascript
module.exports = {
  env: {
    browser: true,
    commonjs: true,
    es2021: true,
    node: true,
    jest: true,
  },
  extends: [
    'eslint:recommended',
  ],
  parserOptions: {
    ecmaVersion: 'latest',
  },
  rules: {
    'indent': ['error', 2],
    'linebreak-style': ['error', 'unix'],
    'quotes': ['error', 'single'],
    'semi': ['error', 'always'],
    'no-unused-vars': ['error', { 'argsIgnorePattern': '^_' }],
    'no-console': 'off',
  },
};
```

### 3. Create `.gitignore`

```
# Dependencies
node_modules/
npm-debug.log*

# Coverage
coverage/
.nyc_output

# Environment
.env
.env.local

# Logs
*.log

# Docker
*.tar.gz

# IDE
.vscode/
.idea/
.DS_Store

# Buildkite
buildkite-builds/
```

### 4. Create `.dockerignore`

```
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
coverage
*.md
.buildkite
scripts
```

## 🚀 Quick Setup Commands

Run these commands in your `buildkite-test` directory:

```bash
# 1. Add missing config files (copy content from above)
mkdir -p .buildkite
# Create the files with content above

# 2. Initialize git if not already done
git init
git add .
git commit -m "Initial buildkite-test setup"

# 3. Test locally first
npm install
npm test
npm run lint

# 4. Test Docker build
docker build -t buildkite-test .
docker run -p 3000:3000 buildkite-test

# 5. Push to your Git repository
git remote add origin YOUR_REPO_URL
git push -u origin main
```

## 📋 Buildkite Pipeline Setup

1. **Go to Buildkite dashboard**
2. **Create New Pipeline:**
   - Name: "Buildkite Test"
   - Repository: Your Git repo URL
   - Default Branch: `main`
3. **Pipeline Configuration:**
   - Select "Read steps from repository"
   - File path: `.buildkite/pipeline.yml`
4. **Create Pipeline**

## 🧪 Testing Your Setup

### Local Testing:
```bash
cd buildkite-test
npm install
npm test
npm run lint
npm start
curl http://localhost:3000/health
```

### Docker Testing:
```bash
docker build -t buildkite-test .
docker run -p 3000:3000 buildkite-test
curl http://localhost:3000/health
```

### Git Push Testing:
```bash
git add .
git commit -m "Test buildkite pipeline"
git push
# Watch your Buildkite dashboard for the triggered build
```

## 🔧 Buildkite Agent Setup

If you haven't set up the Buildkite agent yet:

```bash
# Set your token (get from Buildkite dashboard > Agents)
export BUILDKITE_AGENT_TOKEN="your_token_here"

# Run the setup script
./scripts/setup-buildkite.sh
```

## 📊 Expected Pipeline Flow

When you push to Git, Buildkite will:

1. **Install Dependencies** (npm ci)
2. **Lint Code** (ESLint checks)
3. **Run Tests** (Jest with coverage)
4. **Build Docker Image**
5. **Deploy to Staging** (port 3001)
6. **Wait for Manual Approval**
7. **Deploy to Production** (port 3000, main branch only)

## 🐛 Troubleshooting

### Common Issues:

1. **"queue not found"** - Make sure your agent has `queue=default` tag
2. **Docker not found** - Ensure Docker is running on your agent machine
3. **Port conflicts** - Kill existing processes on ports 3000/3001
4. **npm ci fails** - Delete node_modules and package-lock.json, run npm install

### Verification Commands:
```bash
# Check agent status
buildkite-agent status

# Check Docker
docker ps
docker images | grep buildkite-test

# Check running containers
curl http://localhost:3001/health  # staging
curl http://localhost:3000/health  # production
```

This setup will give you a complete working CI/CD pipeline! 🚀