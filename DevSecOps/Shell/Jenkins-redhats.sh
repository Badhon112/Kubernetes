#!/bin/bash

set -e

echo "=== Jenkins Setup for Amazon Linux ==="

# Hostname
sudo hostnamectl set-hostname jenkins-controller

# Timezone
sudo timedatectl set-timezone Asia/Dhaka

# Update system
sudo yum update -y

# Install Java (Amazon Linux usually uses OpenJDK 17/21 available via amazon-linux-extras or dnf)
sudo yum install -y java-21-amazon-corretto

java -version

# Install required tools
# sudo yum install -y wget curl

# Add Jenkins repo
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install -y jenkins

# Start Jenkins
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Check status
sudo systemctl status jenkins --no-pager

echo "Jenkins installed successfully on Amazon Linux and the password is "

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

