#!/bin/bash
####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will do the finalisation processing for the build process.
# It should be self evident what it does. It's basically a sharing of ip addresses
# between machines so that firewalls can be appropriately configured. We want the
# firewalls to be as explicit as possible, so, we simply only allow the ip addresses
# of specific machines throught the firewall. That is what this is for.
####################################################################################
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
####################################################################################
####################################################################################
#set -x

status ""
status ""
status ""
status ""
status ""
status "========================================================="
status "======================FINALISING========================="
status "========================================================="

if ( [ "${ENABLE_EFS}" = "0" ] || [ "${ENABLE_EFS}" = "" ] )
then
    status "Cleaning out the tunnel in the datastore"
    status "################################################################################################################################################"
    status "It is recommended to expedite the process, if there is a lot of residual data, that you go to the datastore provider website (${DATASTORE_CHOICE})"
    status "And clean out (delete) all old content from the webrootsynctunnel subdirectory of the configuration bucket:"
    status "`/bin/echo "s3://${WEBSITE_URL}" | /bin/sed "s/\.//g"`-config/webrootsynctunnel/*"
    status "#################################################################################################################################################"
    . ${BUILD_HOME}/providerscripts/datastore/PurgeTunnel.sh
fi

OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

# Give a copy of the ssl certificate generated from lets encrypt to the autoscaler for use when building new webservers when autoscaling

test ${PRODUCTION} -eq 1 && /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ${SERVER_USER}@${ASIP}:/home/${SERVER_USER}/.ssh/fullchain.pem
test ${PRODUCTION} -eq 1 && /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ${SERVER_USER}@${ASIP}:/home/${SERVER_USER}/.ssh/privkey.pem

#Just do some checks to make sure that all the different server types are running correctly

if ( [ "${PRODUCTION}" = "1" ] && [ "`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh "autoscaler" ${CLOUDHOST} 2>/dev/null`" = "" ] )
then
    status "It seems like something is not quite right with the build. The Autoscaler seems not to be running so the website will not function properly."
fi

if ( [ "`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh "webserver" ${CLOUDHOST} 2>/dev/null`" = "" ] )
then
    status "It seems like something is not quite right with the build. The webserver seems not to be running so the website will not function properly."
fi

if (  [ "${DATABASE_INSTALLATION_TYPE}" != "None" ] && [ "`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh "database" ${CLOUDHOST} 2>/dev/null`" = "" ] )
then
    status "It seems like something is not quite right with the build. The database seems not to be running so the website will not function properly."
fi

#If our provider supports snapshots, then we can generate a snapshot of our servers here.
#When we have an autoscaling event we can configure things so that the new webserver will be deployed via a snapshot which is faster
if ( [ "${GENERATE_SNAPSHOTS}" -eq "1" ] )
then
    if ( [ "${CLOUDHOST}" = "digitalocean" ] )
    then
        status "###########################################################################################################################"
        status "About to take snapshots of your newly provisioned servers. I noticed that sometimes when it is required for a server to be"
        status "In an 'off state' it seems to keep polling and never reach the off state. Dunno why, but to fix it, just power down the"
        status "Specific server that the tool is cycling for and then power it back up again and that will be it sorted"
        status "###########################################################################################################################"
        status "Press <enter>"
        read x
    fi

    . ${BUILD_HOME}/providerscripts/server/SnapshotAutoscaler.sh
    . ${BUILD_HOME}/providerscripts/server/SnapshotWebserver.sh
    . ${BUILD_HOME}/providerscripts/server/SnapshotDatabase.sh

    status "#######################INITIATED THE SNAPSHOTTING PROCESS##########################"
    status "The snapshots will be generated by your cloudhost provider ( ${CLOUDHOST} ) and will be ready for use in a few minutes"
    status "###################################################################################"
    status "Press <enter> to complete the build"
    read x

    /bin/mkdir -p ${BUILD_HOME}/snapshots/${SERVER_USER}
    /bin/mkdir -p ${BUILD_HOME}/snapshots/${SERVER_USER}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/
    /bin/cp ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${BUILD_HOME}/snapshots/${SERVER_USER}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/
    /bin/cp ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ${BUILD_HOME}/snapshots/${SERVER_USER}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/
    /bin/mkdir -p ${BUILD_HOME}/snapshots/${SERVER_USER}/buildconfiguration/${CLOUDHOST}/
    /bin/cp -r ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials ${BUILD_HOME}/snapshots/${SERVER_USER}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials
fi

#If we are not building for production (an autoscaler is not present) and we are persisting assets to the datastore, then we need to force a
#clean out of the datastore before we go any further
#if ( [ "${PRODUCTION}" = "0" ] && [ "${PERSIST_ASSETS_TO_CLOUD}" = "1" ] )
#then
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${WSIP} "${SUDO} /home/${SERVER_USER}/providerscripts/datastore/SetupConfig.sh forcepurge"
#fi

#Do some checks to find out if the build has completed correctly, before we say we are finished
/bin/mkdir -p ${BUILD_HOME}/runtimedata/${CLOUDHOST}/
/bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/INITIALBUILDCOMPLETED
test ${PRODUCTION} -eq 1 && /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/INITIALBUILDCOMPLETED ${SERVER_USER}@${ASIP}:/home/${SERVER_USER}/runtime/INITIALBUILDCOMPLETED

buildcompleted="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${WSIP} "DEBIAN_FRONTEND=noninteractive /bin/ls /home/${SERVER_USER}/runtime/BUILDCOMPLETED" 2>/dev/null`"
while ( [ "${buildcompleted}" = "" ] )
do
    buildcompleted="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${WSIP} "DEBIAN_FRONTEND=noninteractive /bin/ls /home/${SERVER_USER}/runtime/BUILDCOMPLETED" 2>/dev/null`"
    status "Build process isn't complete. Please wait for build initialisation to complete before navigating to your site....."
    status "Testing to see if build process is completed...."
    /bin/sleep 60
done

#This enables the application to have any post processing done that it needs. There is pre and post processing either side of the build process
status "Performing any post processing that is needed for your application ...."
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${WSIP} "/home/${SERVER_USER}/providerscripts/application/processing/PerformPostProcessingByApplication.sh ${SERVER_USER}" >&3

#We are satisfied that all is well, so let's try and see if the application is actually online and active

if ( [ "${DNS_CHOICE}" != "NONE" ] )
then
    status "Application has completed its initialisation, just checking that it is also online....."
    /bin/sleep 60
    serverinstalled="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${WSIP} "${SUDO} /home/${SERVER_USER}/providerscripts/application/monitoring/CheckServerAlive.sh" 2>/dev/null`"
    while ( [ "`/bin/echo ${serverinstalled} | /bin/grep ALIVE`" = "" ] )
    do
        serverinstalled="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${WSIP} "${SUDO} /home/${SERVER_USER}/providerscripts/application/monitoring/CheckServerAlive.sh" 2>/dev/null`"
        status "Application has completed its initialisation, just checking that it is also online....."
        /bin/sleep 60
    done
fi

status "Just giving the servers a little bit of time to complete their internal initialisation. Please wait...."

/bin/sleep 120

#Tell our infrastructure, 'yes, I am happy that you are up and running and functioning correctly'.
#Other scripts can then check if the build has completed correctly before they action
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${WSIP} "${SUDO} /bin/touch /home/${SERVER_USER}/config/INSTALLEDSUCCESSFULLY"
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${WSIP} "${SUDO} /bin/touch /home/${SERVER_USER}/runtime/INSTALLEDSUCCESSFULLY"

status "Build process fully complete"

############################################################################################
#If you are a developer and you modify these scripts, you will need to update the
#envdump.dat file below with the variables you have added
###########################################################################################

/bin/rm ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/^$/d' ${BUILD_HOME}/builddescriptors/envdump.dat
while read line
do
    name="`/bin/echo ${line} | /usr/bin/awk -F':' '{print $1}'`"
    value="`/bin/echo ${line} | /usr/bin/awk -F':' '{print $NF}'`"
    value="`eval /bin/echo ${value}`"
    /bin/echo "export ${name}=\"${value}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
done < ${BUILD_HOME}/builddescriptors/envdump.dat


#Print a final little congratulations message to say the build is good and that the application should now be online
/bin/date
status "OK, good news, all done your servers are configured and responsive"
status "If you check with your acceleration/DNS provider, in this case : ${DNS_CHOICE} and once you see ip addresses appear for your domain: ${WEBSITE_URL}"
status "You should be able to navigate to your website now in your browser at: https://${WEBSITE_URL}"
status ""
status ""
status "#########################################################################################"
status "Thanks for using our build kit - ANY PROBS, GIVE AT LEAST 10 MINUTES before investigating"
status "#########################################################################################"
