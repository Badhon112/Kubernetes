#!/bin/bash

set -e

echo "🚀 Updating system..."
sudo yum update -y

echo "🐳 Installing Docker..."
sudo yum install docker -y

echo "▶ Starting Docker..."
sudo systemctl start docker
sudo systemctl enable docker

echo "👤 Adding user to docker group..."
sudo usermod -aG docker $USER

# Apply group immediately (works in scripts too)
newgrp docker <<EOF

echo "✅ Docker version:"
docker --version

echo "📦 Installing Docker Compose plugin..."
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o $DOCKER_CONFIG/cli-plugins/docker-compose

chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

echo "✅ Docker Compose version:"
docker compose version

echo "🔧 Installing Docker Buildx plugin (stable version)..."
mkdir -p ~/.docker/cli-plugins

curl -L https://github.com/docker/buildx/releases/download/v0.29.0/buildx-v0.29.0.linux-amd64 \
  -o ~/.docker/cli-plugins/docker-buildx

chmod +x ~/.docker/cli-plugins/docker-buildx

echo "✅ Buildx version:"
docker buildx version

EOF

echo "🎉 Installation complete!"


