import jenkins.model.*

collectBuildEnv = [:]

def deployArtefact(String agentName) {
    node("${agentName}") {
        stage("Env in ${agentName}") {
            // Output details.
            echo "running on agent, ${agentName}"
            echo "NODE_NAME = ${env.NODE_NAME}"
            echo "COMPONENT_ID = ${env.COMPONENT_ID}"
            echo "COMPONENT_NAME = ${env.COMPONENT_NAME}"
            echo "COMPONENT_GROUP = ${env.COMPONENT_GROUP}"
            echo "COMPONENT_VERSION = ${env.COMPONENT_VERSION}"
            echo "REPOSITORY_NAME = ${env.REPOSITORY_NAME}"

            // Determine where the artefacts are deployed.
            env.DEPLOY_DIRECTORY = "/usr/bin/jbr"
            switch(env.REPOSITORY_NAME) {
                case 'maven-snapshots':
                    env.DEPLOY_DIRECTORY = "/usr/bin/jbr/dev"
                    break
            }

            echo "DEPLOY_DIRECTORY = ${env.DEPLOY_DIRECTORY}"

            // Delete the zip
            sh script: "rm -f artifact.zip"

            // Delete the folder
            sh script: "rm -fR artifactExtract"

            // Download the artefact.
            sh script: "curl -u download:password \"http://nexus.jbrmmg.me.uk:8081/service/rest/v1/search/assets?sort=version&direction=desc&repository=${env.REPOSITORY_NAME}&group=${env.COMPONENT_GROUP}&name=${env.COMPONENT_NAME}&version=${env.COMPONENT_VERSION}&maven.extension=zip\" | grep -Po '\"downloadUrl\" : \"\\K.+(?=\",)' | xargs curl -f -o artifact.zip"

            // Unzip the files
            unzip zipFile: "artifact.zip", dir: "artifactExtract"

            // Clean up.
            sh script: "rm -f artifact.zip"
        }
    }
}

def processTask() {
    // Use the node list
    def nodeList = nodesByLabel (label: "${env.COMPONENT_NAME}", offline: false)

    for(i=0; i < nodeList.size(); i++) {
        def agentName = nodeList[i]

        // skip the null entries in the nodeList
        if (agentName != null) {
            println "Preparing task for " + agentName
            collectBuildEnv["node_" + agentName] = {
                deployArtefact(agentName)
            }
        }
    }
}

pipeline {
    agent {
        label "admin-agent"
    }

    stages {
        stage('agents-tasks') {

            steps {
                script {
                    processTask()

                    parallel collectBuildEnv
                }
            }
        }
    }
}
