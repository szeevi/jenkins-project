pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        // שימוש בשיקוף קו נטוי כפול עבור הערות ב-Jenkinsfile
        ANSIBLE_HOST_KEY_CHECKING = 'False'
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
                    // חילוץ ה-IP ויצירת קובץ אינוונטורי
                    def instanceIp = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                    sh "echo '${instanceIp} ansible_user=ec2-user' > inventory.ini"
                    
                    // הרצת הפלייבוק. שים לב שייתכן ותצטרך להוסיף --private-key אם אין מפתח מוגדר ב-Agent
                    sh "ansible-playbook -i inventory.ini instance.yml"
                }
            }
        }
    }

    post {
        always {
            echo 'Finishing pipeline execution...'
        }
    }
}
