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
                echo 'Pulling base image...'
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
                sh '''
                    echo "SEVERITY,CVE_ID,PACKAGE,VERSION,FIXED_VERSION,DESCRIPTION" > output.csv

                    echo "--- CRITICAL ---" >> output.csv
                    trivy image --severity CRITICAL --format json ${IMAGE_NAME}:${IMAGE_TAG} | \
                    python3 -c "
import json,sys
data=json.load(sys.stdin)
for r in data.get('Results',[]):
    for v in r.get('Vulnerabilities',[]):
        print(f\"CRITICAL,{v.get('VulnerabilityID','')},{v.get('PkgName','')},{v.get('InstalledVersion','')},{v.get('FixedVersion','')},{v.get('Title','').replace(',',';')}\")" >> output.csv

                    echo "--- MEDIUM ---" >> output.csv
                    trivy image --severity MEDIUM --format json ${IMAGE_NAME}:${IMAGE_TAG} | \
                    python3 -c "
import json,sys
data=json.load(sys.stdin)
for r in data.get('Results',[]):
    for v in r.get('Vulnerabilities',[]):
        print(f\"MEDIUM,{v.get('VulnerabilityID','')},{v.get('PkgName','')},{v.get('InstalledVersion','')},{v.get('FixedVersion','')},{v.get('Title','').replace(',',';')}\")" >> output.csv

                    echo "--- LOW ---" >> output.csv
                    trivy image --severity LOW --format json ${IMAGE_NAME}:${IMAGE_TAG} | \
                    python3 -c "
import json,sys
data=json.load(sys.stdin)
for r in data.get('Results',[]):
    for v in r.get('Vulnerabilities',[]):
        print(f\"LOW,{v.get('VulnerabilityID','')},{v.get('PkgName','')},{v.get('InstalledVersion','')},{v.get('FixedVersion','')},{v.get('Title','').replace(',',';')}\")" >> output.csv

                    echo "✅ Scan terminé"
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