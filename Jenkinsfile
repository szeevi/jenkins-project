pipeline {
    agent any
    
    environment {
        // ג'נקינס יודע לקחת את ה-Username וה-Password מה-ID האחד שנתת
        AWS_CREDS = credentials('aws-credentials-global')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            environment {
                // הזרקת המפתחות למשתנים שטרפורם מזהה
                AWS_ACCESS_KEY_ID     = "${AWS_CREDS_USR}"
                AWS_SECRET_ACCESS_KEY = "${AWS_CREDS_PSW}"
            }
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Apply') {
            environment {
                AWS_ACCESS_KEY_ID     = "${AWS_CREDS_USR}"
                AWS_SECRET_ACCESS_KEY = "${AWS_CREDS_PSW}"
            }
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
    }
    
    post {
        failure {
            echo 'Deployment failed. Please check if the Credentials ID matches in Jenkins.'
        }
    }
}
