#!/bin/bash
# Build Date:    ${script.build.date}
# Build Version: ${version}
#
# Script for deploying a war
#
# ENVIRONMENT VARIABLES
#
# $DeploymentDir   = directory
# $Environment     = name of environment

echo Deploy Web Artifact version ${version} ${script.build.date}

echo Deployment Directory : ${WebDeploymentDir}
echo GoEnvironment        : ${GO_ENVIRONMENT_NAME}

#Determine the URL used for the artifact, the group and the artifact id.
#URL
UrlVariableName=$(compgen -A variable | grep GO_PACKAGE_ | grep _LOCATION)
echo Get URL from         : ${UrlVariableName}

Url=${!UrlVariableName}
echo URL                  : ${Url}

#Group
GroupVariableName=$(compgen -A variable | grep GO_PACKAGE_ | grep _GROUP_ID)
echo Get Group from       : ${GroupVariableName}

Group=${!GroupVariableName}
echo Group                : ${Group}

#Artifact
ArtifactVariableName=$(compgen -A variable | grep GO_PACKAGE_ | grep _ARTIFACT_ID)
echo Get Artifact from    : ${ArtifactVariableName}

DeployArtifact=${!ArtifactVariableName}
echo Artifact             : ${DeployArtifact}

if [ -z ${WebDeploymentDir} ]; then
	echo Deployment directory not set
	exit
fi

# Remove files in the deployment directory.
rm -rf ${WebDeploymentDir}/*

# Delete the existing file
DeployFile=${WebDeploymentDir}/${DeployArtifact}-${Environment}.war
echo File to deploy ${DeployFile}
rm -f ${DeployFile}

# Update properties and logging configuration
curl -sS -L ${Url} > ${DeployFile}
cd ${WebDeploymentDir}
unzip ${DeployArtifact}-${Environment}.war

rm -f ${DeployFile}