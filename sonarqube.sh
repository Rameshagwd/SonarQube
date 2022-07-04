#!/bin/bash

echo "Installing SonarQube Dependences"
yum install wget unzip java -yum

echo "Downloading Mysql Package"
wget https://repo.mysql.com/yum/mysql-connectors-community/el/7/x86_64/mysql-community-release-el7-5.noarch.rpm