#!/bin/bash
# Build Date:    ${script.build.date}
# Build Version: ${version}
#
# Script for stopping a service
#
echo Start Service version ${version} ${script.build.date}

echo Repository           : $1
echo ComponentName        : $2
echo Deployment Directory : $3

# Determine the service name
if [ $1 = "MAVEN_RELEASES" ]; then
ServiceNameTemp=$(echo $2 | tr '[:upper:]' '[:lower:]')
else
ServiceNameTemp=$(echo $2-dev | tr '[:upper:]' '[:lower:]')
fi
ServiceName=${ServiceNameTemp,,}
echo Service Name         : ${ServiceName}

if [ -z ${ServiceName} ]; then
	echo Service Name not set
	exit
fi

sudo mv ./artifactExtract/${ServiceName}.service /lib/systemd/system/${ServiceName}.service

echo enable ${ServiceName}
sudo systemctl enable ${ServiceName}
sudo systemctl start ${ServiceName}

