#!/bin/bash

set -e

echo "Setting hostname..."
sudo hostnamectl set-hostname jenkins-agent

echo "Setting timezone..."
sudo timedatectl set-timezone Asia/Dhaka
timedatectl status

echo "Updating packages..."
sudo apt update

echo "Installing Java 21..."
sudo apt install -y openjdk-21-jdk

java -version
javac -version

echo "Creating Jenkins user..."
if id "jenkins" &>/dev/null; then
    echo "User 'jenkins' already exists."
else
    sudo useradd -m -s /bin/bash jenkins
    echo "User 'jenkins' created successfully."
fi

echo "Agent setup completed successfully."