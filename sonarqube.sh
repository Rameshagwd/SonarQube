#!/bin/bash
LOG=/tmp/stack.log 

echo "Installing SonarQube Dependences"
yum install wget unzip java -y &>>LOG

echo "Downloading Mysql Package"
cd /tmp
wget https://repo.mysql.com/yum/mysql-connectors-community/el/7/x86_64/mysql-community-release-el7-5.noarch.rpm &>>LOG

echo "Installing Mysql"
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum install mysql-server -y

echo "Starting Mysql Service"
systemctl start mysqld

echo "Updating Mysql Config"
echo "CREATE DATABASE sonarqube_db;
CREATE USER 'sonarqube_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON sonarqube_db.* TO 'sonarqube_user'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;" > /tmp/sonar.sql
mysql < /tmp/sonar.sql

echo "Creating User for SonarQube DB"
useradd -m sonarqube -p sonar@123

echo "Downloading SonarQube Package"
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-6.7.6.zip &>>LOG
