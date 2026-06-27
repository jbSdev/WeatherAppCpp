pipeline {
    agent any

        environment {
            IMAGE_NAME     = "weather-api"
            CONTAINER_NAME = "weather-api"
            APP_PORT       = "8088"
            // OWM_API_KEY is stored as a Jenkins Secret Text credential with id 'owm-api-key'
        }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                    echo "Building commit: ${env.GIT_COMMIT?.take(7)}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def shortSha = env.GIT_COMMIT?.take(7) ?: 'local'
                        env.IMAGE_TAG = "${IMAGE_NAME}:${shortSha}"
                        env.IMAGE_LATEST = "${IMAGE_NAME}:latest"

                        sh """
                        docker build \
                        --tag ${env.IMAGE_TAG} \
                        --tag ${env.IMAGE_LATEST} \
                        .
                        """
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    // Spin up a temporary container and hit /health
                    sh """
                        docker run -d \
                        --name ${CONTAINER_NAME}-test \
                        -p 18080:8080 \
                        -e OWM_API_KEY=dummy_smoke_test \
                        ${env.IMAGE_TAG}

                        # Give it a moment to start
                        sleep 8

                        echo "=== Container Logs ==="
                        docker logs ${CONTAINER_NAME}-test || true
                        
                        CONTAINER_IP=\$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CONTAINER_NAME}-test)
                        echo "Container IP: \$CONTAINER_IP"

                        # /health should return 200 regardless of API key
                        STATUS=\$(curl -s -L --max-time 5 -o /dev/null -w '%{http_code}' http://\$CONTAINER_IP:8080/health)
                        docker rm -f ${CONTAINER_NAME}-test

                        if [ "\$STATUS" != "200" ]; then
                            echo "Health check failed with status \$STATUS"
                            exit 1
                        fi
                        echo "Health check passed."
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([string(credentialsId: 'owm-api-key', variable: 'OWM_API_KEY')]) {
                    sh """
# Stop and remove old container if running
                        docker rm -f ${CONTAINER_NAME} || true

                        docker run -d \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p ${APP_PORT}:8080 \
                        -e OWM_API_KEY=${OWM_API_KEY} \
                        ${env.IMAGE_TAG}

                    echo "Deployed ${env.IMAGE_TAG} → http://localhost:${APP_PORT}"
                        """
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh """
                    sleep 3
                    STATUS=\$(curl -s -o /dev/null -w '%{http_code}' http://localhost:${APP_PORT}/health)
                    if [ "\$STATUS" != "200" ]; then
                        echo "Deployment verification failed!"
                            exit 1
                            fi
                            echo "Service is up."
                            """
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded. weather-api is live on port ${APP_PORT}."
        }
        failure {
            sh "docker rm -f ${CONTAINER_NAME}-test || true"
                echo "Pipeline failed. Check logs above."
        }
        always {
            // Clean up dangling images to save disk space
            sh "docker image prune -f || true"
        }
    }
}
