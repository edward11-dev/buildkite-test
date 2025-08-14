# 🚀 Complete Buildkite Setup Guide

## Prerequisites Check

Before starting, ensure you have:

```bash
# Check Node.js (requires 18+)
node --version

# Check Docker
docker --version
docker info  # Should show Docker is running

# Check Git
git --version
```

## Step 1: Local Development Setup

```bash
# 1. Navigate to the project
cd buildkite-test

# 2. Install dependencies
npm install

# 3. Run tests to verify everything works
npm test

# 4. Start the application
npm start

# 5. Test the API (in another terminal)
curl http://localhost:3000/health
curl http://localhost:3000/api/users
```

**Expected Output:**
```json
{
  "status": "healthy",
  "uptime": 1.234,
  "timestamp": "2025-01-14T...",
  "service": "buildkite-sample-app"
}
```

## Step 2: Docker Testing

```bash
# 1. Build the Docker image
docker build -t buildkite-sample-app .

# 2. Run the container
docker run -p 3000:3000 buildkite-sample-app

# 3. Test the containerized app
curl http://localhost:3000/health

# 4. Stop the container
docker stop $(docker ps -q --filter ancestor=buildkite-sample-app)
```

## Step 3: Buildkite Account Setup

### 3.1 Create Buildkite Account
1. Go to [buildkite.com](https://buildkite.com)
2. Sign up for a free account
3. Create an organization (e.g., "my-company")

### 3.2 Get Agent Token
1. In Buildkite dashboard, go to "Agents"
2. Click "Create an Agent Token"
3. Name it "local-development"
4. Copy the token (starts with something like `abc123...`)

### 3.3 Set Environment Variable
```bash
# Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export BUILDKITE_AGENT_TOKEN="your_token_here"

# Or set it temporarily
export BUILDKITE_AGENT_TOKEN="abc123..."
```

## Step 4: Install and Configure Buildkite Agent

### Option A: Automatic Setup (Recommended)
```bash
# Run our setup script
./scripts/setup-buildkite.sh
```

### Option B: Manual Setup

#### On macOS:
```bash
# Install via Homebrew
brew install buildkite/buildkite/buildkite-agent

# Configure
mkdir -p ~/.buildkite-agent
cat > ~/.buildkite-agent/buildkite-agent.cfg << EOF
token="$BUILDKITE_AGENT_TOKEN"
name="$(hostname)-agent"
tags="queue=default,docker=true,os=macos"
build-path="$HOME/buildkite-builds"
EOF

# Start the agent
buildkite-agent start --config ~/.buildkite-agent/buildkite-agent.cfg
```

#### On Ubuntu/Debian:
```bash
# Add repository
sudo sh -c 'echo deb https://apt.buildkite.com/buildkite-agent stable main > /etc/apt/sources.list.d/buildkite-agent.list'
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198
sudo apt-get update

# Install
sudo apt-get install buildkite-agent

# Configure
sudo sed -i "s/xxx/$BUILDKITE_AGENT_TOKEN/g" /etc/buildkite-agent/buildkite-agent.cfg

# Start
sudo systemctl enable buildkite-agent
sudo systemctl start buildkite-agent
```

## Step 5: Create Git Repository

```bash
# 1. Initialize git (if not already)
git init

# 2. Add all files
git add .

# 3. Commit
git commit -m "Initial commit: Buildkite sample app"

# 4. Add remote (replace with your repo URL)
git remote add origin https://github.com/yourusername/buildkite-sample-app.git

# 5. Push
git push -u origin main
```

## Step 6: Create Buildkite Pipeline

### 6.1 In Buildkite Dashboard:
1. Click "Pipelines" → "New Pipeline"
2. Fill in details:
   - **Name**: "Buildkite Sample App"
   - **Repository**: Your Git repository URL
   - **Default Branch**: `main`

### 6.2 Configure Pipeline:
1. In "Steps" section, select "Read steps from repository"
2. Set **File path**: `.buildkite/pipeline.yml`
3. Click "Create Pipeline"

## Step 7: Trigger First Build

### Option A: Push Code
```bash
# Make a small change
echo "# Test change" >> README.md
git add README.md
git commit -m "Trigger first build"
git push
```

### Option B: Manual Trigger
1. In Buildkite pipeline page
2. Click "New Build"
3. Select branch: `main`
4. Click "Create Build"

## Step 8: Monitor Build Execution

### Watch the Pipeline:
1. **Code Quality Stage**: Install, lint, test (parallel)
2. **Build & Security Stage**: Docker build, security scan
3. **Deploy Stage**: Staging deployment
4. **Manual Gate**: Click "Continue" for production
5. **Post-Deploy**: Integration and performance tests

### Expected Build Flow:
```
✅ Install Dependencies (30s)
✅ Lint Code (10s)  
✅ Run Tests (20s)
⏳ Build Docker Image (60s)
⏳ Security Scan (30s)
✅ Deploy to Staging (20s)
🛑 Deploy to Production? [Manual Approval]
```

## Step 9: Verify Deployments

### Check Staging Deployment:
```bash
# Should be running on port 3001
curl http://localhost:3001/health
curl http://localhost:3001/api/users

# Check Docker container
docker ps | grep staging
```

### After Production Approval:
```bash
# Should be running on port 3000
curl http://localhost:3000/health
curl http://localhost:3000/api/users

# Check Docker container
docker ps | grep prod
```

## Step 10: View Build Artifacts and Logs

### In Buildkite Dashboard:
- **Build logs**: Click on any step to see detailed output
- **Test results**: Coverage reports in artifacts
- **Docker images**: Saved as artifacts between steps
- **Timing**: See which steps take longest

### Local Debugging:
```bash
# View agent logs
tail -f ~/.buildkite-agent/builds/*/buildkite-agent.log

# View container logs
docker logs buildkite-sample-staging
docker logs buildkite-sample-prod
```

## 🔧 Configuration Customization

### Modify Pipeline Behavior:
Edit `.buildkite/pipeline.yml` to:
- Add new test steps
- Change deployment targets
- Modify security scanning
- Add Slack notifications

### Environment-Specific Settings:
```bash
# Staging with debug logging
docker run -e NODE_ENV=staging -e DEBUG=* buildkite-sample-app

# Production with monitoring
docker run -e NODE_ENV=production -e MONITOR_ENDPOINT=https://monitor.example.com buildkite-sample-app
```

## 🐛 Troubleshooting

### Agent Not Connecting:
```bash
# Check agent status
buildkite-agent status

# Verify token
echo $BUILDKITE_AGENT_TOKEN

# Check agent logs
tail -f ~/.buildkite-agent/buildkite-agent.log
```

### Docker Issues:
```bash
# Restart Docker
sudo systemctl restart docker  # Linux
# or restart Docker Desktop on macOS

# Clean up containers
docker system prune -a
```

### Build Failures:
1. **Lint errors**: Fix code style issues
2. **Test failures**: Check test output in Buildkite
3. **Docker build fails**: Check Dockerfile syntax
4. **Deploy fails**: Verify ports aren't in use

### Port Conflicts:
```bash
# Find what's using the port
lsof -ti:3000 | xargs kill -9  # Kill process on port 3000
lsof -ti:3001 | xargs kill -9  # Kill process on port 3001
```

## 🎯 Next Steps

Once everything is working:

1. **Add more tests** to increase coverage
2. **Implement database integration**
3. **Add monitoring and alerting**
4. **Set up multiple environments** (dev, staging, prod)
5. **Implement blue-green deployments**
6. **Add Kubernetes configurations**

## 📚 Understanding the Components

### What Each File Does:
- `.buildkite/pipeline.yml`: Defines the CI/CD workflow
- `Dockerfile`: Multi-stage container build
- `src/server.js`: Express.js application logic
- `src/server.test.js`: Jest unit tests
- `scripts/deploy.sh`: Deployment automation
- `package.json`: Dependencies and npm scripts

### Pipeline Stages Explained:
1. **Code Quality**: Ensures code meets standards
2. **Build & Security**: Creates secure, tested artifacts
3. **Deploy**: Manages environment promotions
4. **Post-Deploy**: Validates deployments work correctly

This setup gives you a production-ready CI/CD pipeline that you can adapt for real projects! 🚀