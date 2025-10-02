#!/bin/bash

# Build script for Full-Stack Web Runtime Docker Image
# This script should be run in an environment with proper Docker or Buildah permissions

# Set variables
IMAGE_NAME="fullstackagent/fullstack-web-runtime"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Check for Docker Hub credentials in environment
if [ -z "$DOCKER_HUB_NAME" ] || [ -z "$DOCKER_HUB_PASSWD" ]; then
    echo "Error: DOCKER_HUB_NAME and DOCKER_HUB_PASSWD environment variables must be set"
    echo "Export them before running this script:"
    echo "  export DOCKER_HUB_NAME=your_username"
    echo "  export DOCKER_HUB_PASSWD=your_password"
    exit 1
fi

echo "Building Full-Stack Web Runtime image..."

# Try different build methods based on availability
if command -v docker &> /dev/null; then
    echo "Using Docker to build image..."
    docker build -t "$FULL_IMAGE_NAME" .

    if [ $? -eq 0 ]; then
        echo "Build successful! Logging in to Docker Hub..."
        echo "$DOCKER_HUB_PASSWD" | docker login -u "$DOCKER_HUB_NAME" --password-stdin

        echo "Pushing image to Docker Hub..."
        docker push "$FULL_IMAGE_NAME"
        echo "Image pushed successfully to Docker Hub!"
    else
        echo "Build failed with Docker"
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