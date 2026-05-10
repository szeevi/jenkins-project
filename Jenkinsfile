pipeline {
    agent any

    environment {
        // הגדרת האזור כברירת מחדל
        AWS_DEFAULT_REGION = 'us-east-1'
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
                // שימוש בבלוק המאובטח להזרקת המפתחות (אחרי שעדכנת אותם ב-Jenkins)
                withCredentials([usernamePassword(credentialsId: 'aws-credentials-global', 
                                                 passwordVariable: 'AWS_SECRET_ACCESS_KEY', 
                                                 usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    // 1. חילוץ ה-IP של השרת החדש מטרפורם (בהנחה שהגדרת output "instance_ip" ב-TF)
                    // אם לא הגדרת output, תוכל להשתמש בנתיב הישיר לקובץ ה-inventory שלך
                    sh 'terraform output -raw instance_ip > instance_ip.txt'
                    
                    // 2. הרצת הפלייבוק
                    // הערה: וודא שיש ל-Jenkins מפתח SSH (Private Key) כדי להתחבר לשרת ה-EC2
                    sh 'ansible-playbook -i instance_ip.txt instance.yml'
                }
            }
        }
    }

    post {
        always {
            echo 'Finishing pipeline execution...'
        }
        success {
            echo 'Infrastructure deployed and configured successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the AWS credentials or Terraform/Ansible logs.'
        }
    }
}
