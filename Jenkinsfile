pipeline {
    agent any

    triggers {
        githubPush()
    }

    options {
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME = "mkr2026/django-todo-cicd"
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

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        set +x

                        echo "$DOCKER_PASS" | docker login \
                            -u "$DOCKER_USER" --password-stdin

                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest

                        docker logout
                    '''
                }
            }
        }

        
       stage('Backup to Floci S3') {
        environment {
         AWS_ACCESS_KEY_ID = 'test'
         AWS_SECRET_ACCESS_KEY = 'test'
         AWS_DEFAULT_REGION = 'us-east-1'
         AWS_EC2_METADATA_DISABLED = 'true'
        }
        steps {
           echo 'Creating and uploading Todo application backup to Floci S3'
             sh '''
                  chmod +x scripts/backup_to_floci_s3.sh
                  bash scripts/backup_to_floci_s3.sh
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
