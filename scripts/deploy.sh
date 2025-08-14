#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="buildkite-sample-app"
CONTAINER_NAME_PREFIX="buildkite-sample"
IMAGE_TAG="${BUILDKITE_COMMIT:-latest}"
ENVIRONMENT="${1:-staging}"
PORT="${2:-3001}"

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Validate environment
validate_environment() {
    case $ENVIRONMENT in
        staging|production)
            log "Deploying to $ENVIRONMENT environment"
            ;;
        *)
            error "Invalid environment: $ENVIRONMENT. Use 'staging' or 'production'"
            ;;
    esac
}

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        error "Docker is not running. Please start Docker and try again."
    fi
    success "Docker is running"
}

# Load Docker image
load_image() {
    if [[ -f "image.tar.gz" ]]; then
        log "Loading Docker image from artifact..."
        docker load < image.tar.gz
        success "Image loaded successfully"
    else
        log "Building Docker image locally..."
        docker build --target production -t "$APP_NAME:$IMAGE_TAG" .
        docker tag "$APP_NAME:$IMAGE_TAG" "$APP_NAME:latest"
        success "Image built successfully"
    fi
}

# Stop and remove existing container
cleanup_existing() {
    local container_name="$CONTAINER_NAME_PREFIX-$ENVIRONMENT"
    
    if docker ps -a --format "table {{.Names}}" | grep -q "^$container_name$"; then
        log "Stopping existing container: $container_name"
        docker stop "$container_name" 2>/dev/null || true
        docker rm "$container_name" 2>/dev/null || true
        success "Cleaned up existing container"
    else
        log "No existing container found"
    fi
}

# Deploy the application
deploy() {
    local container_name="$CONTAINER_NAME_PREFIX-$ENVIRONMENT"
    
    log "Starting new container: $container_name"
    docker run -d \
        --name "$container_name" \
        -p "$PORT:3000" \
        -e NODE_ENV="$ENVIRONMENT" \
        -e PORT=3000 \
        --restart unless-stopped \
        "$APP_NAME:$IMAGE_TAG"
    
    success "Container started successfully"
}

# Health check
health_check() {
    local max_attempts=30
    local attempt=1
    local url="http://localhost:$PORT/health"
    
    log "Performing health check ($url)..."
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -f -s "$url" >/dev/null 2>&1; then
            success "Health check passed!"
            return 0
        fi
        
        log "Health check attempt $attempt/$max_attempts failed, retrying in 2 seconds..."
        sleep 2
        ((attempt++))
    done
    
    error "Health check failed after $max_attempts attempts"
}

# Show deployment info
show_info() {
    local container_name="$CONTAINER_NAME_PREFIX-$ENVIRONMENT"
    
    echo
    log "Deployment completed successfully!"
    echo -e "${GREEN}🌐 Application URL: http://localhost:$PORT${NC}"
    echo -e "${GREEN}🏥 Health Check: http://localhost:$PORT/health${NC}"
    echo -e "${GREEN}👥 Users API: http://localhost:$PORT/api/users${NC}"
    echo
    
    log "Container details:"
    docker ps --filter "name=$container_name" --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"
    
    echo
    log "To view logs, run:"
    echo "  docker logs -f $container_name"
    echo
    log "To stop the application, run:"
    echo "  docker stop $container_name"
}

# Rollback function
rollback() {
    warning "Rolling back deployment..."
    # This would typically involve deploying the previous version
    # For this demo, we'll just stop the current container
    cleanup_existing
    error "Rollback completed. Please deploy a stable version."
}

# Trap errors and attempt rollback
trap 'rollback' ERR

# Main deployment flow
main() {
    log "Starting deployment of $APP_NAME to $ENVIRONMENT"
    
    validate_environment
    check_docker
    load_image
    cleanup_existing
    deploy
    health_check
    show_info
    
    success "Deployment completed successfully! 🎉"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --environment|-e)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --port|-p)
            PORT="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS] [ENVIRONMENT] [PORT]"
            echo "Deploy the Buildkite sample application"
            echo
            echo "Options:"
            echo "  -e, --environment   Environment to deploy to (staging|production)"
            echo "  -p, --port         Port to expose the application on"
            echo "  -h, --help         Show this help message"
            echo
            echo "Examples:"
            echo "  $0 staging 3001"
            echo "  $0 --environment production --port 3000"
            exit 0
            ;;
        *)
            if [[ -z ${ENVIRONMENT:-} ]]; then
                ENVIRONMENT="$1"
            elif [[ -z ${PORT:-} ]]; then
                PORT="$1"
            else
                error "Unknown argument: $1"
            fi
            shift
            ;;
    esac
done

# Run main function
main