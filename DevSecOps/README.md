# Complete DevSecOps CI/CD Pipeline | Multi-AZ Amazon EKS + Jenkins + Trivy + SonarQube + ECR + GitHub

## Introduction

- We will build an end to end production-grade DevSecOps pipeline that integrates secures coding, vulnerability scanning, container image hardening, artifact management, and automated Kubernetes deployment. The goal is to show secures CI/CD using a combination of.
  - Jenkins
  - SonarQube (SAST + coverage)
  - Trivy (SCA + image scanning)
  - AWS ECR
  - Amazon EKS
  - Kubernetes YAML manifests
  - IAM + RBAC for least-privilege deployments

## Lab: Install Jenkins Controller on EC2

- Setup the ec2(Ubuntu) with the Security Group for
  - Allow SSH (22)
  - Allow HTTP (8080) for (Jenkins)
- After Create the EC2 Ubuntu we need to install jenkins and java. Here are the script file

```bash
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

echo "Jenkins Password Is"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

- Access Jenkins UI and unlock

- Open in browser:

```bash
http://<jenkins-controller-public-ip>:8080
```

Get admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

## Lab: Configure SSH-based Jenkins Agent on EC2

This VM will execute all Jenkins jobs. It will have JDK 21, Docker, and a non-root jenkins user.

- Setup the ec2 with the Security Group for
  - Allow SSH (22)
  - 30 gb storage for trivy
- Set hostname, timezone, Install Java 21, Create a dedicated jenkins user (non-root):

```bash
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
```

---

## Lab: Add the jenkins-agent to the Jenkins Controller

1. Generate SSH key on the controller (Jenkins user)
   - Jenkins service runs as jenkins, so we generate the key inside its home.
   - Use a meaningful filename and a different comment:

```bash
# You land in the home directory of jenkins user which is /var/lib/jenkins
sudo su - jenkins

ssh-keygen -t ed25519 -f /var/lib/jenkins/.ssh/jenkins-agent-key -C "jenkins-agent-access"

# Show the public Key
cat /var/lib/jenkins/.ssh/jenkins-agent-key.pub
```

2. Copy the public key to the agent

- On the controller (as jenkins), print the pubkey and copy it

```bash
sudo su - jenkins

# Copy this jenkins-agent-key
cat ~/.ssh/jenkins-agent-key.pub
```

3. On the agent (SSH session already open), switch to jenkins user

```bash
sudo su - jenkins
mkdir -p ~/.ssh
vim ~/.ssh/authorized_keys
```

- Paste the public key inside that you copy from the jenkins controllers, save and exit.
- Set permissions (now that you’re already jenkins user)

```bash
chmod 600 ~/.ssh/authorized_keys
```

- From the controller, test the connection

```bash
# switch to jenkins (loads jenkins HOME)
sudo su - jenkins

# test SSH using the private key from jenkins home
# ssh -i /var/lib/jenkins/.ssh/jenkins-agent-key jenkins@<jenkins-agent-public-ip> hostname
# ssh -i /var/lib/jenkins/.ssh/jenkins-agent-key jenkins@<jenkins-agent-private-ip> hostname
ssh -i /var/lib/jenkins/.ssh/jenkins-agent-key jenkins@172.31.2.17 hostname

```

---

## Configure the agent in Jenkins UI

1. Jenkins Dashboard -> Managed Jenkins -> Nodes -> New Node
2. Name Jenkins-agent
3. Type: Permanent Agent
4. Configure:
   - Number of executors: 1 (or as needed)
   - Remote root directory: /home/jenkins ← ensure this matches the agent's jenkins home.
   - Labels: docker-maven-trivy
   - Usage: Use this node as much as possible
   - Launch method: Launch agents via SSH
5. Enter connection details:
   - Host: <jenkins-agent-PRIVATE-ip>
   - Credentials: Add → SSH Username with private key
     - Username: jenkins
     - Private key: paste the private key contents from /var/lib/jenkins/.ssh/jenkins-agent-key (the file on the controller).
     - Passphrase: leave empty unless you set one.

## Lab: Install SonarQube on EC2

- To install SonarQube, We will use docker and docker compose file. To install docker and docker compose.

```bash
#!/bin/bash

set -e

echo "🚀 Updating system..."
sudo yum update -y

echo "🐳 Installing Docker..."
sudo yum install docker -y

echo "▶ Starting Docker..."
sudo systemctl start docker
sudo systemctl enable docker

echo "👤 Adding user to docker group..."
sudo usermod -aG docker $USER

# Apply group immediately (works in scripts too)
newgrp docker <<EOF

echo "✅ Docker version:"
docker --version

echo "📦 Installing Docker Compose plugin..."
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o $DOCKER_CONFIG/cli-plugins/docker-compose

chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

echo "✅ Docker Compose version:"
docker compose version

echo "🔧 Installing Docker Buildx plugin (stable version)..."
mkdir -p ~/.docker/cli-plugins

curl -L https://github.com/docker/buildx/releases/download/v0.29.0/buildx-v0.29.0.linux-amd64 \
  -o ~/.docker/cli-plugins/docker-buildx

chmod +x ~/.docker/cli-plugins/docker-buildx

echo "✅ Buildx version:"
docker buildx version

EOF

echo "🎉 Installation complete!"

```

- Run this Command

```bash
$ sh ./docker.sh

```

- And then implement docker compose file

```bash
version: "3"

services:
  sonarqube:
    image: sonarqube:lts-community
    depends_on:
      - sonar_db
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://sonar_db:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
    ports:
      - "9001:9000"
    volumes:
      - sonarqube_conf:/opt/sonarqube/conf
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_temp:/opt/sonarqube/temp

  sonar_db:
    image: postgres:13
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
      POSTGRES_DB: sonar
    volumes:
      - sonar_db:/var/lib/postgresql
      - sonar_db_data:/var/lib/postgresql/data

volumes:
  sonarqube_conf:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  sonarqube_temp:
  sonar_db:
  sonar_db_data:

```

```bash
$ docker compose up -d
```

--

- Or

```bash
$ docker run --name sonarqube-custom -p 9000:9000 sonarqube:community
```
