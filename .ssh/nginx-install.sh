#!/bin/bash
# Update package index and install Nginx
apt-get update -y
apt-get install -y nginx

# Enable and start Nginx service
systemctl enable nginx
systemctl start nginx

# Create a directory for the website
mkdir -p /var/www/html/mywebsite

# Add a simple index.html file for the website
cat <<EOF > /var/www/html/mywebsite/index.html
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

# Set permissions for the web content
chown -R www-data:www-data /var/www/html/mywebsite

# Update Nginx default configuration to serve the website
cat <<EOF > /etc/nginx/sites-available/mywebsite
server {
    listen 80;
    server_name localhost;

    root /var/www/html/mywebsite;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Enable the website configuration
ln -s /etc/nginx/sites-available/mywebsite /etc/nginx/sites-enabled/

# Remove the default Nginx configuration
rm /etc/nginx/sites-enabled/default

# Reload Nginx to apply changes
systemctl reload nginx
