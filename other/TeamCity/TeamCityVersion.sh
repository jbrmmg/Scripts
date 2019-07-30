#!/usr/bin/env bash
env | grep ^major\\.version= | cut -d= -f2-
env | grep ^minor\\.version= | cut -d= -f2-
if grep -Fxq "build.is.personal=true" $TEAMCITY_BUILD_PROPERTIES_FILE
then
   echo Personal Build
   %teamcity.tool.maven3_3%/bin/mvn versions:set -f %env.pomfile% -DnewVersion=1.0-Beta-SNAPSHOT
elif [ "refs/heads/Development" = "%teamcity.build.branch%" ];
then
   echo Development branch
   %teamcity.tool.maven3_3%/bin/mvn versions:set -f %env.pomfile% -DnewVersion=%build.number%-SNAPSHOT
elif [ "refs/heads/Release" = "%teamcity.build.branch%" ];
then
   echo Release branch
   %teamcity.tool.maven3_3%/bin/mvn versions:set -f %env.pomfile% -DnewVersion=%build.number%
else
   echo Feature or Bug Fix branch
   %teamcity.tool.maven3_3%/bin/mvn versions:set -f %env.pomfile% -DnewVersion=%build.number%-%teamcity.build.branch%-SNAPSHOT
fi