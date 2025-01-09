#!/bin/bash
set -e

# Step 1: Uninstall conflicting packages
echo "Removing any conflicting Docker packages..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg || true
done

# Step 2: Update system and install dependencies
echo "Updating system and installing required dependencies..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl apt-transport-https software-properties-common

# Step 3: Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Step 4: Add Docker's repository
echo "Adding Docker's repository to apt sources..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Step 5: Update package index and install Docker
echo "Installing Docker..."
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Step 6: Verify Docker installation
echo "Verifying Docker installation by running hello-world container..."
sudo docker run hello-world

# Step 7: Post-installation steps (optional)
echo "If you want non-root users to run Docker commands, execute the following manually:"
echo "  sudo groupadd docker"
echo "  sudo usermod -aG docker \$USER"
echo "Then log out and back in to apply the group changes."
