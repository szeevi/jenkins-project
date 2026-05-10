pipeline {
    agent any

    environment {
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
                // שימוש ב-ID התקין שמופיע בתמונה השנייה שלך
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
                    // חילוץ ה-IP
                    def instanceIp = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                    
                    // יצירת אינוונטורי זמני
                    sh "echo '${instanceIp}' > host_to_provision.txt"
                    
                    // הרצת פלייבוק
                    sh "ansible-playbook -i host_to_provision.txt instance.yml"
                }
            }
        }
    }

    post {
        success {
            script {
                def finalIp = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                echo "-----------------------------------------------------------"
                echo "🚀 DEPLOYMENT SUCCESSFUL!"
                echo "🌐 New VM IP Address: ${finalIp}"
                echo "🔗 Web URL: http://${finalIp}/web"
                echo "-----------------------------------------------------------"
            }
        }
        always {
            sh 'rm -f host_to_provision.txt'
        }
    }
}
