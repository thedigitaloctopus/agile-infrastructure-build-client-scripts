#!/bin/sh
######################################################################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will connect you to your database(s) via ssh
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
#set -x

if ( [ ! -f  ./ConnectToDB.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

export BUILD_HOME="`/usr/bin/pwd | /bin/sed 's/\/helper.*//g'`"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4)Vultr 5)AWS. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
    CLOUDHOST="digitalocean"
    token_to_match="database.*"
elif ( [ "${response}" = "2" ] )
then
    CLOUDHOST="exoscale"
    token_to_match="database"
elif ( [ "${response}" = "3" ] )
then
    CLOUDHOST="linode"
    token_to_match="database"
elif ( [ "${response}" = "4" ] )
then
    CLOUDHOST="vultr"
    token_to_match="database"
elif ( [ "${response}" = "5" ] )
then
    CLOUDHOST="aws"
    token_to_match="*database*"
else
    /bin/echo "Unrecognised  cloudhost. Exiting ...."
    exit
fi



/bin/echo "What is the build identifier you want to connect to?"
/bin/echo "You have these builds to choose from: "
/bin/ls ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} | /bin/grep -v 'credentials'
/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh ${token_to_match} ${CLOUDHOST}`"

if ( [ "${ips}" = "" ] )
then
    /bin/echo "There doesn't seem to be any databases running"
    exit
fi

DIR="`/bin/pwd`"


/bin/echo "Which Database server would you like to connect to?"
count=1
for ip in ${ips}
do
    /bin/echo "${count}:   ${ip}"
    /bin/echo "Press Y/N to connect..."
    read response
    if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
    then
        DB_IP=${ip}
        break
    fi
    count="`/usr/bin/expr ${count} + 1`"
done

/bin/echo "Does your server use Elliptic Curve Digital Signature Algorithm or the Rivest Shamir Adleman Algorithm for authenitcation?"
/bin/echo "Please select (1) RSA (2) ECDSA"
read response

SERVER_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSER`"
SSH_PORT="`/bin/grep SSH_PORT ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"

/usr/bin/ssh-keygen -f "${HOME}/.ssh/known_hosts" -R [${DB_IP}]:${SSH_PORT} 2>/dev/null

if ( [ "${response}" = "1" ] )
then
    /usr/bin/ssh -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP}
    if ( [ "$?" != "0" ] )
    then
        /usr/bin/ssh -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP}
    fi
elif ( [ "${response}" = "2" ] )
then
    /usr/bin/ssh -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP}
    if ( [ "$?" != "0" ] )
    then
        /usr/bin/ssh -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP}
    fi
else
    /bin/echo "Unrecognised selection, please select only 1 or 2"
fi

