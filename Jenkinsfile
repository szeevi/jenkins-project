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
                    writeFile file: 'inventory_fixed.ini', text: "[all]\n${instanceIp}"
                    
                    withCredentials([sshUserPrivateKey(credentialsId: 'aws-ssh-key', 
                                                     keyFileVariable: 'SSH_KEY', 
                                                     usernameVariable: 'SSH_USER')]) {
                        sh """
                            export ANSIBLE_CONFIG=./ansible.cfg
                            export ANSIBLE_HOST_KEY_CHECKING=False
                            ansible-playbook -i inventory_fixed.ini instance.yml \
                            --user ${SSH_USER} \
                            --private-key ${SSH_KEY}
                        """
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                // שליפה של ה-IP לצורך התצוגה בסוף
                def finalIp = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                echo "-----------------------------------------------------------"
                echo "DEPLOYMENT SUCCESSFUL!"
                echo "New VM IP Address: ${finalIp}"
                echo "Web URL: http://${finalIp}/web/index.php"
                echo "-----------------------------------------------------------"
            }
        }
        always {
            sh 'rm -f inventory_fixed.ini'
        }
    }
}
