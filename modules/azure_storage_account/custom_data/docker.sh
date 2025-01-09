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

# Step 6: Pull and Run the Nginx Container
echo "Pulling and running the Nginx container..."
sudo docker pull nginx:latest
sudo docker run --name nginx-container -d -p 80:80 nginx

# Step 7: Add a Custom HTML Template
echo "Creating and adding a custom HTML template..."
mkdir -p /tmp/mywebsite
cat <<EOF > /tmp/mywebsite/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to My Custom Website</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; text-align: center; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>Welcome to My Custom Website!</h1>
    <p>This is a custom HTML page served by Nginx running in a Docker container.</p>
</body>
</html>
EOF

# Copy the custom HTML into the Nginx container
echo "Copying the custom HTML into the Nginx container..."
sudo docker cp /tmp/mywebsite/index.html nginx-container:/usr/share/nginx/html/index.html

# Step 8: Verify Nginx is Running and Serving the Custom Page
echo "Verifying Nginx is running and serving the custom HTML page..."
if sudo docker ps | grep nginx; then
    echo "Nginx is running on port 80. Visit http://localhost to view the custom page."
else
    echo "Failed to start Nginx container."
fi
