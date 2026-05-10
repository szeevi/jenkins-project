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
                    echo "Provisioning host: ${instanceIp}"
                    
                    writeFile file: 'inventory_fixed.ini', text: "[all]\n${instanceIp}"
                    
                    // שימוש ב-withCredentials עבור המפתח הפרטי (SSH)
                    // זה יוצר קובץ זמני עם תוכן המפתח ומכניס את הנתיב שלו למשתנה SSH_KEY
                    withCredentials([sshUserPrivateKey(credentialsId: 'aws-ssh-key', 
                                                     keyFileVariable: 'SSH_KEY', 
                                                     usernameVariable: 'SSH_USER')]) {
                        sh """
                            export ANSIBLE_CONFIG=./ansible.cfg
                            export ANSIBLE_HOST_KEY_CHECKING=False
                            
                            # הרצת אנסיבל תוך שימוש במשתנה SSH_KEY כקובץ המפתח
                            ansible-playbook -v -i inventory_fixed.ini instance.yml \
                            --user ${SSH_USER} \
                            --private-key ${SSH_KEY}
                        """
                    }
                }
            }
        }
    }
    post {
        always {
            sh 'rm -f inventory_fixed.ini'
        }
    }
}
