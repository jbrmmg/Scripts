#!/bin/bash
# Build Date:    ${script.build.date}
# Build Version: ${version}
#
# Script for deploying a service jar
#
# ENVIRONMENT VARIABLES
#
# $DeploymentDir           = directory
# $Environment             = name of environment
#

echo Deploy Artifact version ${version} ${script.build.date}

echo Deployment Directory : ${DeploymentDir}
echo GoEnvironment        : ${GO_ENVIRONMENT_NAME}
echo Environment          : ${Environment}

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

# Delete the existing file
if [ ${Environment} = "PDN" ]; then
DeployFile=${DeploymentDir}/${DeployArtifact}-onejar.jar
ServiceNameTemp=${DeployArtifact}
else
DeployFile=${DeploymentDir}/${DeployArtifact}-${Environment}-onejar.jar
ServiceNameTemp=${DeployArtifact}-${Environment}
fi
ServiceName=${ServiceNameTemp,,}
echo Service Name         : ${ServiceName}

# File to update:
# /$DeploymentDir/$ServiceName-$environment-onejar.jar

echo Deploy File          : ${DeployFile}
rm -f ${DeployFile}

# Update properties and logging configuration
curl -sS -L ${Url} > ${DeployFile}
sudo chgrp jbr ${DeployFile}
sudo chmod 774 ${DeployFile}

echo Extract config/${DeployArtifact}-${Environment}.properties
unzip -p ${DeployFile} BOOT-INF/classes/config/${DeployArtifact}-${Environment}.properties >${DeploymentDir}/${DeployArtifact}-${Environment}.properties
echo Extract config/${DeployArtifact}-${Environment}-log4j.xml
unzip -p ${DeployFile} BOOT-INF/classes/config/${DeployArtifact}-${Environment}-log4j.xml >${DeploymentDir}/${DeployArtifact}-${Environment}-log4j.xml
echo Extract config/${ServiceName}.service
unzip -p ${DeployFile} BOOT-INF/classes/config/${ServiceName}.service >${DeploymentDir}/${ServiceName}.service
sudo mv ${DeploymentDir}/${ServiceName}.service /lib/systemd/system/${ServiceName}.service

# Update service
