#!/bin/bash
# Build, Test, and Push Docker Image for SolvingMicroDSOPs
#
# Builds the standalone Docker image using the root Dockerfile, smoke-tests
# it by running reproduce.sh --docs inside a container, then pushes to DockerHub
# if the test passes.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}ℹ️  $*${NC}"; }
log_success() { echo -e "${GREEN}✅ $*${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $*${NC}"; }
log_error()   { echo -e "${RED}❌ $*${NC}"; }

# Change to repository root
cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"

# Derive image name from directory name
REPO_NAME=$(basename "$REPO_ROOT" | tr '[:upper:]' '[:lower:]')
REPO_SUFFIX=${REPO_NAME#solvingmicrodsops-}   # e.g. "latest", "public"

DOCKER_USER="llorracc"
DOCKER_IMAGE_NAME="solvingmicrodsops-${REPO_SUFFIX}"
DOCKER_IMAGE_TAG="latest"
DOCKER_IMAGE="${DOCKER_USER}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
DOCKER_CONTAINER="test-${DOCKER_IMAGE_NAME}-$$"

DEBUG_LOG="/tmp/docker-build-debug-${DOCKER_IMAGE_NAME}-$$.log"

echo ""
echo "=========================================="
echo "Docker Build, Test, and Push"
echo "=========================================="
echo ""
log_info "Repository: $REPO_ROOT"
log_info "Docker image: $DOCKER_IMAGE"
echo ""

# ── Step 0: Ensure Docker is running ──────────────────────────────────────────
log_info "Step 0: Ensuring Docker daemon is running..."
if ! docker info >/dev/null 2>&1; then
    log_warning "Docker daemon not running, attempting to start..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Starting Docker Desktop on macOS..."
        open -a Docker
        log_info "Waiting for Docker daemon (up to 60 s)..."
        for i in {1..60}; do
            if docker info >/dev/null 2>&1; then
                log_success "Docker daemon is ready"
                break
            fi
            if [[ $i -eq 60 ]]; then
                log_error "Docker daemon failed to start within 60 seconds"
                exit 1
            fi
            echo -n "."
            sleep 1
        done
        echo ""
    else
        log_error "Docker daemon not running. Start with: sudo systemctl start docker"
        exit 1
    fi
else
    log_success "Docker daemon is already running"
fi

# ── Step 0.1: Stop conflicting containers ─────────────────────────────────────
log_info "Step 0.1: Stopping running containers..."
RUNNING_CONTAINERS=$(docker ps -q)
if [[ -n "$RUNNING_CONTAINERS" ]]; then
    docker stop "$RUNNING_CONTAINERS" || true
    log_success "All containers stopped"
else
    log_info "No running containers"
fi

# ── Step 0.2: Prune Docker storage ────────────────────────────────────────────
log_info "Step 0.2: Pruning Docker storage..."
docker system prune -af --volumes && log_success "Storage pruged" || log_warning "Prune had issues, continuing"
docker system df

# ── Step 1: Verify Dockerfile ─────────────────────────────────────────────────
[[ -f "Dockerfile" ]] || { log_error "Dockerfile not found in $REPO_ROOT"; exit 1; }
log_success "Dockerfile found"

# ── Step 2: Build ─────────────────────────────────────────────────────────────
log_info "Building Docker image: $DOCKER_IMAGE"
if ! docker build -t "$DOCKER_IMAGE" .; then
    log_error "Docker build failed"
    exit 1
fi
IMAGE_SIZE=$(docker images "$DOCKER_IMAGE" --format "{{.Size}}" | head -1)
log_success "Docker image built successfully (size: $IMAGE_SIZE)"

# ── Step 3: Test ──────────────────────────────────────────────────────────────
log_info "Testing Docker image..."
docker rm -f "$DOCKER_CONTAINER" 2>/dev/null || true

log_info "Starting test container: $DOCKER_CONTAINER"
if ! docker run -d --name "$DOCKER_CONTAINER" "$DOCKER_IMAGE" tail -f /dev/null; then
    log_error "Failed to start test container"
    exit 1
fi
log_success "Test container started"

# Test 1: reproduce.sh exists
log_info "Test 1: Checking reproduce.sh..."
if ! docker exec "$DOCKER_CONTAINER" test -x /workspace/reproduce.sh; then
    log_error "reproduce.sh not found or not executable"
    docker rm -f "$DOCKER_CONTAINER" 2>/dev/null || true
    exit 1
fi
log_success "reproduce.sh found and executable"

# Diagnostics
log_info "Running diagnostic checks..."
PDFLATEX_PATH=$(docker exec "$DOCKER_CONTAINER" bash -c 'which pdflatex' 2>&1)
echo "{\"pdflatex\":\"$PDFLATEX_PATH\"}" >> "$DEBUG_LOG"
PYTHON_PATH=$(docker exec "$DOCKER_CONTAINER" bash -c 'which python' 2>&1)
echo "{\"python\":\"$PYTHON_PATH\"}" >> "$DEBUG_LOG"
log_success "Diagnostics saved to $DEBUG_LOG"

# Test 2: smoke-test document build
log_info "Test 2: Running reproduce.sh --docs in container..."
if docker exec "$DOCKER_CONTAINER" bash -c "source /home/vscode/.bashrc 2>/dev/null; cd /workspace && ./reproduce.sh --docs" > /tmp/docker-test-$$.log 2>&1; then
    log_success "reproduce.sh --docs completed successfully"
    if docker exec "$DOCKER_CONTAINER" test -f /workspace/SolvingMicroDSOPs.pdf; then
        PDF_SIZE=$(docker exec "$DOCKER_CONTAINER" ls -lh /workspace/SolvingMicroDSOPs.pdf | awk '{print $5}')
        log_success "SolvingMicroDSOPs.pdf generated ($PDF_SIZE)"
    else
        log_warning "reproduce.sh succeeded but SolvingMicroDSOPs.pdf not found"
    fi
else
    log_error "reproduce.sh --docs failed in container"
    echo ""
    echo "Last 50 lines of output:"
    tail -50 /tmp/docker-test-$$.log
    docker rm -f "$DOCKER_CONTAINER" 2>/dev/null || true
    rm -f /tmp/docker-test-$$.log
    exit 1
fi

# Cleanup
log_info "Cleaning up test container..."
docker rm -f "$DOCKER_CONTAINER" 2>/dev/null || true
rm -f /tmp/docker-test-$$.log
log_success "Test container removed"

echo ""
log_success "All tests passed"

# ── Step 4: Push ──────────────────────────────────────────────────────────────
log_info "Pushing to DockerHub: $DOCKER_IMAGE"
if ! docker push "$DOCKER_IMAGE"; then
    log_error "Docker push failed. Login with: docker login"
    exit 1
fi

echo ""
log_success "Docker image pushed successfully"
echo ""
echo "=========================================="
echo "Docker Build Complete"
echo "=========================================="
echo ""
echo "Image: $DOCKER_IMAGE"
echo "Size:  $IMAGE_SIZE"
echo "DockerHub: https://hub.docker.com/r/$DOCKER_USER/$DOCKER_IMAGE_NAME"
echo ""
echo "To use this image:"
echo "  docker pull $DOCKER_IMAGE"
echo "  docker run -it $DOCKER_IMAGE bash"
echo ""
