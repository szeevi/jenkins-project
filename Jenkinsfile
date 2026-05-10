pipeline {
    agent any
    
    environment {
        // ג'נקינס יזריק את המפתחות למשתני הסביבה שטרפורם מחפש
        AWS_ACCESS_KEY_ID     = credentials('aws-creds-id') // ה-ID שנתת ב-Jenkins
        AWS_SECRET_ACCESS_KEY = credentials('aws-creds-secret')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        // ... שאר השלבים
    }
    
    post {
        always {
            echo 'Cleaning up workspace...'
            deleteDir()
        }
    }
}
