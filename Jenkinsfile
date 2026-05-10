pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }
    stages {
        stage('Checkout') { steps { checkout scm } }
        stage('Terraform Init') { steps { sh 'terraform init' } }
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
                    def instanceIp = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                    echo "Waiting for SSH to be ready on ${instanceIp}..."
                    sleep 30 // המתנה קצרה כדי לוודא שהמכונה עלתה לגמרי
                    
                    // שימוש בפורמט ה-IP עם פסיק
                    sh "ansible-playbook -i '${instanceIp},' instance.yml"
                }
            }
        }
    }
    post {
        success {
            script {
                def finalIp = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                echo "-----------------------------------------------------------"
                echo "DEPLOYMENT SUCCESSFUL!"
                echo "New VM IP Address: ${finalIp}"
                echo "Web URL: http://${finalIp}/web"
                echo "-----------------------------------------------------------"
            }
        }
    }
}
