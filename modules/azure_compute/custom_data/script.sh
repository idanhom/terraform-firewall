#!/bin/bash
set -e

# Step 1: Uninstall conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg || true
done

# Step 2: Update system and install dependencies
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl apt-transport-https software-properties-common needrestart

# Step 3: Configure needrestart for non-interactive service restarts
sudo bash -c "cat <<EOF > /etc/needrestart/needrestart.conf
\$nrconf{kernelhints} = 0;
\$nrconf{restart} = 'a';
\$nrconf{sendmail} = 0;
\$nrconf{notify} = 'none';
EOF"

# Step 4: Add Docker's official GPG key and apt repository
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  \$(. /etc/os-release && echo \"\$VERSION_CODENAME\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Step 5: Install Docker
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Step 6: Run needrestart to fix outdated daemons
sudo needrestart -r a

# Step 7: Create website files
mkdir -p /tmp/mywebsite
cat <<EOF > /tmp/mywebsite/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to My Website</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; text-align: center; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>Welcome to My Website!</h1>
    <p>This website is hosted on an Azure VM using Nginx and Terraform.</p>
</body>
</html>
EOF

# Step 8: Create a custom Docker image for Nginx with the website
cat <<EOF > /tmp/mywebsite/Dockerfile
FROM nginx:latest
COPY ./index.html /usr/share/nginx/html/index.html
EOF

sudo docker build -t mywebsite-nginx /tmp/mywebsite
sudo docker run --name nginx-container -d -p 80:80 mywebsite-nginx
