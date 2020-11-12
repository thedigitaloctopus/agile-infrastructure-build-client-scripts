#!/bin/sh
######################################################################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script enables you to configure the scaling of your webservers and is the way it must be done if you have mutiple autoscalers running
######################################################################################################################################################
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
set -x

if ( [ ! -f  ./ConnectToAutoscaler.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

export BUILD_HOME="`/bin/cat ../buildconfiguration/buildhome`"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr 5)AWS. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
    CLOUDHOST="digitalocean"
elif ( [ "${response}" = "2" ] )
then
    CLOUDHOST="exoscale"
elif ( [ "${response}" = "3" ] )
then
    CLOUDHOST="linode"
elif ( [ "${response}" = "4" ] )
then
    CLOUDHOST="vultr"
elif ( [ "${response}" = "5" ] )
then
    CLOUDHOST="aws"
else
    /bin/echo "Unrecognised  cloudhost. Exiting ...."
    exit
fi

/bin/echo "What is the build identifier you want to connect to?"
/bin/echo "You have these builds to choose from: "
/bin/ls ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} | /bin/grep -v 'credentials'
/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

#AUTOSCALER_IP="`/bin/ls ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASIP* | /usr/bin/awk -F':' '{print $NF}'`"
ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh *autoscaler* ${CLOUDHOST} ${BUILD_HOME}`"

/bin/echo "Does your server use Elliptic Curve Digital Signature Algorithm or the Rivest Shamir Adleman Algorithm for authenitcation?"
/bin/echo "Please select (1) RSA (2) ECDSA"
read response

SSH_PORT="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} | /bin/grep SSH_PORT | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"
SERVER_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSER`"

/bin/echo "How many webservers do you wish to have active?"

read no_webservers

if ( [ "${no_webservers}" -eq "${no_webservers}" ] )
then 
    /bin/echo "Thanks, setting webservers to : ${no_webservers}"
    /bin/echo "Press enter to continue"
    read x
else
    /bin/echo "That is not a valid number of webservers, exiting....."
    exit
fi

for ip in ${ips}
do
    /usr/bin/ssh-keygen -f "${HOME}/.ssh/known_hosts" -R [${ip}]:${SSH_PORT}
    if ( [ "${response}" = "1" ] )
    then
        if ( [ "${SSH_PORT}" != "" ] )
        then
            /usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${ip} "/bin/sed -i "/^NO_WEBSERVERS=/c\NO_WEBSERVERS=${no_webservers}" /home/${SERVER_USERNAME}/config/scalingprofile/profile.cnf"
        else
            /usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${ip} "/bin/sed -i "/^NO_WEBSERVERS=/c\NO_WEBSERVERS=${no_webservers}" /home/${SERVER_USERNAME}/config/scalingprofile/profile.cnf"
fi
    elif ( [ "${response}" = "2" ] )
    then
        if ( [ "${SSH_PORT}" != "" ] )
        then
            /usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${ip} "/bin/sed -i "/^NO_WEBSERVERS=/c\NO_WEBSERVERS=${no_webservers}" /home/${SERVER_USERNAME}/config/scalingprofile/profile.cnf" 
else
            /usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${ip} "/bin/sed -i "/^NO_WEBSERVERS=/c\NO_WEBSERVERS=${no_webservers}" /home/${SERVER_USERNAME}/config/scalingprofile/profile.cnf" 
fi
     else
        /bin/echo "Unrecognised selection, please select only 1 or 2"
    fi
done
