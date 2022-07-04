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
                sh 'sshpass -p "sonar@123" scp -r /var/lib/jenkins/workspace/SonarQube_Pipeline/sonarqube.sh sonar@10.32.39.252:/tmp'
            }
        }
        stage ('Adding sudo') {
            steps {
                sh 'ssh sonar@10.32.39.252 export HISTIGNORE=*sudo -S*'
            }
        }

        stage ('Execute the Sonar Qube Script') {
            steps {
                sh 'ssh -t sonar@10.32.39.252 "echo <sonar@123> sudo sh /tmp/sonarqube.sh"'
            }
        }
              
    }
}