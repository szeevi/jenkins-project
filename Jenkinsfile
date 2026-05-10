pipeline {
    agent any
    
    environment {
        // וודא שה-ID כאן תואם למה שהגדרת ב-Jenkins!
        AWS_ACCESS_KEY_ID     = credentials('aws-creds-id') 
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
    }

    // ה-post נמצא כאן, והוא ירוץ בתוך ה-Context של ה-agent
    post {
        success {
            echo 'Infrastructure deployed successfully!'
        }
        failure {
            echo 'Deployment failed. Check the logs above.'
        }
    }
}
