pipeline {
    agent { label 'scripts' }
    stages {
        stage('Hello World') {
            steps {
                echo 'Hello World'
                echo "NODE_NAME = ${env.NODE_NAME}"
                echo "COMPONENT_ID = ${env.COMPONENT_ID}"
                echo "COMPONENT_NAME = ${env.COMPONENT_NAME}"
                echo "COMPONENT_GROUP = ${env.COMPONENT_GROUP}"
                echo "COMPONENT_VERSION = ${env.COMPONENT_VERSION}"
            }
        }
    }
}
