#!/bin/bash
# Build Date:    ${script.build.date}
# Build Version: ${version}
#
# Script for stopping a service
#
echo Stop Service version ${version} ${script.build.date}

echo Repository           : $1
echo ComponentName        : $2
echo Deployment Directory : $3

# Determine the service name
if [ $1 = "maven-releases" ]; then
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

Running="$(systemctl is-active ${ServiceName} >/dev/null 2>&1 && echo YES || echo NO)"
echo Is ${ServiceName} active? ${Running}
if [ ${Running} = "YES" ]; then
	echo stop ${ServiceName}
	sudo systemctl stop ${ServiceName}
fi
