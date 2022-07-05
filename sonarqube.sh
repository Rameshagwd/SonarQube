#!/bin/bash
LOG=/tmp/stack.log 

echo "Installing SonarQube Dependences"
yum install wget unzip java -y &>>$LOG

echo "Downloading Mysql Package"
cd /tmp
wget https://repo.mysql.com/yum/mysql-connectors-community/el/7/x86_64/mysql-community-release-el7-5.noarch.rpm &>>LOG

echo "Installing Mysql"
rpm -ivh mysql-community-release-el7-5.noarch.rpm &>>$LOG
yum install mysql-server -y &>>$LOG

echo "Starting Mysql Service"
systemctl start mysqld &>>$LOG

echo "Updating Mysql Config"
echo "CREATE DATABASE sonarqube_db;
CREATE USER 'sonarqube_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON sonarqube_db.* TO 'sonarqube_user'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;" > /tmp/sonar.sql
mysql < /tmp/sonar.sql &>>$LOG

echo "Creating User for SonarQube DB"
useradd -m -p sonar@123 sonarqube &>>$LOG

echo "Downloading SonarQube Package"
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-6.7.6.zip &>>$LOG
unzip sonarqube-6.7.6.zip &>>$LOG
mv sonarqube-6.7.6 /opt/sonarqube
chown -R sonarqube. /opt/sonarqube

echo "Updating SonarQube DB Details"
echo 'sonar.jdbc.username=sonarqube_user
sonar.jdbc.password=password
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonarqube_db?useUnicode=true&amp;characterEncoding=utf8&amp;rewriteBatchedStatements=true&amp;useConfigs=maxPerformance' >> /opt/sonarqube/conf/sonar.properties