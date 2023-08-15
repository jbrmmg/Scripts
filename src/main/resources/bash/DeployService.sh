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
echo Deployment For       : ${deployment.script.artifact.name}

ServiceName=${ServiceNameTemp,,}
echo Service Name         : ${ServiceName}
echo Bin File             : ${BinFile}

# File to update:
# /$DeploymentDir/$ServiceName-$environment.zip

echo Deploy File          : ${DeployFile}
rm -f ${DeployFile}

# Update properties and logging configuration
curl -sS -L ${Url} > ${DeployFile}

echo Extract config/${ServiceName}.service
unzip -p ${DeployFile} ${ServiceName}.service >${DeploymentDir}/${ServiceName}.service
sudo mv ${DeploymentDir}/${ServiceName}.service /lib/systemd/system/${ServiceName}.service

echo Extract ${ServiceName}-onejar.jar
unzip -p ${DeployFile} ${DeployArtifact}-${DeployVersion}.jar >${BinFile}
sudo chgrp jbr ${BinFile}
sudo chmod 774 ${BinFile}

rm -r ${DeployFile}
