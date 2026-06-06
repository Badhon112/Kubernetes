#!/bin/bash

set -e

echo "Setting hostname..."
sudo hostnamectl set-hostname jenkins-controller

echo "Setting timezone..."
sudo timedatectl set-timezone Asia/Dhaka
timedatectl status

echo "Updating packages..."
sudo apt update

echo "Installing Java 21..."
sudo apt install -y openjdk-21-jdk

java -version
javac -version

echo "Adding Jenkins repository key..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "Adding Jenkins repository..."
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Installing Jenkins..."
sudo apt update
sudo apt install -y jenkins

echo "Configuring Jenkins timezone..."
sudo mkdir -p /etc/systemd/system/jenkins.service.d

cat <<EOF | sudo tee /etc/systemd/system/jenkins.service.d/override.conf > /dev/null
[Service]
Environment="JAVA_OPTS=-Duser.timezone=Asia/Dhaka"
EOF

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Enabling and starting Jenkins..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Jenkins status:"
sudo systemctl status jenkins --no-pager

echo "Jenkins installation completed successfully."