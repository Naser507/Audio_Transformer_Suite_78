#!/bin/bash

echo "⚡ Fast Docker rebuild (no toolchain reinstall)"

# Rebuild only changed layers
docker build --no-cache \
    --target runtime \
    -t audio_suite_78_image_fast .

echo "🔁 Restarting container..."

# Remove old container
docker rm -f audio_suite_78_container_fast 2>/dev/null

# Run new one
docker run -d \
    -p 7860:7860 \
    --name audio_suite_78_container_fast \
    audio_suite_78_image_fast

echo "🚀 Fast container running!"
