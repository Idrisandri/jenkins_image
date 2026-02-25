pipeline {
    agent any

    environment {
        IMAGE_NAME = "idris390/myimage"
        IMAGE_TAG  = "latest"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
    }

    stages {

        stage('PULL') {
            steps {
                echo 'Pulling base image Ubuntu 24.04...'
                sh 'docker pull ubuntu:24.04'
            }
        }

        stage('BUILD') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('PUSH') {
            steps {
                echo 'Pushing image to DockerHub...'
                sh '''
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logout'
        }
        success {
            echo 'Pipeline terminé avec succès !'
        }
        failure {
            echo 'Échec du pipeline.'
        }
    }
}