pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        // אנחנו משתמשים בהגדרה מה-ansible.cfg שלך, אז אין צורך ב-ANSIBLE_HOST_KEY_CHECKING כאן
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
                    // 1. שליפת ה-IP מטרפורם
                    def instanceIp = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                    
                    // 2. יצירת קובץ אינוונטורי זמני (כי ה-ansible.cfg שלך מצפה ל-aws_ec2.yaml כברירת מחדל)
                    sh "echo '${instanceIp}' > host_to_provision.txt"
                    
                    // 3. הרצת הפלייבוק
                    // אנחנו דורסים את ה-inventory של ה-cfg רק לרגע זה כדי להשתמש ב-IP החדש
                    sh "ansible-playbook -i host_to_provision.txt instance.yml"
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh 'rm -f host_to_provision.txt'
        }
    }
}
