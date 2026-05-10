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
                    // 1. שליפת ה-IP
                    def instanceIp = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                    
                    echo "Waiting for SSH to be ready on ${instanceIp}..."
                    sleep 30 
                    
                    // 2. יצירת קובץ אינוונטורי בצורה בטוחה (Native Jenkins step)
                    // שיטה זו מבטיחה ירידת שורה תקינה ופורמט INI מושלם
                    writeFile file: 'inventory_fixed.ini', text: "[all]\n${instanceIp}"
                    
                    // 3. בדיקה ויזואלית ב-Log לראות שהקובץ נוצר תקין
                    sh "cat inventory_fixed.ini"
                    
                    // 4. הרצת ה-Playbook
                    sh "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -v -i inventory_fixed.ini instance.yml"
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
        always {
            sh 'rm -f inventory_fixed.ini'
        }
    }
}
