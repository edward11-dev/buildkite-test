#!/bin/bash

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Function to install Buildkite agent
install_buildkite_agent() {
    log "Installing Buildkite agent..."
    
    case "$(uname -s)" in
        Darwin*)
            # macOS
            if command -v brew >/dev/null 2>&1; then
                brew install buildkite/buildkite/buildkite-agent
            else
                warning "Homebrew not found. Please install manually:"
                echo "https://buildkite.com/docs/agent/v3/installation"
            fi
            ;;
        Linux*)
            # Linux
            if command -v apt-get >/dev/null 2>&1; then
                # Ubuntu/Debian
                sudo sh -c 'echo deb https://apt.buildkite.com/buildkite-agent stable main > /etc/apt/sources.list.d/buildkite-agent.list'
                sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198
                sudo apt-get update
                sudo apt-get install -y buildkite-agent
            elif command -v yum >/dev/null 2>&1; then
                # CentOS/RHEL
                sudo sh -c 'echo -e "[buildkite-agent]\nname = Buildkite Pty Ltd\nbaseurl = https://yum.buildkite.com/buildkite-agent/stable/x86_64/\nenabled=1\ngpgcheck=0\npriority=1" > /etc/yum.repos.d/buildkite-agent.repo'
                sudo yum -y install buildkite-agent
            else
                warning "Package manager not detected. Please install manually:"
                echo "https://buildkite.com/docs/agent/v3/installation"
            fi
            ;;
        *)
            warning "OS not supported. Please install manually:"
            echo "https://buildkite.com/docs/agent/v3/installation"
            ;;
    esac
}

# Function to configure Buildkite agent
configure_buildkite_agent() {
    log "Configuring Buildkite agent..."
    
    if [[ -z "${BUILDKITE_AGENT_TOKEN:-}" ]]; then
        warning "BUILDKITE_AGENT_TOKEN environment variable not set"
        echo "Please:"
        echo "1. Go to https://buildkite.com/organizations/YOUR_ORG/agents"
        echo "2. Create a new agent token"
        echo "3. Set the environment variable: export BUILDKITE_AGENT_TOKEN=your_token_here"
        echo "4. Run this script again"
        return 1
    fi
    
    # Find config file location
    local config_file=""
    if [[ -f "/etc/buildkite-agent/buildkite-agent.cfg" ]]; then
        config_file="/etc/buildkite-agent/buildkite-agent.cfg"
    elif [[ -f "$HOME/.buildkite-agent/buildkite-agent.cfg" ]]; then
        config_file="$HOME/.buildkite-agent/buildkite-agent.cfg"
    else
        mkdir -p "$HOME/.buildkite-agent"
        config_file="$HOME/.buildkite-agent/buildkite-agent.cfg"
    fi
    
    log "Creating configuration at $config_file"
    
    cat > "$config_file" << EOF
token="$BUILDKITE_AGENT_TOKEN"
name="$(hostname)-agent"
tags="queue=default,docker=true,os=$(uname -s | tr '[:upper:]' '[:lower:]')"
build-path="$HOME/buildkite-builds"
hooks-path="$HOME/.buildkite-agent/hooks"
plugins-path="$HOME/.buildkite-agent/plugins"
EOF

    success "Buildkite agent configured"
}

# Function to start Buildkite agent
start_buildkite_agent() {
    log "Starting Buildkite agent..."
    
    if command -v systemctl >/dev/null 2>&1; then
        # systemd
        sudo systemctl enable buildkite-agent
        sudo systemctl start buildkite-agent
        success "Buildkite agent started via systemd"
    elif command -v launchctl >/dev/null 2>&1; then
        # macOS launchd
        buildkite-agent start --config "$HOME/.buildkite-agent/buildkite-agent.cfg" &
        success "Buildkite agent started in background"
    else
        # Manual start
        buildkite-agent start --config "$HOME/.buildkite-agent/buildkite-agent.cfg" &
        success "Buildkite agent started in background"
    fi
}

# Function to create pipeline
create_pipeline() {
    log "Pipeline setup instructions:"
    echo
    echo "1. Go to https://buildkite.com/organizations/YOUR_ORG/pipelines/new"
    echo "2. Configure your pipeline:"
    echo "   - Name: Buildkite Sample App"
    echo "   - Repository: YOUR_REPO_URL"
    echo "   - Default Branch: main"
    echo "3. In the 'Steps' section, select 'Read steps from repository'"
    echo "4. Set the file path to: .buildkite/pipeline.yml"
    echo "5. Click 'Create Pipeline'"
    echo
    success "Pipeline creation instructions provided"
}

# Function to setup local development
setup_local_dev() {
    log "Setting up local development environment..."
    
    # Install dependencies if package.json exists
    if [[ -f "package.json" ]]; then
        if command -v npm >/dev/null 2>&1; then
            npm install
            success "NPM dependencies installed"
        else
            warning "npm not found. Please install Node.js"
        fi
    fi
    
    # Create .env file if it doesn't exist
    if [[ ! -f ".env" ]]; then
        cat > .env << EOF
NODE_ENV=development
PORT=3000
# Add your environment variables here
EOF
        success "Created .env file"
    fi
}

# Main setup function
main() {
    echo "🚀 Buildkite Sample App Setup"
    echo "=================================="
    echo
    
    setup_local_dev
    
    if command -v buildkite-agent >/dev/null 2>&1; then
        success "Buildkite agent already installed"
    else
        install_buildkite_agent
    fi
    
    configure_buildkite_agent
    start_buildkite_agent
    create_pipeline
    
    echo
    success "Setup completed! 🎉"
    echo
    log "Next steps:"
    echo "1. Create your Buildkite organization and pipeline"
    echo "2. Push this code to your Git repository"
    echo "3. Trigger your first build!"
    echo
    log "To test locally:"
    echo "  npm install"
    echo "  npm test"
    echo "  npm start"
    echo
    log "To build and run with Docker:"
    echo "  docker build -t buildkite-sample-app ."
    echo "  docker run -p 3000:3000 buildkite-sample-app"
}

# Check if running with --help
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Buildkite Sample App Setup Script"
    echo
    echo "This script helps you set up the Buildkite agent and environment"
    echo "for the sample application."
    echo
    echo "Prerequisites:"
    echo "- Docker installed and running"
    echo "- Git repository created"
    echo "- Buildkite account and organization"
    echo
    echo "Environment Variables:"
    echo "  BUILDKITE_AGENT_TOKEN  Your Buildkite agent token"
    echo
    echo "Usage:"
    echo "  ./setup-buildkite.sh"
    echo
    exit 0
fi

# Run main function
main