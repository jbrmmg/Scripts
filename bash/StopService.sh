#!/bin/bash
# Build Date:    ${script.build.date}
# Build Version: ${version}
#
# Script for stopping a service
#
echo Stop Service version ${version} ${script.build.date}

echo Deployment Directory : ${DeploymentDir}
echo GoEnvironment        : ${GO_ENVIRONMENT_NAME}

#Artifact
ArtifactVariableName=$(compgen -A variable | grep GO_PACKAGE_ | grep _ARTIFACT_ID)
echo Get Artifact from    : ${ArtifactVariableName}

DeployArtifact=${!ArtifactVariableName}
echo Artifact             : ${DeployArtifact}

# Determine the service name
if [ ${Environment} = "PDN" ]; then
ServiceNameTemp=${DeployArtifact}
else
ServiceNameTemp=${DeployArtifact}-${Environment}
fi
ServiceName=${ServiceNameTemp,,}
echo Service Name         : ${ServiceName}

if [ -z ${ServiceName} ]; then
	echo Service Name not set
	exit
fi

Running="$(systemctl is-active ${ServiceName} >/dev/null 2>&1 && echo YES || echo NO)"
echo Is ${ServiceName} active? ${Running}
if [ ${Running} = "YES" ]; then
	echo stop ${ServiceName}
	sudo systemctl stop ${ServiceName}
fi
