#!/bin/bash

# ========================================================
# Generate RSA SSH key for GitHub
# ========================================================
echo "Generating RSA SSH key for GitHub..."

# Set key file path
KEY_PATH="$HOME/.ssh/github_rsa"

# Check if SSH key already exists, prompt for overwrite if so
if [ -f "$KEY_PATH" ]; then
    echo "Key already exists at $KEY_PATH. Do you want to overwrite it? (y/n)"
    read -r response
    if [[ "$response" != "y" ]]; then
        echo "Exiting without overwriting the key."
        exit 1
    fi
fi

# Generate the RSA key
ssh-keygen -t rsa -b 4096 -C "abalverde1694@gmail.com" -f "$KEY_PATH" -N ""

# Add the SSH key to the SSH agent
echo "Adding the SSH key to the agent..."
eval "$(ssh-agent -s)"
ssh-add "$KEY_PATH"

# Display the public key and guide user to copy it
echo "SSH key generated successfully!"
echo "Now, copy the public key to your clipboard and add it to your GitHub account."
echo "You can view the public key by running:"
echo "cat $KEY_PATH.pub"
echo "You can add the key to GitHub via: https://github.com/settings/keys"

# Optional: Open the key in a text editor (uncomment to enable)
# cat "$KEY_PATH.pub"

# End
echo "Setup complete!"
