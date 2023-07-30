import jenkins.model.*

collectBuildEnv = [:]

@NonCPS
def getNodes(String label) {
    jenkins.model.Jenkins.instance.nodes.collect { thisAgent ->
        if (thisAgent.labelString.contains("${label}")) {
            // this works too
            // if (this Agent.labelString == "${label}") {
            return thisAgent.name
        }
    }
}

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

            // Download the artefact.
            sh script: "curl -o artefact.zip \"http://nexus.jbrmmg.me.uk:8081/nexus/service/local/artifact/maven/redirect?r=${env.REPOSITORY_NAME}&g=${env.COMPONENT_GROUP}&a=${env.COMPONENT_NAME}&v=${env.COMPONENT_VERSION}&p=zip\""
        }
    }
}

def processTask() {
    // Use the node list
    def nodeList = getNodes( "${env.COMPONENT_NAME}" )

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

        stage('test') {
            steps {
                nodesByLabel('Script',false)
            }
        }
    }
}
