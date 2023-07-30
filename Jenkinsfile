pipeline {
    agent { label 'scripts' }
    stages {
        stage('Hello World') {
            steps {
                echo 'Hello World'
                echo "NODE_NAME = ${env.NODE_NAME}"
            }
        }
    }
}
