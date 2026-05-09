pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // ג'נקינס מושך אוטומטית את הריפו שהוגדר בתוך ה-Job
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                // הרצה ישירות בשורש הפרויקט
                sh 'terraform init'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                // ניגש ישירות לנתיב היחסי בתוך הריפו שירד
                dir('infrastructure/ansible') {
                    sh 'ansible-playbook -i inventory instance.yml'
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            deleteDir() // מומלץ: מנקה את ה-Workspace בסיום כדי למנוע בעיות שטח אחסון
        }
    }
}
