pipeline {
    agent any
    
    environment {
        // כאן אנחנו מניחים ששינית את ה-ID ב-Jenkins ל-aws-credentials-global
        AWS_CREDS = credentials('aws-credentials-global')
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
                // שימוש במשתנים שנוצרים אוטומטית מה-credentials
                withEnv(["AWS_ACCESS_KEY_ID=${AWS_CREDS_USR}", "AWS_SECRET_ACCESS_KEY=${AWS_CREDS_PSW}", "AWS_DEFAULT_REGION=us-east-1"]) {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
    
    post {
        always {
            echo 'Finishing pipeline...'
        }
    }
}
