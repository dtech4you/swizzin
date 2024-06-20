#!/bin/bash

# Variables
OMBI_DIR="/opt/Ombi"
OMBI_SERVICE="ombi"
BACKUP_DIR="/opt/Ombi_Backup"

# Function to get the latest release URL
get_latest_release_url() {
  curl -s https://api.github.com/repos/Ombi-app/Ombi/releases/latest | grep "browser_download_url.*linux-x64.tar.gz" | cut -d '"' -f 4
}

# Check if the current user has root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Stop the Ombi service
echo "Stopping Ombi service..."
systemctl stop $OMBI_SERVICE

# Backup current Ombi installation
echo "Backing up current Ombi installation to $BACKUP_DIR..."
mkdir -p $BACKUP_DIR
cp -r $OMBI_DIR/* $BACKUP_DIR

# Download the latest Ombi release
OMBI_URL=$(get_latest_release_url)
echo "Downloading the latest Ombi release from $OMBI_URL..."
wget -O /tmp/Ombi-linux.tar.gz $OMBI_URL

# Extract the new version
echo "Extracting the new version..."
tar -xzf /tmp/Ombi-linux.tar.gz -C $OMBI_DIR

# Clean up
echo "Cleaning up..."
rm /tmp/Ombi-linux.tar.gz

# Ensure the correct permissions
echo "Setting permissions..."
chown -R ombi:ombi $OMBI_DIR

# Restart the Ombi service
echo "Restarting Ombi service..."
systemctl start $OMBI_SERVICE

echo "Ombi has been updated successfully!"
