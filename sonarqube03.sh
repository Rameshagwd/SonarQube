#!/bin/bash
LOG=/tmp/stack.log
MYSQL_PKG=https://repo.mysql.com/yum/mysql-connectors-community/el/7/x86_64/mysql-community-release-el7-5.noarch.rpm
MYSQL_RPM=mysql-community-release-el7-5.noarch.rpm
SQ_PKG=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-6.7.6.zip
SQ_ZIP=sonarqube-6.7.6.zip

echo "Installing SonarQube Dependences"
yum install wget unzip java -y &>>$LOG

if [ $? -ne 0 ]; then
    echo "Installing SonarQube Dependences .........FAILED"
else
    echo "Installing SonarQube Dependences .........SUCCESS"
fi

if [ -f /tmp/$MYSQL_PKG ]; then
    echo "MYSQL Package was downloaded"
        else
            echo "Downloading Mysql Package"
            wget $MYSQL_PKG -O /tmp/$MYSQL_RPM &>>$LOG

            if [ $? -ne 0 ]; then
                echo "Downloading Mysql Package .........FAILED"
            else
                echo "Downloading Mysql Package .........SUCCESS"
            fi
fi

echo "Installing Mysql"
rpm -ivh /tmp/$MYSQL_RPM &>>$LOG
yum install mysql-server -y &>>$LOG

if [ $? -ne 0 ]; then
    echo "Installing Mysql .........FAILED"
else
    echo "Installing Mysql .........SUCCESS"
fi

echo "Starting Mysql Service"
systemctl start mysqld &>>$LOG

if [ $? -ne 0 ]; then
    echo "Starting Mysql Service .........FAILED"
else
    echo "Starting Mysql Service .........SUCCESS"
fi

if [ -f /tmp/sonar.sql ]; then
    echo "The Mysql Config was updated .........SUCCESS"
else
    echo "Updating Mysql Config"
        echo "CREATE DATABASE sonarqube_db;
        CREATE USER 'sonarqube_user'@'localhost' IDENTIFIED BY 'password';
        GRANT ALL PRIVILEGES ON sonarqube_db.* TO 'sonarqube_user'@'localhost' IDENTIFIED BY 'password';
        FLUSH PRIVILEGES;" > /tmp/sonar.sql
        mysql < /tmp/sonar.sql &>>$LOG

        if [ $? -ne 0 ]; then
                echo "Updating Mysql Config .........FAILED"
            else
                echo "Updating Mysql Config .........SUCCESS"
        fi
fi

egrep "sonarqube" /etc/passwd > /dev/null
if [ $? -eq 0 ]; then
    echo "The sonarqube DB user was created .........SUCCESS"
else
    echo "Creating User for SonarQube DB"
        useradd -m -p sonar@123 sonarqube &>>$LOG
        if [ $? -ne 0 ]; then
                echo "Creating User for SonarQube DBg .........FAILED"
            else
                echo "Creating User for SonarQube DBg .........SUCCESS"
        fi
fi

if [ -f /tmp/$MYSQL_RPM ]; then
    
            echo "The SQ file was downloaded"
    else
            echo "Downloading/Extracting/Installing SonarQube Package"
            wget $SQ_PKG -O /tmp/$SQ_ZIP &>>$LOG
            unzip /tmp/$SQ_ZIP &>>$LOG
            mv sonarqube-6.7.6 /opt/sonarqube
            chown -R sonarqube. /opt/sonarqube

            if [ $? -ne 0 ]; then
                echo "Downloading/Extracting/Installing SonarQube Package .........FAILED"
            else
                echo "Downloading/Extracting/Installing SonarQube Package .........SUCCESS"
            fi
fi

echo "Updating SonarQube DB Details"
echo 'sonar.jdbc.username=sonarqube_user
sonar.jdbc.password=password
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonarqube_db?useUnicode=true&amp;characterEncoding=utf8&amp;rewriteBatchedStatements=true&amp;useConfigs=maxPerformance' >> /opt/sonarqube/conf/sonar.properties

if [ $? -ne 0 ]; then
    echo "Updating SonarQube DB Details .........FAILED"
else
    echo "Updating SonarQube DB Details .........SUCCESS"
fi