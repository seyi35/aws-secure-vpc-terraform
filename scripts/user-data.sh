#!/bin/bash

# Exit if a command fails and log commands during setup.
set -euxo pipefail

# Terraform supplies a unique name for each web server.
WEB_NAME="${server_name}"

# Refresh Ubuntu package information.
apt-get update -y

# Install Apache web server, ZIP extraction and download tools.
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apache2 \
  unzip \
  curl

# Start Apache and configure it to start after reboot.
systemctl enable --now apache2

# Create a simple health-check endpoint for our future ALB.
echo "healthy" > /var/www/html/health

# Deploy a temporary test page identifying the web server.
# Our Tooplate website will replace this page later.
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>AWS Terraform VPC Project</title>
</head>
<body>
    <h1>Website is running!</h1>
    <p>Served by: $WEB_NAME</p>
    <p>Provisioned automatically using Terraform.</p>
</body>
</html>
EOF

# Log confirmation that initial configuration completed.
echo "Apache setup completed on $WEB_NAME"
