#!/bin/bash

# Exit on any error and treat unset variables as an error
set -eu

# Check if IBM Cloud CLI is installed
if ! command -v ibmcloud &> /dev/null
then
    echo "IBM Cloud CLI is not installed. Installing IBM Cloud CLI..."
    
    # Download and install IBM Cloud CLI
    curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
    
    echo "IBM Cloud CLI installation completed."
else
    echo "IBM Cloud CLI is already installed."
fi

# IBM Cloud login - Single Sign-On (SSO)
echo "Logging into IBM Cloud..."
ibmcloud login --sso

# Check if the login was successful
if [ $? -ne 0 ]; then
    echo "IBM Cloud login failed. Exiting script."
    exit 1
fi

echo "IBM Cloud login successful."

# Log into IBM Container Registry with Docker
echo "Logging into IBM Cloud Container Registry..."
ibmcloud cr login

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Installing Docker..."
    
    # Install Docker based on the OS type (Linux/macOS)
    if [ "$(uname)" == "Linux" ]; then
        # On Linux systems (Debian/Ubuntu)
        sudo apt-get update
        sudo apt-get install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker
    elif [ "$(uname)" == "Darwin" ]; then
        # On macOS
        brew install --cask docker
        open /Applications/Docker.app
        echo "Please ensure Docker is running on macOS."
    fi
else
    echo "Docker is already installed."
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    
    # Install Docker Compose
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    sudo curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    echo "Docker Compose installation completed."
else
    echo "Docker Compose is already installed."
fi

# Create a virtual environment in the 'venv' directory
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install required packages inside the virtual environment
pip install --upgrade pip  # Upgrade pip to the latest version
pip install python-dotenv

# Deactivate the virtual environment (optional)
deactivate

# Stop and remove Docker containers
docker-compose down

docker-compose pull

# Run Docker Compose
docker-compose up -d
