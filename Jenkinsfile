
pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME = "todoapp"
        DEPLOYMENT_NAME = "todoapp"
        CONTAINER_NAME = "todoapp"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/kee227/django-todo-cicd.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv venv
                    venv/bin/pip install -r requirements.txt
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    venv/bin/python test_app.py test
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG = "v${BUILD_NUMBER}"
                }

                sh '''
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl set image deployment/${DEPLOYMENT_NAME} \
                    ${CONTAINER_NAME}=${IMAGE_NAME}:${IMAGE_TAG}

                    kubectl rollout status deployment/${DEPLOYMENT_NAME} \
                    --timeout=180s
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    kubectl get deployment todoapp
                    kubectl get pods
                    kubectl get services
                '''
            }
        }
    }

    post {
        success {
            echo "Todo application deployed successfully!"
        }

        failure {
            echo "Pipeline failed. Check Console Output."
        }
    }
}
