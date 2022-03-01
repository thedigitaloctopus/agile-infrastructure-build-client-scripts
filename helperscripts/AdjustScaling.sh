#!/bin/sh
########################################################################################################
# Author: Peter Winter
# Date  : 13/01/2022
# Description : This script will adjust the scaling settings for your infrastructure
########################################################################################################
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

if ( [ ! -f  ./AdjustScaling.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr 5)AWS. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
    CLOUDHOST="digitalocean"
    token_to_match="*autoscaler*"
elif ( [ "${response}" = "2" ] )
then
    CLOUDHOST="exoscale"
    token_to_match="autoscaler"
elif ( [ "${response}" = "3" ] )
then
    CLOUDHOST="linode"
    token_to_match="*autoscaler*"
elif ( [ "${response}" = "4" ] )
then
    CLOUDHOST="vultr"
    token_to_match="*autoscaler*"
elif ( [ "${response}" = "5" ] )
then
    CLOUDHOST="aws"
    token_to_match="*autoscaler*"
else
    /bin/echo "Unrecognised  cloudhost. Exiting ...."
    exit
fi

export BUILD_HOME="`/bin/pwd | /bin/sed 's/\/helper.*//g'`"

/bin/echo "What is the build identifier you want to allow access for?"
/bin/echo "You have these builds to choose from: "
/bin/ls ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} | /bin/grep -v 'credentials'
/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

/bin/echo "OK, can you please tell me what the URL is to be?"
read website_url

configbucket="`/bin/echo ${website_url} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
configbucket="${configbucket}-config"

if ( [ "`/usr/bin/s3cmd ls s3://${configbucket}`" = "" ] )
then
    /bin/echo "Can't find the cofigration bucket in your datastore for website: ${website_url}"
    exit
fi

/usr/bin/s3cmd --force get s3://${configbucket}/scalingprofile/profile.cnf

original_no_webservers="`/bin/grep "NO_WEBSERVERS" ./profile.cnf | /usr/bin/awk -F'=' '{print $NF}'`"

/bin/echo "Your number of webservers is currently set to: ${original_no_webservers}"
/bin/echo "What do you want to set your number of webservers to, please enter the number of webservers you want as an integer"

read no_webservers

/bin/sed -i "s/NO_WEBSERVER.*/NO_WEBSERVERS=${no_webservers}/" ./profile.cnf

/usr/bin/s3cmd put ./profile.cnf s3://${configbucket}/scalingprofile/profile.cnf

/bin/rm ./profile.cnf
