#!/bin/bash
set -e

CONTAINER_NAME="audio_suite_78_container"
IMAGE_NAME="audio_suite_78_image"
NETWORK_NAME="audio_suite_78_net"

echo "🧹 Removing old container (if exists)..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

echo "🧹 Removing old image (if exists)..."
docker rmi $IMAGE_NAME 2>/dev/null || true

echo "🔧 Creating Docker network (if missing)..."
docker network inspect $NETWORK_NAME >/dev/null 2>&1 || docker network create $NETWORK_NAME

echo "📦 Building new Docker image..."
docker build -t $IMAGE_NAME .

echo "🚀 Starting new container on port 5000..."
docker run -d \
  --name $CONTAINER_NAME \
  --network $NETWORK_NAME \
  -p 5000:5000 \
  $IMAGE_NAME

echo "✔ Container launched!"
echo "🌐 App available at: http://localhost:5000"

echo "📜 Showing last 10 container logs:"
docker logs --tail 10 $CONTAINER_NAME
