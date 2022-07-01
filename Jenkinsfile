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
                sh 'sshpass -p "sonar@123" scp -r /var/lib/jenkins/workspace/Shall_Script_Project/sonarqube.sh sonar@10.32.39.252:/tmp'
            }
        }
      
    }
}