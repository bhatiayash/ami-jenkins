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

# Jenkins Configuration
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                          CONFIGURE JENKINS                                                              |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Install Jenkins plugin manager tool:
wget --quiet \
  https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar

# Install plugins with jenkins-plugin-manager tool:
sudo java -jar ./jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins --plugin-file plugins.txt

# Update users and group permissions to `jenkins` for all installed plugins:
cd /var/lib/jenkins/plugins/ || exit
sudo chown jenkins:jenkins ./*

# Move Jenkins files to Jenkins home
cd /home/ubuntu/ || exit
sudo mv configs.tgz /var/lib/jenkins/

# Update file ownership
cd /var/lib/jenkins/ || exit
sudo tar -xzvf configs.tgz
sudo chown jenkins:jenkins jcasc.yaml ./*.groovy

# Configure JAVA_OPTS to disable setup wizard
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
{
  echo "[Service]"
  echo "Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/jcasc.yaml\""
} | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

echo "Restarting Jenkins service with JCasC..."
sudo systemctl daemon-reload
sudo systemctl stop jenkins
sudo systemctl start jenkins


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