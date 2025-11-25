pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building...'
                sh 'echo "Hello from the build stage!"'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
                sh 'echo "Running tests..."'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sh 'echo "Deploying application..."'
            }
        }
    }
}