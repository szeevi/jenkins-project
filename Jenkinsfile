pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                // מוריד את הקוד מה-Repository (כולל ה-Playbook וה-cfg)
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
                // שימוש ב-Credentials שהגדרת ב-Jenkins (aws-credentials-global)
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
                    // 1. שליפת ה-IP מתוך ה-Output של טרפורם
                    def instanceIp = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                    
                    echo "Waiting for SSH to be ready on ${instanceIp}..."
                    sleep 30 // המתנה של 30 שניות כדי לוודא שה-SSH במכונה למעלה
                    
                    // 2. יצירת קובץ אינוונטורי תקני בפורמט INI
                    // זה פותר את בעיית ה-Unable to parse שראינו קודם
                    sh "echo '[all]\n${instanceIp}' > inventory_fixed.ini"
                    
                    // 3. הרצת ה-Playbook
                    // אנחנו מוסיפים דריסה ל-Host Key Checking כדי למנוע תקיעה בחיבור ראשון
                    sh "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory_fixed.ini instance.yml"
                }
            }
        }
    }

    post {
        success {
            script {
                // הדפסת פרטי הגישה בצורה ברורה בסוף ה-Console
                def finalIp = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                echo "-----------------------------------------------------------"
                echo "DEPLOYMENT SUCCESSFUL!"
                echo "New VM IP Address: ${finalIp}"
                echo "Web URL: http://${finalIp}/web"
                echo "-----------------------------------------------------------"
            }
        }
        always {
            // ניקוי הקובץ הזמני
            sh 'rm -f inventory_fixed.ini'
        }
    }
}
