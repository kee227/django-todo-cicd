pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                echo 'Downloading code from GitHub'
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv .venv
                    .venv/bin/pip install -r requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Running Python tests'
                sh '.venv/bin/pytest -v'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image'
                sh 'docker build -t todoapp:latest .'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying Todo application'

                sh '''
                    docker rm -f todoapp || true

                    docker run -d \
                    --name todoapp \
                    -p 5000:5000 \
                    todoapp:latest
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD Pipeline Successful!'
        }

        failure {
            echo 'CI/CD Pipeline Failed!'
        }
    }
}
