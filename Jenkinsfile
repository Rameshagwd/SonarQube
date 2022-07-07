pipeline {
    agent any
    stages {
        stage ('Git Clone') {
            steps {
               git branch: 'main', url: 'https://github.com/Rameshagwd/SonarQube.git' 
            }
        }
        stage ('Remote Copy') {
            steps {
                sh 'sshpass -p "sonar@123" scp -r /var/lib/jenkins/workspace/SonarQube_Pipeline/sonarqube_final.sh sonar@10.32.39.109:/tmp'
            }
        }
        stage ('Set the permission') {
            steps {
                sh 'ssh -t sonar@10.32.39.109 "chmod -R 755 /tmp/sonarqube_final.sh"'
            }
        }
        stage ('Execute the Sonar Qube Script') {
            steps {
                sh 'ssh -t sonar@10.32.39.109 "echo "sonar@123" | sudo -S sh /tmp/sonarqube_final.sh"'
            }
        }
              
    }
}