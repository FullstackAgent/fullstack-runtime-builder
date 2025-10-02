#!/bin/bash

# Build script for Full-Stack Web Runtime Docker Image
# This script provides multiple build options including cloud-based builds

# Set variables
IMAGE_NAME="fullstackagent/fullstack-web-runtime"
IMAGE_TAG="${1:-latest}"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Full-Stack Web Runtime Build Script${NC}"
echo "Image: $FULL_IMAGE_NAME"
echo ""

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] [TAG]"
    echo ""
    echo "Options:"
    echo "  --local     Build locally using Docker/Buildah/Podman"
    echo "  --github    Trigger GitHub Actions build (requires gh CLI)"
    echo "  --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  # Build locally with tag 'latest'"
    echo "  $0 v1.0.0           # Build locally with tag 'v1.0.0'"
    echo "  $0 --github         # Trigger GitHub Actions build"
    echo "  $0 --local v2.0.0   # Build locally with specific tag"
}

# Parse arguments
BUILD_METHOD="local"
while [[ $# -gt 0 ]]; do
    case $1 in
        --local)
            BUILD_METHOD="local"
            shift
            ;;
        --github)
            BUILD_METHOD="github"
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            if [[ ! "$1" =~ ^-- ]]; then
                IMAGE_TAG="$1"
                FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"
            fi
            shift
            ;;
    esac
done

# GitHub Actions build
if [ "$BUILD_METHOD" = "github" ]; then
    echo -e "${YELLOW}Triggering GitHub Actions build...${NC}"

    # Check if gh CLI is installed
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
        echo "Install it from: https://cli.github.com/"
        exit 1
    fi

    # Trigger workflow
    echo "Triggering workflow with tag: $IMAGE_TAG"
    gh workflow run docker-build.yml -f tag="$IMAGE_TAG"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}GitHub Actions workflow triggered successfully!${NC}"
        echo "Check the build status at: https://github.com/FullstackAgent/fullstack-runtime-builder/actions"
        echo ""
        echo "Once built, the image will be available at:"
        echo "  docker pull $FULL_IMAGE_NAME"
    else
        echo -e "${RED}Failed to trigger GitHub Actions workflow${NC}"
        exit 1
    fi
    exit 0
fi

# Local build
echo -e "${YELLOW}Attempting local build...${NC}"

# Check for Docker Hub credentials for local build
if [ -z "$DOCKER_HUB_NAME" ] || [ -z "$DOCKER_HUB_PASSWD" ]; then
    echo -e "${YELLOW}Warning: Docker Hub credentials not set${NC}"
    echo "To push the image, set these environment variables:"
    echo "  export DOCKER_HUB_NAME=your_username"
    echo "  export DOCKER_HUB_PASSWD=your_password"
    echo ""
    read -p "Continue with local build only? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    PUSH_IMAGE=false
else
    PUSH_IMAGE=true
fi

echo "Building Full-Stack Web Runtime image..."

# Try different build methods based on availability
if command -v docker &> /dev/null; then
    echo "Using Docker to build image..."
    docker build -t "$FULL_IMAGE_NAME" .

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Build successful!${NC}"
        if [ "$PUSH_IMAGE" = true ]; then
            echo "Logging in to Docker Hub..."
            echo "$DOCKER_HUB_PASSWD" | docker login -u "$DOCKER_HUB_NAME" --password-stdin

            echo "Pushing image to Docker Hub..."
            docker push "$FULL_IMAGE_NAME"
            echo -e "${GREEN}Image pushed successfully to Docker Hub!${NC}"
        fi
    else
        echo -e "${RED}Build failed with Docker${NC}"
        exit 1
    fi

elif command -v buildah &> /dev/null; then
    echo "Using Buildah to build image..."

    # Try with different storage drivers
    if buildah bud -t "$FULL_IMAGE_NAME" .; then
        echo "Build successful with default driver!"
    elif buildah --storage-driver vfs bud -t "$FULL_IMAGE_NAME" .; then
        echo "Build successful with vfs driver!"
    else
        echo "Trying with sudo..."
        sudo buildah --storage-driver vfs bud -t "$FULL_IMAGE_NAME" .
    fi

    if [ $? -eq 0 ]; then
        echo "Build successful! Logging in to Docker Hub..."
        buildah login -u "$DOCKER_HUB_NAME" -p "$DOCKER_HUB_PASSWD" docker.io

        echo "Pushing image to Docker Hub..."
        buildah push "$FULL_IMAGE_NAME" "docker://${FULL_IMAGE_NAME}"
        echo "Image pushed successfully to Docker Hub!"
    else
        echo "Build failed with Buildah"
        exit 1
    fi

elif command -v podman &> /dev/null; then
    echo "Using Podman to build image..."
    podman build -t "$FULL_IMAGE_NAME" .

    if [ $? -eq 0 ]; then
        echo "Build successful! Logging in to Docker Hub..."
        echo "$DOCKER_HUB_PASSWD" | podman login -u "$DOCKER_HUB_NAME" --password-stdin docker.io

        echo "Pushing image to Docker Hub..."
        podman push "$FULL_IMAGE_NAME"
        echo "Image pushed successfully to Docker Hub!"
    else
        echo "Build failed with Podman"
        exit 1
    fi
else
    echo "Error: No container build tool found (docker, buildah, or podman)"
    echo "Please install one of these tools and try again"
    exit 1
fi

echo "Build and push completed successfully!"
echo "Image available at: docker.io/${FULL_IMAGE_NAME}"