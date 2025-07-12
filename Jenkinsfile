pipeline {
    agent any

    tools {
        nodejs 'nodejs'
        jdk 'jdk'
        dockerTool 'docker'
    }

    environment {
        SCANNER_HOME = tool 'sonar_scanner_cli'
        DOCKER_HOME = tool 'docker'
        DOCKER_IMAGE = 'himanshu19660/mynodejsappliction:latest'
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'git_acces-tocken',
                    url: 'https://github.com/Himanshuyadav11/nodejsdeploy.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh """
                        ${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=nodejsdeploy \
                        -Dsonar.projectName='Node.js Deployment Project' \
                        -Dsonar.sources=. \
                        -Dsonar.javascript.file.suffixes=.js,.jsx
                    """
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    try {
                        sh 'npm test'
                    } catch (Exception e) {
                        echo 'No test script defined or tests failed.'
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh "trivy image --format table -o image.html $DOCKER_IMAGE || true"
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    sh "docker build -t $DOCKER_IMAGE ."
                    withDockerRegistry(credentialsId: 'docker-tocken', toolName: 'docker') {
                        sh "docker push $DOCKER_IMAGE"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh 'kubectl create namespace nodejsweb || true'
                    sh '[ -f k8u-deployment.yaml ] && kubectl apply -f k8u-deployment.yaml || true'
                    sh 'sleep 20'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'kubectl get pods -n nodejsweb || true'
                sh 'kubectl get svc -n nodejsweb || true'
                sh 'sleep 40'
            }
        }

        stage('Wait and Delete Deployment') {
            steps {
                sh 'sleep 300'
                sh '[ -f k8u-deployment.yaml ] && kubectl delete -f k8u-deployment.yaml || true'
            }
        }
    }
}
