#!/bin/bash

# Update and upgrage packages
echo "================================="
echo "Updating dependencies"
echo "================================="
sudo apt update -y

# Installing Java 11
echo "================================="
echo "Installing Java 11"
echo "================================="
sudo apt install openjdk-11-jdk -y

# Install Jenkins
echo "================================="
echo "Installing Jenkins"
echo "================================="
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add a Jenkins apt repository entry:
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install fontconfig -y
sudo apt install jenkins -y

echo "================================="
echo "Starting Jenkins Agent"
echo "================================="
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install caddy
echo "================================="
echo "Installing Caddy"
echo "================================="
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update -y
sudo apt install caddy -y

sudo sed -i 's/# reverse_proxy localhost:8080/reverse_proxy localhost:8080/g' /etc/caddy/Caddyfile

echo "================================="
echo "Starting Caddy"
echo "================================="
sudo systemctl start caddy
sudo systemctl enable caddy

# Installing Docker
echo "================================="
echo "Installing Docker"
echo "================================="
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins

echo "================================="
echo "Restarting Jenkins"
echo "================================="
sudo systemctl enable jenkins
sudo systemctl restart jenkins