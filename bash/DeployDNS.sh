#!/bin/bash
# Build Date:    ${script.build.date}
# Build Version: ${version}
#
# Script for deploying a DNS configuration
#
# ENVIRONMENT VARIABLES
#
# $Environment             = name of environment
#

echo Deploy DNS configuration ${version} ${script.build.date}

$DeploymentDir = /etc/bind

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

echo Deploy File          : ${DeployFile}
rm -f ${DeployFile}

# Update properties and logging configuration
curl -sS -L ${Url} > ${DeployFile}
sudo chgrp jbr ${DeployFile}
sudo chmod 774 ${DeployFile}

echo Extract configuration
unzip ${DeployFile} -d ${DeploymentDir}

# Update service
