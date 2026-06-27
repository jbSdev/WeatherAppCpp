pipeline {
    agent any

        environment {
            IMAGE_NAME     = "weather-api"
            CONTAINER_NAME = "weather-api"
            APP_PORT       = "8090"
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
                        # Find Jenkins' network
                        JENKINS_NETWORK=\$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}' jenkins | head -c 12)
                        JENKINS_NETWORK_NAME=\$(docker inspect -f '{{range \$k, \$v := .NetworkSettings.Networks}}{{\$k}}{{end}}' jenkins)
                        echo "Jenkins network: \$JENKINS_NETWORK_NAME"

                        docker run -d \
                        --name ${CONTAINER_NAME}-test \
                        --network \$JENKINS_NETWORK_NAME \
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
                    sh '''
                        docker rm -f weather-api || true

                        docker run -d \
                            --name weather-api \
                            --restart unless-stopped \
                            -p $APP_PORT:8080 \
                            -e OWM_API_KEY=$OWM_API_KEY \
                            weather-api:latest

                        echo "Deployed → http://localhost:$APP_PORT"
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    sleep 3
                    CONTAINER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' weather-api)
                    STATUS=\$(curl -s --max-time 5 -o /dev/null -w '%{http_code}' http://$CONTAINER_IP:8080/health)
                    if [ "\$STATUS" != "200" ]; then
                        echo "Deployment verification failed!"
                        exit 1
                    fi
                    echo "Service is up at http://$(hostname -I | awk '{print $1}):8090"
                '''
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
