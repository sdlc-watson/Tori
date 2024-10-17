# Exit on any error
$ErrorActionPreference = "Stop"

# Check if IBM Cloud CLI is installed
if (-not (Get-Command ibmcloud -ErrorAction SilentlyContinue)) {
    Write-Host "IBM Cloud CLI is not installed. Installing IBM Cloud CLI..."
    
    # Download IBM Cloud CLI installer for Windows
    Invoke-WebRequest -UseBasicParsing "https://clis.cloud.ibm.com/download/bluemix-cli/latest/win64" -OutFile "$env:TEMP\IBMCloudCLIInstaller.exe"
    
    # Run the installer silently
    Start-Process -FilePath "$env:TEMP\IBMCloudCLIInstaller.exe" -ArgumentList "/quiet" -Wait
    
    # Remove the installer
    Remove-Item "$env:TEMP\IBMCloudCLIInstaller.exe"
    
    Write-Host "IBM Cloud CLI installation completed."
} else {
    Write-Host "IBM Cloud CLI is already installed."
}

# IBM Cloud login - Single Sign-On (SSO)
Write-Host "Logging into IBM Cloud..."
ibmcloud login --sso

# Check if the login was successful
if ($LASTEXITCODE -ne 0) {
    Write-Host "IBM Cloud login failed. Exiting script."
    exit 1
}

Write-Host "IBM Cloud login successful."

# Log into IBM Container Registry with Docker
Write-Host "Logging into IBM Cloud Container Registry..."
ibmcloud cr login --client docker

# Check if Docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not installed. Installing Docker..."
    Invoke-WebRequest -UseBasicParsing "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -OutFile "$env:TEMP\DockerInstaller.exe"
    Start-Process -FilePath "$env:TEMP\DockerInstaller.exe" -ArgumentList "/S" -Wait
    Remove-Item "$env:TEMP\DockerInstaller.exe"
    Write-Host "Docker installation completed. Please restart your computer and re-run this script."
    exit
} else {
    Write-Host "Docker is already installed."
}

# Check if Docker Compose is installed
if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Compose is not installed. Installing Docker Compose..."
    $COMPOSE_VERSION = (Invoke-RestMethod -Uri "https://api.github.com/repos/docker/compose/releases/latest").tag_name
    $URL = "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-Windows-x86_64.exe"
    Invoke-WebRequest -Uri $URL -OutFile "$env:ProgramFiles\Docker\docker-compose.exe" -UseBasicParsing
    Write-Host "Docker Compose installation completed."
} else {
    Write-Host "Docker Compose is already installed."
}

# Create a virtual environment in the 'venv' directory
python -m venv venv

# Activate the virtual environment
& ./venv/Scripts/Activate.ps1

# Install required packages inside the virtual environment
pip install --upgrade pip  # Upgrade pip to the latest version
pip install python-dotenv

# Stop and remove Docker containers
docker-compose down

docker-compose pull

# Run Docker Compose
docker-compose up -d
