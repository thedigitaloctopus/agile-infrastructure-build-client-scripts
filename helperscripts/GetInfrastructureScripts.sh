#!/bin/sh
#######################################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will obtain the infrastructure scripts for you from the repository
#######################################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################################################
#######################################################################################################
#set -x

INFRASTRUCTURE_REPOSITORY_PROVIDER="bitbucket"

if ( [ ! -f  ./GetInfrastructureScripts.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

BUILD_HOME="`/bin/cat ../buildconfiguration/buildhome`"

/bin/echo "Please select the repository provider where the infrastructure source code you are deploying is kept"
/bin/echo "Enter 1: for Bitbucket 2: for Github"
/bin/echo "If you don't have an infrastructure repository, then you need to register for one at bitbucket.org or github.com"
/bin/echo "and then create a repository and upload the sourcecode for your website to it"
/bin/echo "If you are using sourcecode stored in someone else's repository, then you need to have read access to it"
read choice

while ( [ "`/bin/echo "1 2" | /bin/grep ${choice}`" = "" ] )
do
    /bin/echo "Invalid choice, please try again..."
    read choice
done

if ( [ "`/bin/echo ${choice} | /bin/grep '1'`" != "" ] )
then
    INFRASTRUCTURE_REPOSITORY_PROVIDER="bitbucket"
fi
if ( [ "`/bin/echo ${choice} | /bin/grep '2'`" != "" ] )
then
    INFRASTRUCTURE_REPOSITORY_PROVIDER="github"
fi

/bin/mkdir -p ${BUILD_HOME}/scripts/autoscaler
/bin/mkdir -p ${BUILD_HOME}/scripts/webserver
/bin/mkdir -p ${BUILD_HOME}/scripts/buildclient
/bin/mkdir -p ${BUILD_HOME}/scripts/database

/bin/echo "Please enter your infrastructure repository username:"
read INFRASTRUCTURE_REPOSITORY_USERNAME
/bin/echo "Please enter your infrastructure repository password:"
read INFRASTRUCTURE_REPOSITORY_PASSWORD
/bin/echo "Please enter your infrastructure repository owner:"
read INFRASTRUCTURE_REPOSITORY_OWNER

cd ${BUILD_HOME}/scripts/autoscaler

/usr/bin/git init

${BUILD_HOME}/providerscripts/git/GitPull.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-autoscaler-scripts

cd ${BUILD_HOME}/scripts/database

/usr/bin/git init

${BUILD_HOME}/providerscripts/git/GitPull.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-database-scripts

cd ${BUILD_HOME}/scripts/webserver

/usr/bin/git init

${BUILD_HOME}/providerscripts/git/GitPull.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-webserver-scripts

cd ${BUILD_HOME}/scripts/buildclient

/usr/bin/git init

${BUILD_HOME}/providerscripts/git/GitPull.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-build-client-scripts