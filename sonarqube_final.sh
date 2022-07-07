#!/bin/bash
ID=$(id -u)
LOG=/tmp/stack.log
MYSQL_PKG=https://repo.mysql.com/yum/mysql-connectors-community/el/7/x86_64/mysql-community-release-el7-5.noarch.rpm
MYSQL_RPM=$(echo $MYSQL_PKG | cut -d/ -f9)
SQ_PKG=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-6.7.6.zip
SQ_ZIP=$(echo $SQ_PKG awk -F / '{print $NF}')

G='\033[0;92m'
R='\033[0;91m'
Y='\033[0;93m'

if [ $ID -ne 0 ]; then
    echo -e " $G You do not have the admin privileges to run this script file.......!$R"
    exit 1
else
    echo -e " $G Running the script file with admin privileges.......!$R"
fi
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo "$2 ... FAILED"
        exit 1
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


if [ -f /tmp/$SQ_PKG ]; then
    
    echo "The SQ file was downloaded"
        else
            cd /tmp/    
            wget $SQ_PKG -O /tmp/$SQ_ZIP &>>$LOG
            unzip /tmp/$SQ_ZIP &>>$LOG
            mv sonarqube-6.7.6 /opt/sonarqube
            chown -R sonarqube. /opt/sonarqube
            VALIDATE $? "Downloading/Extracting/Installing SonarQube Package"

            echo 'sonar.jdbc.username=sonarqube_user
            sonar.jdbc.password=password
            sonar.jdbc.url=jdbc:mysql://localhost:3306/sonarqube_db?useUnicode=true&amp;characterEncoding=utf8&amp;rewriteBatchedStatements=true&amp;useConfigs=maxPerformance' >> /opt/sonarqube/conf/sonar.properties
            VALIDATE $? "Updating SonarQube DB Details"
fi
sed -i 's/#RUN_AS_USER=/RUN_AS_USER=sonarqube/g' /opt/sonarqube/bin/linux-x86-64/sonar.sh
VALIDATE $? "Updating SonarQube user into the DB Configuation"

sh /opt/sonarqube/bin/linux-x86-64/sonar.sh start

