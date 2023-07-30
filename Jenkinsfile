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

def dumpBuildEnv(String agentName) {
    node("${agentName}") {
        stage("Env in ${agentName}") {
            echo "running on agent, ${agentName}"

            echo "NODE_NAME = ${env.NODE_NAME}"
            echo "COMPONENT_ID = ${env.COMPONENT_ID}"
            echo "COMPONENT_NAME = ${env.COMPONENT_NAME}"
            echo "COMPONENT_GROUP = ${env.COMPONENT_GROUP}"
            echo "COMPONENT_VERSION = ${env.COMPONENT_VERSION}"
        }
    }
}

def processTask() {
    // Use the
    def nodeList = getNodes( "${env.COMPONENT_NAME}" )

    for(i=0; i < nodeList.size(); i++) {
        def agentName = nodeList[i]

        // skip the null entries in the nodeList
        if (agentName != null) {
            println "Preparing task for " + agentName
            collectBuildEnv["node_" + agentName] = {
                dumpBuildEnv(agentName)
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
