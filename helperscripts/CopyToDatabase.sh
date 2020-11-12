#!/bin/sh
####################################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will copy a file, passed as a parameter to your selected webserver
####################################################################################################
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

DB_IP=""

if ( [ ! -f  ./CopyToWebserver.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

BUILD_HOME="`/bin/cat ../buildconfiguration/buildhome`"

/bin/echo "Which Cloudhost are you using for this server?"
/bin/echo "(1) Digital Ocean (2) Exoscale (3) Linode (4) Vultr (5) AWS"
read response

if ( [ "${response}" = "1" ] )
then
    CLOUDHOST="digitalocean"
    ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh \"database\" \"digitalocean\"`"
elif ( [ "${response}" = "2" ] )
then
    CLOUDHOST="exoscale"
    ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh \"database\" \"exoscale\"`"
elif ( [ "${response}" = "3" ] )
then
    CLOUDHOST="linode"
    ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh \"database\" \"linode\"`"
elif ( [ "${response}" = "4" ] )
then
    CLOUDHOST="vultr"
    ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh \"database\" \"vultr\"`"
elif ( [ "${response}" = "5" ] )
then
    CLOUDHOST="aws"
    ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh \"*database*\" \"aws\"`"
fi

if ( [ "${ips}" = "" ] )
then
    /bin/echo "There doesn't seem to be any databases running"
    exit
fi

/bin/echo "What is the build identifier you want to connect to?"
/bin/echo "You have these builds to choose from: "
/bin/ls ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}
/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

/bin/echo "Which database would you like to connect to?"
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

SERVER_USER="`/bin/ls ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/SERVERUSER:* | /usr/bin/awk -F':' '{print $NF}'`"

/bin/echo "Does your server use Elliptic Curve Digital Signature Algorithm or the Rivest Shamir Adleman Algorithm for authenitcation?"
/bin/echo "If you are not sure, please try one and then the other. If you are prompted for a password, it is the wrong one"
/bin/echo "Please select (1) RSA (2) ECDSA"
read response

SSH_PORT="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} | /bin/grep SSH_PORT | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"

/bin/echo "Please enter the full path to the directory you would like to copy the file to on the remove machine"
read remotedir

if ( [ "${response}" = "1" ] )
then
    /usr/bin/scp -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} $1 ${SERVER_USER}@${DB_IP}:${remotedir}
elif ( [ "${response}" = "2" ] )
then
    /usr/bin/scp -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} $1 ${SERVER_USER}@${DB_IP}:${remotedir}
else
    /bin/echo "Unrecognised selection, please select only 1 or 2"
fi
