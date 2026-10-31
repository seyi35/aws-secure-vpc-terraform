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


# --------------------------------------------------
# TOOPLATE WEBSITE DEPLOYMENT
# --------------------------------------------------

# Terraform inserts the template download URL here.
TOOPLATE_URL="${tooplate_url}"

# Create temporary workspace.
WORK_DIR="$(mktemp -d)"

# Download the ZIP archive.
# -f fails on HTTP errors; -L follows redirects.
curl -fL --retry 3 \
  "$TOOPLATE_URL" \
  -o "$WORK_DIR/tooplate.zip"

# Verify the archive is a valid ZIP before extracting.
unzip -tq "$WORK_DIR/tooplate.zip"

# Extract the website.
unzip -q "$WORK_DIR/tooplate.zip" -d "$WORK_DIR/site"

# Find index.html even if the ZIP contains a parent folder.
SITE_INDEX="$(find "$WORK_DIR/site" -type f -name index.html -print -quit)"

if [[ -z "$SITE_INDEX" ]]; then
  echo "ERROR: No index.html found in template archive"
  exit 1
fi

SITE_ROOT="$(dirname "$SITE_INDEX")"

# Replace the temporary homepage with the Tooplate site.
rm -f /var/www/html/index.html
cp -a "$SITE_ROOT"/. /var/www/html/

# Preserve the ALB health endpoint independently of the site.
echo "healthy" > /var/www/html/health

# Set ownership and restart Apache.
chown -R www-data:www-data /var/www/html
systemctl restart apache2

# Remove temporary installation files.
rm -rf "$WORK_DIR"

echo "Tooplate website deployed successfully on $WEB_NAME"
