#!/bin/bash

# ========================================================
# Swap setup
# ========================================================
echo "Setting up swap space..."

# Create swap file
sudo dd if=/dev/zero of=/swapfile bs=6144 count=6291456

# Set permissions
sudo chmod 600 /swapfile

# Make swap
sudo mkswap /swapfile

# Activate swap
sudo swapon /swapfile

# Add swap to fstab for persistence
echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab

# Verify swap setup
echo "Swap setup complete. Verifying..."
sudo free -h

# ========================================================
# Cache setup
# ========================================================
echo "Setting up cache..."

# Add to .bashrc
echo "export USE_CCACHE=1" >> ~/.bashrc

# Source .bashrc to apply changes
source ~/.bashrc

# Set ccache size to 40GB
ccache -M 40G

# ========================================================
# Git setup
# ========================================================
echo "Setting up Git..."

# Configure Git credentials and user information
git config --global credential.helper store
git config --global color.ui true
git config --global user.name "skwel"
git config --global user.email "abalverde1694@gmail.com"

# ========================================================
# Build script setup
# ========================================================
echo "Setting up build environment..."

# Clone the build script repository and run the setup script
git clone http://github.com/akhilnarang/scripts tools && bash tools/setup/android_build_env.sh

echo "Setup completed successfully!"
