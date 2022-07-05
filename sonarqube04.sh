#!/bin/bash
LOG=/tmp/stack.log
##### "This is applying Regular expression with cut command "#############
MYSQL_PKG=https://repo.mysql.com/yum/mysql-connectors-community/el/7/x86_64/mysql-community-release-el7-5.noarch.rpm
MYSQL_RPM=$(echo $MYSQL_PKG | cut -d/ -f9)

##### "This is applying Regular expression with awk Fragment "#############
SQ_PKG=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-6.7.6.zip
SQ_ZIP=$(echo $SQ_PKG awk -F / '{print $NF}')

VALIDATE() {
    if [ $1 -ne 0]; then
        echo "$2 ... FAILED"
    else
        echo "$2 ... SUCCESS"
    fi

}

yum install wget unzip java -y &>>$LOG
VALIDATE $? "Installing SonarQube Dependences"

if [ -f /tmp/$MYSQL_PKG ]; then
    echo "MYSQL Package was downloaded"
        else
            wget $MYSQL_PKG -O /tmp/$MYSQL_RPM &>>$LOG
            VALIDATE $? "Downloading Mysql Package"
fi

rpm -ivh /tmp/$MYSQL_RPM &>>$LOG
yum install mysql-server -y &>>$LOG
VALIDATE $? "Installing Mysql"

systemctl start mysqld &>>$LOG
VALIDATE $? "Starting Mysql Service"

if [ -f /tmp/sonar.sql ]; then
    echo "The Mysql Config was updated .........SUCCESS"
else
        echo "CREATE DATABASE sonarqube_db;
        CREATE USER 'sonarqube_user'@'localhost' IDENTIFIED BY 'password';
        GRANT ALL PRIVILEGES ON sonarqube_db.* TO 'sonarqube_user'@'localhost' IDENTIFIED BY 'password';
        FLUSH PRIVILEGES;" > /tmp/sonar.sql
        mysql < /tmp/sonar.sql &>>$LOG
        VALIDATE $? "Updating Mysql Config"
fi

egrep "sonarqube" /etc/passwd > /dev/null
if [ $? -eq 0 ]; then
    echo "The sonarqube DB user was created .........SUCCESS"
else
        useradd -m -p sonar@123 sonarqube &>>$LOG
        VALIDATE $? "Creating User for SonarQube DB"
fi

if [ -f /tmp/$MYSQL_RPM ]; then
    
            echo "The SQ file was downloaded"
    else
            wget $SQ_PKG -O /tmp/$SQ_ZIP &>>$LOG
            unzip /tmp/$SQ_ZIP &>>$LOG
            mv sonarqube-6.7.6 /opt/sonarqube
            chown -R sonarqube. /opt/sonarqube
            VALIDATE $? "Downloading/Extracting/Installing SonarQube Package"
fi

echo 'sonar.jdbc.username=sonarqube_user
sonar.jdbc.password=password
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonarqube_db?useUnicode=true&amp;characterEncoding=utf8&amp;rewriteBatchedStatements=true&amp;useConfigs=maxPerformance' >> /opt/sonarqube/conf/sonar.properties
VALIDATE $? "Updating SonarQube DB Details"
