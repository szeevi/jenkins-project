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
                    
                    writeFile file: 'inventory_fixed.ini', text: "${instanceIp}"
                    
                    // שימוש ב-SSH Agent כדי להזריק את המפתח מה-Credentials
                    sshagent(['aws-ssh-key']) {
                        sh """
                            export ANSIBLE_CONFIG=./ansible.cfg
                            export ANSIBLE_HOST_KEY_CHECKING=False
                            ansible-playbook -v -i inventory_fixed.ini instance.yml
                        """
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                def finalIp = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                echo "Success! URL: http://${finalIp}/web"
            }
        }
    }
}
