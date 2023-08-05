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

echo Deployment Directory : ${BindDir}
echo GoEnvironment        : ${GO_ENVIRONMENT_NAME}
echo Environment          : ${Environment}
echo MyDNS1               : ${MyDNS1}
echo MyDNS2               : ${MyDNS2}

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

DeployFile=/usr/bin/jbr/DNSconfig.zip
echo Deploy File          : ${DeployFile}
rm -f ${DeployFile}

# Update properties and logging configuration
echo Download the file
curl -sS -L ${Url} > ${DeployFile}
sudo chgrp jbr ${DeployFile}
sudo chmod 774 ${DeployFile}
sudo chmod g+rw ${BindDir}/*
sudo chmod g+rwx ${BindDir}

#Stop the service
echo Stop Bind
sudo systemctl stop bind9

echo Extract configuration
unzip -o ${DeployFile} -d ${BindDir}

echo replace text in files
sed -i "s/##MYDNS1##/$MyDNS1/g" /etc/bind/db.*
sed -i "s/##MYDNS2##/$MyDNS2/g" /etc/bind/db.*

# Start the service
echo start the service
sudo systemctl start bind9

# Remove the zip
echo remove deployed file
rm ${DeployFile}
