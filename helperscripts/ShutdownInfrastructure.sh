#!/bin/sh
########################################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will shutdown your infrastructure
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

if ( [ ! -f ./helperscripts/ShutdownInfrastructure.sh ] )
then
    /bin/echo "This script is expected to run from the same directory as the Build Home"
    /bin/echo "You can run it as \${BUILD_HOME}/helperscripts/ShutdownInfrastructure.sh"
    exit
fi

BUILD_HOME="`/bin/pwd`"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4)Vultr 5)AWS. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
    CLOUDHOST="digitalocean"
    autoscaler_token_to_match="*autoscaler*"
    webserver_token_to_match="*webserver*"
    database_token_to_match="*database*"
elif ( [ "${response}" = "2" ] )
then
    CLOUDHOST="exoscale"
    autoscaler_token_to_match="autoscaler"
    webserver_token_to_match="webserver"
    database_token_to_match="database"
elif ( [ "${response}" = "3" ] )
then
    CLOUDHOST="linode"
    autoscaler_token_to_match="*autoscaler*"
    webserver_token_to_match="*webserver*"
    database_token_to_match="*database*"
elif ( [ "${response}" = "4" ] )
then
    CLOUDHOST="vultr"
    autoscaler_token_to_match="*autoscaler*"
    webserver_token_to_match="*webserver*"
    database_token_to_match="*database*"
elif ( [ "${response}" = "5" ] )
then
    CLOUDHOST="aws"
    autoscaler_token_to_match="*autoscaler*"
    webserver_token_to_match="*webserver*"
    database_token_to_match="*database*"
else
    /bin/echo "Unrecognised  cloudhost. Exiting ...."
    exit
fi

/bin/echo "What is the build identifier you want to connect to?"
/bin/echo "You have these builds to choose from: "
/bin/ls ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} | /bin/grep -v 'credentials'
/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

autoscalerips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${autoscaler_token_to_match}" ${CLOUDHOST}`"
webserverips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${webserver_token_to_match}" ${CLOUDHOST}`"
databaseips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${database_token_to_match}" ${CLOUDHOST}`"

/bin/echo "autoscaler ips: ${autoscalerips}"
/bin/echo "webserver ips: ${webserverips}"
/bin/echo "database ips: ${databaseips}"

/bin/echo "Press <enter> to accept"
read x


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

/bin/echo "Are you sure you want to shutdown the infrastructure? (Y/N)"
read response

if ( [ "${response}" != "Y" ] && [ "${response}" != "y" ] )
then
    exit
fi

/bin/echo "OK, shutting down infrastructure. It may take some time to shut it all down...."

SERVER_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSER`"
SERVER_USER_PASSWORD="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSERPASSWORD`"
SSH_PORT="`/bin/grep SSH_PORT ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"
SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

for ip in ${autoscalerips}
do
    /usr/bin/ssh -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=5 -o ConnectionAttempts=6 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${SERVER_USERNAME}@${ip} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/utilities/ShutdownThisAutoscaler.sh" 2>/dev/null
done

first="1"
for ip in ${webserverips}
do
    if ( [ "${first}" = "1" ] )
    then
        first="0"
        /usr/bin/ssh -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=5 -o ConnectionAttempts=6 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${SERVER_USERNAME}@${ip} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/utilities/ShutdownThisWebserver.sh 'backup'"
    else
        /usr/bin/ssh -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=5 -o ConnectionAttempts=6 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${SERVER_USERNAME}@${ip} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/utilities/ShutdownThisWebserver.sh"
    fi
done

for ip in ${databaseips}
do
    /usr/bin/ssh -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=5 -o ConnectionAttempts=6 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${SERVER_USERNAME}@${ip} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/utilities/ShutdownThisDatabase.sh 'backup'" 2>/dev/null
done

/bin/echo "Do you want to destroy the actual machines as well? This is totally non-recoverable (Y/N)"
read response1

if ( [ "${response1}" != "y" ] && [ "${response1}" != "Y" ] )
then
    /bin/echo "OK, not destroying machines. Exiting...."
    exit
fi

for autoscalerip in ${autoscalerips}
do
    ${BUILD_HOME}/providerscripts/server/DestroyServer.sh ${autoscalerip} ${CLOUDHOST} 1>/dev/null 2>/dev/null
done

for webserverip in ${webserverips}
do
    ${BUILD_HOME}/providerscripts/server/DestroyServer.sh ${webserverip} ${CLOUDHOST} 1>/dev/null 2>/dev/null
done

for databaseip in ${databaseips}
do
    ${BUILD_HOME}/providerscripts/server/DestroyServer.sh ${databaseip} ${CLOUDHOST} 1>/dev/null 2>/dev/null
done

/bin/echo "#######################################################################################################################################"
/bin/echo "IF YOU USED A MANAGED DATABASE, YOU WILL NEED TO SHUT IT DOWN MANUALLY USING YOUR PROVIDER\'S INTERFACE."
/bin/echo "REMEMBER TO MANUALLY REVOKE ANY ACCESS RIGHTS GRANTED TO SECURIY GROUPS/ FIREWALLS AND SO ON ASSOCIATED WITH YOUR MANAGED DB"
/bin/echo "THIS IS SO IF THE SECURITY GROUP IS REUSED AT A LATER TIME, ADDITIONAL ACCESS IS NOT INADVERTENTLY GRANTED"
/bin/echo "#######################################################################################################################################"
