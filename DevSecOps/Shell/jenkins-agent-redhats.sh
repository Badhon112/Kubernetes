#!/bin/bash

set -e

echo "=== Jenkins Agent Setup (RHEL-based) ==="

# Hostname
sudo hostnamectl set-hostname jenkins-agent

# Timezone
sudo timedatectl set-timezone Asia/Dhaka

timedatectl status

# Update system
sudo dnf update -y || sudo yum update -y

# Install Java
echo "Installing Java..."
# sudo dnf install -y java-21-openjdk || sudo yum install -y java-21-openjdk
sudo dnf install -y java-21-amazon-corretto
sudo dnf install -y java-21-amazon-corretto-devel

java -version
javac -version

# Create Jenkins user
echo "Creating Jenkins user..."
if id "jenkins" &>/dev/null; then
    echo "User 'jenkins' already exists."
else
    sudo useradd -m -s /bin/bash jenkins
    echo "User 'jenkins' created successfully."
fi

echo "Jenkins agent setup completed successfully."