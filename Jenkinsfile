pipeline {
    agent any

    environment {
        SONAR_PROJECT_KEY = 'mspr-main'
        COMPOSE_FILE      = 'docker-compose.yml'
        COMPOSE_CICD_FILE = 'docker-compose.cicd-MSPR.yml'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validation docker-compose') {
            steps {
                sh 'docker compose -f ${COMPOSE_FILE} config --quiet'
                sh 'docker compose -f ${COMPOSE_CICD_FILE} config --quiet'
                echo "Les deux fichiers docker-compose sont valides"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    script {
                        def scannerHome = tool 'SonarQube Scanner'
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.sources=. \
                                -Dsonar.inclusions="**/*.yml,**/*.yaml,**/*.sh,**/*.conf" \
                                -Dsonar.exclusions="**/.git/**"
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo "=== Déploiement automatique de l'application MSPR ==="
                sh 'docker compose -f ${COMPOSE_FILE} down --remove-orphans || true'
                sh '''
                    docker images --format "{{.Repository}}:{{.Tag}}" \
                    | grep "^mspr/" \
                    | xargs -r docker rmi || true
                '''
                sh '''
                    docker compose -f ${COMPOSE_FILE} pull --ignore-pull-failures || true
                    docker compose -f ${COMPOSE_FILE} up -d --build --remove-orphans
                '''
                sh '''
                    echo "Attente du démarrage des services..."
                    sleep 30
                    docker compose -f ${COMPOSE_FILE} ps
                '''
            }
            post {
                success {
                    echo "Application MSPR déployée avec succès"
                    sh 'docker compose -f ${COMPOSE_FILE} ps'
                }
                failure {
                    echo "Échec du déploiement — affichage des logs"
                    sh 'docker compose -f ${COMPOSE_FILE} logs --tail=50 || true'
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline Main : SUCCESS (build #${BUILD_NUMBER})"
        }
        failure {
            echo "Pipeline Main : FAILURE (build #${BUILD_NUMBER})"
        }
        always {
            deleteDir()
        }
    }
}
