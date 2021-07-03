#!/bin/sh
#########################################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will reboot your infrastructure
#########################################################################################################
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


if ( [ ! -f  ./RebootInfrastructure.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

BUILD_HOME="`/bin/cat ../buildconfiguration/buildhome`"

/bin/echo "I find that with some providers, occassionally, the networking doesn't initialse correctly and you get timeouts between machines"
/bin/ehco "If you find a situation where everything looks to be running fine but you get a timeout, a simple reboot can sort it out"
/bin/echo "So, please bear that in mind as something to try if you are getting timeouts...Thanks"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr 5) AWS. Please Enter the number for your cloudhost"
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
/bin/ls ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}
/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

autoscalerips="`./providerscripts/server/GetServerIPAddresses.sh "*autoscaler*" ${CLOUDHOST}`"
webserverips="`./providerscripts/server/GetServerIPAddresses.sh "webserver*" ${CLOUDHOST}`"
databaseips="`./providerscripts/server/GetServerIPAddresses.sh "database*" ${CLOUDHOST}`"

/bin/echo "Do your servers use Elliptic Curve Digital Signature Algorithm or the Rivest Shamir Adleman Algorithm for authenitcation?"
/bin/echo "If you are not sure, please try one and then the other. If you are prompted for a password, it is the wrong one"
/bin/echo "Please select (1) RSA (2) ECDSA"
read response

if ( [ "${response}" = "1" ] )
then
    ALGORITHM="rsa"
elif ( [ "${response}" = "2" ] )
then
    ALGORITHM="ecdsa"
else
    /bin/echo "Unknown choice. Exiting...."
    exit
fi

/bin/echo "Are you sure you want to reboot the infrastructure? (Y/N)"
read response

if ( [ "${response}" != "Y" ] && [ "${response}" != "y" ] )
then
    exit
fi

SSH_PORT="`/bin/grep SSH_PORT ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"

/bin/echo "OK, rebooting your infrastructure"

for ip in ${autoscalerips}
do
    /usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ./keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} root@${ip} "/sbin/shutdown -r now" 2>/dev/null
done

for ip in ${webserverips}
do
    /usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ./keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} root@${ip} "/sbin/shutdown -r now" 2>/dev/null
done

for ip in ${databaseips}
do
    /usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ./keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} root@${databaseips} '/sbin/shutdown -r now' 2>/dev/null
done

/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/liveimageserverkeys/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} root@${ip} '/sbin/shutdown -r now' 2>/dev/null
