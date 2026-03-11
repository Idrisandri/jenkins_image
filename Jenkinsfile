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
        stage('TRIVY SCAN') {
            steps {
                echo 'Scanning image with Trivy...'
                sh '''#!/bin/bash
                    echo "SEVERITY,CVE_ID,PACKAGE,VERSION,FIXED_VERSION,DESCRIPTION" > output.csv
                    echo "--- CRITICAL ---" >> output.csv
                    trivy image --severity CRITICAL --format table ${IMAGE_NAME}:${IMAGE_TAG} >> output.csv 2>&1 || true
                    echo "--- MEDIUM ---" >> output.csv
                    trivy image --severity MEDIUM --format table ${IMAGE_NAME}:${IMAGE_TAG} >> output.csv 2>&1 || true
                    echo "--- LOW ---" >> output.csv
                    trivy image --severity LOW --format table ${IMAGE_NAME}:${IMAGE_TAG} >> output.csv 2>&1 || true
                    echo "Scan termine"
                    cat output.csv
                '''
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
            archiveArtifacts artifacts: 'output.csv', allowEmptyArchive: true
        }
        success {
            echo 'Pipeline terminé avec succès !'
        }
        failure {
            echo 'Échec du pipeline.'
        }
    }
}