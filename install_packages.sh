#!/bin/bash

# Script to automate the installation of Git, Node.js, Docker, and other useful utilities

# Update the system
echo "Updating the system..."
sudo apt update -y && sudo apt upgrade -y

# Install common utilities
echo "Installing common utilities (curl, wget, vim, build-essential)..."
sudo apt install -y curl wget vim build-essential

# 1. Install Git
echo "Installing Git..."
sudo apt install -y git

# Verify Git installation
if command -v git &>/dev/null; then
    echo "Git installation successful."
else
    echo "Git installation failed."
    exit 1
fi

# 2. Install Node.js (using NodeSource repository)
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - # You can change version as needed
sudo apt install -y nodejs

# Verify Node.js installation
if command -v node &>/dev/null && command -v npm &>/dev/null; then
    echo "Node.js installation successful."
else
    echo "Node.js installation failed."
    exit 1
fi

# 3. Install Docker
echo "Installing Docker..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up Docker's stable repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update apt package index again
sudo apt update -y

# Install Docker CE (Community Edition)
sudo apt install -y docker-ce

# Start Docker and enable it to run at boot
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
if command -v docker &>/dev/null; then
    echo "Docker installation successful."
else
    echo "Docker installation failed."
    exit 1
fi

# 4. Install Docker Compose (for managing multi-container Docker applications)
echo "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
if command -v docker-compose &>/dev/null; then
    echo "Docker Compose installation successful."
else
    echo "Docker Compose installation failed."
    exit 1
fi

# 5. Install additional useful utilities (e.g., unzip, tree)
echo "Installing additional utilities (unzip, tree)..."
sudo apt install -y unzip tree

# Final message
echo "Package installation completed successfully."

# Optional: Reboot the system (if needed)
# sudo reboot
