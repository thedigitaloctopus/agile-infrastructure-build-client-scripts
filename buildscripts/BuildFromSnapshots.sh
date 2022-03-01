#!/bin/sh
#####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This will build machines from pre existing snapshots held with your
# cloudhost. The cloudhost has to support snapshots and snapshots are identified
# uniquely so that they can be provisioned. From a deployer perspective, the environment
# still needs to be re-primed or at least reviews as, for example, you might require
# that the machine sizes are different to what they were when the snapshots were generated
# Also, you may require to use a different repo, an hourly backup build deployment
# when you may have built off a baseline in the build the snapshots were generated from.
# NOTE THEN: The enviroment is fully re-primed or reviewed for a snapshot deployment, but
# only a small subset of specific environment variables are actually actively renewed
# when deployed from a snapshot, otherwise, the enviroment is considered to be the same
# as when the snapshots were generated, for example, same username and password for
# the user that we sudo from as were in the original and so on.
#####################################################################################
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
######################################################################################
######################################################################################
#set -x

OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "

if ( [ "${AUTOSCALER_IMAGE_ID}" != "" ] && [ "${WEBSERVER_IMAGE_ID}" != "" ] && [ "${DATABASE_IMAGE_ID}" != "" ] )
then
    status "#########################BUILD FROM SNAPSHOTS#######################"
    status ""
    
    #. ${BUILD_HOME}/providerscripts/datastore/PurgeDatastore.sh "reset"

    . ${BUILD_HOME}/providerscripts/datastore/PurgeDatastore.sh

    #Generate the snapshot of the autoscaler. We use the username as the identifier as that will remain constant between
    #the original machine and the generated snapshot
    RND="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1`"
    FULL_SNAPSHOT_ID="`/bin/ls ${BUILD_HOME}/snapshots | /bin/grep ${SNAPSHOT_ID}`"

    no_autoscalers="0"
    while ( [ "${no_autoscalers}" -lt "${NO_AUTOSCALERS}" ] )
    do
       status "#######################################################################################################"
       status "Building autoscaler `/usr/bin/expr ${no_autoscalers} + 1` of ${NO_AUTOSCALERS} autoscalers"

        autoscaler_name="autoscaler-${RND}-${WEBSITE_NAME}-${BUILD_IDENTIFIER}"
        autoscaler_name="`/bin/echo ${no_autoscalers}-${autoscaler_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"

        #Find out what operating system we are building for
        OS_TYPE="`${BUILD_HOME}/providerscripts/cloudhost/GetOperatingSystemVersion.sh ${AS_SIZE} ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"

        if ( [ "${SUBNET_ID}" = "" ] )
        then
            SUBNET_ID="FILLER"
        fi

        #Actually create the server from the snapshot. Note that the image id of the snapshot we want to build from is passed in as the
        #last parameter
        ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${OS_TYPE}" "${REGION_ID}" "${AS_SERVER_TYPE}" "${autoscaler_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} "${SUBNET_ID}" "${AUTOSCALER_IMAGE_ID}" 1>/dev/null 2>/dev/null
    
    
        #Get the ip addresses of the server we have just built
        ip=""
        private_ip=""
        count="0"
        while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "20" ] )
        do
            status "Interrogating for autoscaler ip addresses....."
            ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${autoscaler_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
            private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${autoscaler_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
            /bin/sleep 30
            count="`/usr/bin/expr ${count} + 1`"
        done

        status "It looks like the machine has booted OK"
        ASIP=${ip}
        ASIP_PRIVATE=${private_ip}

        status "Have got the ip addresses for your autoscaler"
        status "Public IP address: ${ASIP}"
        status "Private IP address: ${ASIP_PRIVATE}"

        #record the server ip address(es)
        /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASIP:*
        /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASPRIVATEIP:*
        /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASIP:${ASIP}
        /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASPRIVATEIP:${ASIP_PRIVATE}


        #We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
        #So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
        #We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
        /bin/echo "Host ${ASIP}" >> ~/.ssh/config
        /bin/echo "IdentityFile ~/.ssh/${FULL_SNAPSHOT_ID}.key" >> ~/.ssh/config
        /bin/echo "IdentitiesOnly yes" >> ~/.ssh/config
        no_autoscalers="`/usr/bin/expr ${no_autoscalers} + 1`"
    done
    
    ASIPS="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "*autoscaler*" ${CLOUDHOST} | /bin/grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | /bin/tr '\n' ':' | /bin/sed 's/\:$//g'`"
    ASIP_PRIVATES="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "*autoscaler*" ${CLOUDHOST} | /bin/grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | /bin/tr '\n' ':' | /bin/sed 's/\:$//g'`"
    ASIPS_CLEANED="`/bin/echo ${ASIPS} | /bin/sed 's/\:/ /g'`"
    
    status "#########################################################################################################"

    #Generate the webserver snapshot. Again, we use the username to create the identifier of the machine as this will remain
    #the same between the original machine and the machine built from a snapshot
    webserver_name="webserver-${RND}-${WEBSITE_NAME}-${BUILD_IDENTIFIER}"
    webserver_name="`/bin/echo ${webserver_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"

    #Build the machine from the snapshot. The snapshot image id is passed in as the final parameter
    ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${OS_TYPE}" "${REGION_ID}" "${WS_SERVER_TYPE}" "${webserver_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} "${SUBNET_ID}" "${WEBSERVER_IMAGE_ID}" 1>/dev/null 2>/dev/null

    #Get the ip addresses of the server we have just built
    ip=""
    private_ip=""
    count="0"
    while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "10" ] )
    do
        status "Interrogating for webserver ip addresses....."
        ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${webserver_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
        private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${webserver_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
        /bin/sleep 30
        count="`/usr/bin/expr ${count} + 1`"
    done

    status "It looks like the machine has booted OK"
    WSIP=${ip}
    WSIP_PRIVATE=${private_ip}

    status "Have got the ip addresses for your webserver"
    status "Public IP address: ${WSIP}"
    status "Private IP address: ${WSIP_PRIVATE}"

    #record the server ip address(es)
    /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/WSIP:*
    /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/WSPRIVATEIP:*
    /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/WSIP:${WSIP}
    /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/WSPRIVATEIP:${WSIP_PRIVATE}

    #We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
    #So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
    #We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
    /bin/echo "Host ${WSIP}" >> ~/.ssh/config
    /bin/echo "IdentityFile ~/.ssh/${FULL_SNAPSHOT_ID}.key" >> ~/.ssh/config
    /bin/echo "IdentitiesOnly yes" >> ~/.ssh/config
    
    status "#########################################################################################################"


    # generate the database snapshot. The username is used to create the identifier as it will remain consistent between the original machine
    # and the machine generated from a snapshot
    database_name="database-${RND}-${WEBSITE_NAME}-${BUILD_IDENTIFIER}"
    database_name="`/bin/echo ${database_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"
    ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${OS_TYPE}" "${REGION_ID}" "${DB_SERVER_TYPE}" "${database_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} "${SUBNET_ID}" "${DATABASE_IMAGE_ID}" 1>/dev/null 2>/dev/null

    #Get the ip addresses of the server we have just built
    ip=""
    private_ip=""
    count="0"
    while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "10" ] )
    do
        status "Interrogating for database ip addresses....."
        ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${database_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
        private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${database_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
        /bin/sleep 30
        count="`/usr/bin/expr ${count} + 1`"
    done

    status "It looks like the machine has booted OK"
    DBIP=${ip}
    DBIP_PRIVATE=${private_ip}

    status "Have got the ip addresses for your database"
    status "Public IP address: ${DBIP}"
    status "Private IP address: ${DBIP_PRIVATE}"

    #record the server ip address(es)
    /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBIP:*
    /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBPRIVATEIP:*
    /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBIP:${DBIP}
    /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBPRIVATEIP:${DBIP_PRIVATE}

    #We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
    #So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
    #We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
    /bin/echo "Host ${DBIP}" >> ~/.ssh/config
    /bin/echo "IdentityFile ~/.ssh/${FULL_SNAPSHOT_ID}.key" >> ~/.ssh/config
    /bin/echo "IdentitiesOnly yes" >> ~/.ssh/config

    #Remember the keys and config settings for use when we deploy these from these snapshots. The build process will try
    #and use new keys but we'll say, 'no you don't, you have to use the ones we recorded earlier'.

    /bin/mv  ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}  ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.$$

    /bin/cp ${BUILD_HOME}/snapshots/${FULL_SNAPSHOT_ID}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}

    /bin/mv  ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub  ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub.$$

    /bin/cp ${BUILD_HOME}/snapshots/${FULL_SNAPSHOT_ID}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub

    /bin/mv ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials.$$

    /bin/cp -r ${BUILD_HOME}/snapshots/${FULL_SNAPSHOT_ID}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/

    SERVER_USER_PASSWORD="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSERPASSWORD`"

    SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

    ########AUTOSCALER config#################
        
    for ASIP in ${ASIPS_CLEANED}
    do
       
        #Wait until the autoscaler has been fully provisioned from its snapshot

        status "Trying to connect to the autoscaler to perform initialisation...."

        /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "exit"

        while ( [ "$?" != "0" ] )
        do
            /bin/sleep 10
            status "Still trying to connect to the autoscaler to perform initialisation...."
            /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "exit"
        done

        status "Connected to the autoscaler, now initialising it..."

        #There might be some stuff on the autoscaler which is from the build when the snapshots were generated, like IP addresses and so on, so
        #clear them out as they have now been changed/renewed

    #    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVE:* /home/${FULL_SNAPSHOT_ID}/.ssh/KEYID:* /home/${FULL_SNAPSHOT_ID}/.ssh/SNAPAUTOSCALE:* /home/${FULL_SNAPSHOT_ID}/config/INSTALLEDSUCCESSFULLY /home/${FULL_SNAPSHOT_ID}/runtime/INITIALCONFIGSET /home/${FULL_SNAPSHOT_ID}/runtime/NETCONFIGURED /home/${FULL_SNAPSHOT_ID}/config/APPLICATION_DB_CONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/*lock* ${HOME}/runtime/INITIALCONFIGSET"


        #swap out the ip addresses that were from the preceeding build and update them with the new ones for our newly provisioned machines
    #    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/rm /home/${FULL_SNAPSHOT_ID}/.ssh/*IP*"

    #    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVE:${BUILD_ARCHIVE_CHOICE} /home/${FULL_SNAPSHOT_ID}/.ssh/AUTOSCALE:${WEBSERVER_SNAPSHOT_NAME} /home/${FULL_SNAPSHOT_ID}/.ssh/SNAPSHOTID:${WEBSERVER_IMAGE_ID} /home/${FULL_SNAPSHOT_ID}/.ssh/SNAPAUTOSCALE:1 /home/${FULL_SNAPSHOT_ID}/.ssh/KEYID:${PUBLIC_KEY_ID} /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDCLIENTIP:${BUILD_CLIENT_IP} /home/${FULL_SNAPSHOT_ID}/.ssh/MYPUBLICIP:${ASIP} /home/${FULL_SNAPSHOT_ID}/.ssh/MYIP:${ASIP_PRIVATE}"

    #    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/RefreshNetworking.sh"

        #Reinitialise everything by rebooting the machine
    #    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /sbin/shutdown -r now"

        /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/config/INSTALLEDSUCCESSFULLY /home/${FULL_SNAPSHOT_ID}/runtime/INITIALCONFIGSET /home/${FULL_SNAPSHOT_ID}/runtime/NETCONFIGURED /home/${FULL_SNAPSHOT_ID}/config/APPLICATION_DB_CONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/*lock* /home/${FULL_SNAPSHOT_ID}/runtime/CONFIG-PRIMED"

        /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDARCHIVE\" \"${BUILD_ARCHIVE_CHOICE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"AUTOSCALE\" \"${WEBSERVER_SNAPSHOT_NAME}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"SNAPSHOTID\" \"${WEBSERVER_IMAGE_ID}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"SNAPAUTOSCALE\" \"1\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"KEYID\" \"${PUBLIC_KEY_ID}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDCLIENTIP\" \"${BUILD_CLIENT_IP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYPUBLICIP\" \"${ASIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYIP\" \"${ASIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIPS\" \"${ASIPS}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP_PRIVATES\" \"${ASIP_PRIVATES}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASPUBLICIP\" \"${ASIP}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP\" \"${ASIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBPUBLICIP\" \"${DBIP}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBIP\" \"${DBIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEINSTALLATIONTYPE\" \"${DATABASE_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSDBNAME\" \"${DBaaS_DBNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSUSERNAME\" \"${DBaaS_USERNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSPASSWORD\" \"${DBaaS_PASSWORD}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEDBaaSINSTALLATIONTYPE\" \"${DATABASE_DBaaS_INSTALLATION_TYPE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBPORT\" \"${DB_PORT}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DATABASEINSTALLATIONTYPE\" \"${DATABASE_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DBaaSDBNAME\" \"${DBaaS_DBNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DBaaSUSERNAME\" \"${DBaaS_USERNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DBaaSPASSWORD\" \"${DBaaS_PASSWORD}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DATABASEDBaaSINSTALLATIONTYPE\" \"${DATABASE_DBaaS_INSTALLATION_TYPE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DBPORT\" \"${DB_PORT}\""

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/RefreshNetworking.sh"

        #Reinitialise everything by rebooting the machine
        /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /sbin/shutdown -r now"

    done

    ########WEBSERVER config############

    #Wait until the webserver has been fully provisioned from its snapshot
    status "Trying to connect to the webserver to perform initialisation...."

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "exit"

    while ( [ "$?" != "0" ] )
    do
        /bin/sleep 10
        status "Still trying to connect to the webserver to perform initialisation...."
        /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "exit"
    done

    #Clean what we need to so that the configuration will reinitialise on the machine.
    #NETCONFIGURED removing that means that the private ip networking will be refreshed to reflect the new ip addresses
    #APPLICATION_DB_CONFIGURED removing that will mean that the database reinitialises for the new ip addresses and so on
    #SSHTUNNELCONFIGURED removing that will mean that the SSH tunneling will be reinitialised in the case where we use DBaaS
    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/runtime/NETCONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/APPLICATION_DB_CONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/APPLICATION_CONFIGURATION_PREPARED /home/${FULL_SNAPSHOT_ID}/runtime/*lock* /home/${FULL_SNAPSHOT_ID}/runtime/CONFIG-PRIMED"

    status "Connected to the webserver, now initialising it..."

    #Clean out the old shit. The ip addresses are all invalid now
#    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/rm /home/${FULL_SNAPSHOT_ID}/.ssh/*IP*"

    #Update ourselves with all our new ip addresses that have been assigned when we created the new servers from their snapshots
#    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDCLIENTIP:${BUILD_CLIENT_IP} /bin/touch /home/${FULL_SNAPSHOT_ID}/runtime/FIREWALL-REFRESH /home/${FULL_SNAPSHOT_ID}/.ssh/ASIP:${ASIP_PRIVATE} /home/${FULL_SNAPSHOT_ID}/.ssh/ASPUBLICIP:${ASIP} /home/${FULL_SNAPSHOT_ID}/.ssh/DBIP:${DBIP_PRIVATE} /home/${FULL_SNAPSHOT_ID}/.ssh/MYPUBLICIP:${WSIP} /home/${FULL_SNAPSHOT_ID}/.ssh/MYIP:${WSIP_PRIVATE} "

    #Refesh the networking. This means that the firewall needs to be reset and regenerated as the ip addresses have changed and also,
    #private networking can be refreshed here if the way that the provider is setup to be, requires it
#    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/RefreshNetworking.sh"

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDCLIENTIP\" \"${BUILD_CLIENT_IP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP\" \"${ASIP_PRIVATE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASPUBLICIP\" \"${ASIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBIP\" \"${DBIP_PRIVATE}\" ;  ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBPUBLICIP\" \"${DBIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYPUBLICIP\" \"${WSIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYIP\" \"${WSIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIPS\" \"${ASIPS}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP_PRIVATES\" \"${ASIP_PRIVATES}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEINSTALLATIONTYPE\" \"${DATABASE_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSDBNAME\" \"${DBaaS_DBNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSUSERNAME\" \"${DBaaS_USERNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSPASSWORD\" \"${DBaaS_PASSWORD}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEDBaaSINSTALLATIONTYPE\" \"${DATABASE_DBaaS_INSTALLATION_TYPE}\";${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBPORT\" \"${DB_PORT}\""

    #Refesh the networking. This means that the firewall needs to be reset and regenerated as the ip addresses have changed and also,
    #private networking can be refreshed here if the way that the provider is setup to be, requires it
    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/RefreshNetworking.sh"

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /sbin/shutdown -r now"


    #If we get to here then we know that the webserver was built correctly
    #We have to configure it some more and add it to the DNS provider's DNS so we can access the webserver
    #Please note, we make use of the implicit DNS loadbalancing system with our webservers
    name="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"

    #Create  zone if it doesn't already exist
    ${BUILD_HOME}/providerscripts/dns/CreateZone.sh "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${WEBSITE_URL}" "${DNS_CHOICE}" "${DNS_REGION}"

    status "We are adding our DNS records to the DNS provider you selected, in this case ${DNS_CHOICE}"
    zonename="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
    zoneid="`${BUILD_HOME}/providerscripts/dns/GetZoneID.sh "${zonename}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}"`"
    recordids="`${BUILD_HOME}/providerscripts/dns/GetAllRecordIDs.sh  "${zoneid}" "${WEBSITE_URL}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}"`"

    if ( [ "${recordids}" != "" ] )
    then
        for recordid in ${recordids}
        do
            ${BUILD_HOME}/providerscripts/dns/DeleteRecord.sh "${zoneid}" "${recordid}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}" "${WEBSITE_URL}"
        done
    fi

    #Add our record to the dns. Please note, proxying has to be off, but we need the ip address to be active with our DNS provider
    #provider. The reason why proxying is off is that the system we use to install SSL certificates does not work when proxying is on

    if ( [ "${DNS_REGION}" = "" ] )
    then
        DNS_REGION="FILLER"
    fi
    
    ${BUILD_HOME}/providerscripts/dns/AddRecord.sh "${zoneid}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${WEBSITE_URL}" "${WSIP}" "true" "${DNS_CHOICE}" "${DNS_REGION}" "${WEBSITE_URL}"

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /sbin/shutdown -r now"

    ##############DB config#################################

    #Wait until we are sure our DB machine has been provisioned from the snapshot
    status "Trying to connect to the database to perform initialisation...."
    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "exit"

    while ( [ "$?" != "0" ] )
    do
        /bin/sleep 10
        status "Still trying to connect to the database to perform initialisation...."
        /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "exit"
    done

    status "Connected to the database, now initialising it..."

    #Remove the aspect of the configuration that are stale
    #Removing NETCONFIGURED will refresh the networking
    #Removing the stale ip addresses will mean we can place our new ones there instead
    #Removing the BUILDARCHIVECHOICE means that we can choose a new build archive to use, (baseline, hourly and so on, specific to this build)

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/runtime/NETCONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/*lock* /home/${FULL_SNAPSHOT_ID}/runtime/CONFIG-PRIMED"

    #Refresh all our ip addresses and so on
#    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVECHOICE:${BUILD_ARCHIVE_CHOICE} /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDCLIENTIP:${BUILD_CLIENT_IP} /home/${FULL_SNAPSHOT_ID}/.ssh/ASIP:${ASIP_PRIVATE} /home/${FULL_SNAPSHOT_ID}/.ssh/ASPUBLICIP:${ASIP} /home/${FULL_SNAPSHOT_ID}/.ssh/MYPUBLICIP:${DBIP} /home/${FULL_SNAPSHOT_ID}/.ssh/MYIP:${DBIP_PRIVATE} /home/${FULL_SNAPSHOT_ID}/.ssh/WSIP:${WSIP_PRIVATE}"

   /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDCLIENTIP\" \"${BUILD_CLIENT_IP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDARCHIVECHOICE\" \"${BUILD_ARCHIVE_CHOICE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP\" \"${ASIP_PRIVATE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASPUBLICIP\" \"${ASIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYPUBLICIP\" \"${DBIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYIP\" \"${DBIP_PRIVATE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"WSIP\" \"${WSIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"WSPUBLICIP\" \"${WSIP}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIPS\" \"${ASIPS}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP_PRIVATES\" \"${ASIP_PRIVATES}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEINSTALLATIONTYPE\" \"${DATABASE_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSDBNAME\" \"${DBaaS_DBNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSUSERNAME\" \"${DBaaS_USERNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSPASSWORD\" \"${DBaaS_PASSWORD}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEDBaaSINSTALLATIONTYPE\" \"${DATABASE_DBaaS_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBPORT\" \"${DB_PORT}\""


    #This will refresh the private networking including the renewal of the firewall rules as the ip addresses have changed

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/RefreshNetworking.sh"

    #to refresh everything, reboot the machine
    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /sbin/shutdown -r now"

fi

#We are satisfied that all is well, so let's try and see if the application is actually online and active
#if ( [ "${DNS_CHOICE}" != "NONE" ] )
#then
#    status "Application has completed its initialisation, just checking that it is also online....."
#    /bin/sleep 60
#    serverinstalled="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/monitoring/CheckServerAlive.sh" 2>/dev/null`"
#    while ( [ "`/bin/echo ${serverinstalled} | /bin/grep ALIVE`" = "" ] )
#    do
#        serverinstalled="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/monitoring/CheckServerAlive.sh" 2>/dev/null`"
#        status "Application has completed its initialisation, just checking that it is also online....."
#        /bin/sleep 60
#    done
#fi

#Check that the configuration directory is mounted
#while ( [ "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/mount | /bin/grep '/home/${FULL_SNAPSHOT_ID}/config'"`" = "" ] )
#do
#    status "Waiting for the configuration directory to be mounted...."
#    /bin/sleep 30
#done

#Check that the configuration directory is mounted
#while ( [ "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/ls /home/${FULL_SNAPSHOT_ID}/config/credentials/shit"`" = "" ] )
#do
#    status "Waiting for the database credentials to be available...."
#    /bin/sleep 30
#done

. ${BUILD_HOME}/providerscripts/datastore/ConfirmCredentials.sh

while ( [ "${credentials_confirmed}" != "1" ] )
do
    status "Couldn't confirm database credentials, trying again....."
    . ${BUILD_HOME}/providerscripts/datastore/ConfirmCredentials.sh
    /bin/sleep 10
done


if ( [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
then
    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreDatabaseCredentials.sh \"${DBaaS_DBNAME}\" \"${DBaaS_PASSWORD}\" \"${DBaaS_USERNAME}\" "
fi

#We are satisfied that all is well, so let's try and see if the application is actually online and active
#if ( [ "${DNS_CHOICE}" != "NONE" ] )
#then
#    status "Application has completed its initialisation, just checking that it is also online....."
#    /bin/sleep 60
#    serverinstalled="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/monitoring/CheckServerAlive.sh" 2>/dev/null`"
#    while ( [ "`/bin/echo ${serverinstalled} | /bin/grep ALIVE`" = "" ] )
#    do
#        serverinstalled="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/monitoring/CheckServerAlive.sh" 2>/dev/null`"
#        status "Application has completed its initialisation, just checking that it is also online....."
#        /bin/sleep 60
#    done
#fi

# A snapshot might have been made weeks ago and there's been some application modifications or new data is in the database.
# We want to sync, therefore with our latest db backups and repos. Note if the snapshot is generated during a baseline build
# then, when we rerun the config process, we need to select an hourly backup, for example, to sync here with our hourly backup repo/db
#/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/rm /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVECHOICE:*"
#/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVECHOICE:${BUILD_ARCHIVE_CHOICE}"
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDARCHIVECHOICE\" \"${BUILD_ARCHIVE_CHOICE}\""
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/applicationscripts/SyncLatestApplication.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${BUILD_ARCHIVE_CHOICE} ${DATASTORE_CHOICE} ${BUILD_IDENTIFIER} ${WEBSITE_NAME}"

#/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/rm /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVECHOICE:*"
#/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVECHOICE:${BUILD_ARCHIVE_CHOICE}"
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDARCHIVECHOICE\" \"${BUILD_ARCHIVE_CHOICE}\""
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/applicationdb/InstallApplicationDB.sh force"


status "Performing any post processing that is needed for your application. This may take a little while depending on your application, Please wait...."
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/processing/PerformPostProcessingByApplication.sh ${FULL_SNAPSHOT_ID}"

#We are satisfied that all is well, so let's try and see if the application is actually online and active
if ( [ "${DNS_CHOICE}" != "NONE" ] )
then
    status "Application has completed its initialisation, just checking that it is also online....."
    /bin/sleep 60
    serverinstalled="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/monitoring/CheckServerAlive.sh" 2>/dev/null`"
    while ( [ "`/bin/echo ${serverinstalled} | /bin/grep ALIVE`" = "" ] )
    do
        serverinstalled="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/monitoring/CheckServerAlive.sh" 2>/dev/null`"
        status "Application has completed its initialisation, just checking that it is also online....."
        /bin/sleep 60
    done
fi

/usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/config/autoscalerip/* /home/${FULL_SNAPSHOT_ID}/config/autoscalerpublicip/* /home/${FULL_SNAPSHOT_ID}/config/beingbuiltips/* /home/${FULL_SNAPSHOT_ID}/config/bootedwebserverips/* /home/${FULL_SNAPSHOT_ID}/config/databaseip/* /home/${FULL_SNAPSHOT_ID}/config/databasepublicip/* /home/${FULL_SNAPSHOT_ID}/config/lowcpuaudit/* /home/${FULL_SNAPSHOT_ID}/config/lowdiskaudit/* /home/${FULL_SNAPSHOT_ID}/config/lowmemoryaudit/* /home/${FULL_SNAPSHOT_ID}/config/shuttingdownwebserverips/* /home/${FULL_SNAPSHOT_ID}/config/webrootsynctunnel/* /home/${FULL_SNAPSHOT_ID}/config/webserverips/* /home/${FULL_SNAPSHOT_ID}/config/webserverpublicips/* /home/${FULL_SNAPSHOT_ID}/runtime/*lock*"

#Refresh the native firewalling system
for ip in ${ASIPS}
do
    /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${ip} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/runtime/FIREWALL-REFRESH"
done

#Tell our infrastructure, 'yes, I am happy that you are up and running and functioning correctly'. Other
#scripts can then check if the build has completed before any action is taken
#/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/config/INSTALLEDSUCCESSFULLY"

#Allow synctunnel to become active
#/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/config/ENABLESYNCTUNNEL"

${BUILD_HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${WEBSITE_URL} INSTALLEDSUCCESSFULLY INSTALLEDSUCCESSFULLY
${BUILD_HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${WEBSITE_URL} ENABLESYNCTUNNEL ENABLESYNCTUNNEL


# If we got to here then we really are doing quite well and we can assume that the environment is Ok to use next
# time around, so dump it to a config file

#################################################################################################################
#If you are a developer and you modify these scripts, you will need to update the envdump.dat file below
#with the variables you have added
#################################################################################################################

/bin/rm ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}

while read line
do
    name="`/bin/echo ${line} | /usr/bin/awk -F':' '{print $1}'`"
    value="`/bin/echo ${line} | /usr/bin/awk -F':' '{print $NF}'`"
    value="`eval /bin/echo ${value}`"
    /bin/echo "export ${name}=\"${value}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
done < ${BUILD_HOME}/builddescriptors/envdump.dat
#!/bin/sh
#####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This will build machines from pre existing snapshots held with your
# cloudhost. The cloudhost has to support snapshots and snapshots are identified
# uniquely so that they can be provisioned. From a deployer perspective, the environment
# still needs to be re-primed or at least reviews as, for example, you might require
# that the machine sizes are different to what they were when the snapshots were generated
# Also, you may require to use a different repo, an hourly backup build deployment
# when you may have built off a baseline in the build the snapshots were generated from.
# NOTE THEN: The enviroment is fully re-primed or reviewed for a snapshot deployment, but
# only a small subset of specific environment variables are actually actively renewed
# when deployed from a snapshot, otherwise, the enviroment is considered to be the same
# as when the snapshots were generated, for example, same username and password for
# the user that we sudo from as were in the original and so on.
#####################################################################################
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
######################################################################################
######################################################################################
#set -x

OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "

if ( [ "${AUTOSCALER_IMAGE_ID}" != "" ] && [ "${WEBSERVER_IMAGE_ID}" != "" ] && [ "${DATABASE_IMAGE_ID}" != "" ] )
then
    status "#########################BUILD FROM SNAPSHOTS#######################"
    status ""
    
    #. ${BUILD_HOME}/providerscripts/datastore/PurgeDatastore.sh "reset"

    . ${BUILD_HOME}/providerscripts/datastore/PurgeDatastore.sh

    #Generate the snapshot of the autoscaler. We use the username as the identifier as that will remain constant between
    #the original machine and the generated snapshot
    RND="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1`"
    FULL_SNAPSHOT_ID="`/bin/ls ${BUILD_HOME}/snapshots | /bin/grep ${SNAPSHOT_ID}`"

    no_autoscalers="0"
    while ( [ "${no_autoscalers}" -lt "${NO_AUTOSCALERS}" ] )
    do
       status "#######################################################################################################"
       status "Building autoscaler `/usr/bin/expr ${no_autoscalers} + 1` of ${NO_AUTOSCALERS} autoscalers"

        autoscaler_name="autoscaler-${RND}-${WEBSITE_NAME}-${BUILD_IDENTIFIER}"
        autoscaler_name="`/bin/echo ${no_autoscalers}-${autoscaler_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"

        #Find out what operating system we are building for
        OS_TYPE="`${BUILD_HOME}/providerscripts/cloudhost/GetOperatingSystemVersion.sh ${AS_SIZE} ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"

        if ( [ "${SUBNET_ID}" = "" ] )
        then
            SUBNET_ID="FILLER"
        fi

        #Actually create the server from the snapshot. Note that the image id of the snapshot we want to build from is passed in as the
        #last parameter
        ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${OS_TYPE}" "${REGION_ID}" "${AS_SERVER_TYPE}" "${autoscaler_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} "${SUBNET_ID}" "${AUTOSCALER_IMAGE_ID}" 1>/dev/null 2>/dev/null
    
    
        #Get the ip addresses of the server we have just built
        ip=""
        private_ip=""
        count="0"
        while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "20" ] )
        do
            status "Interrogating for autoscaler ip addresses....."
            ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${autoscaler_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
            private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${autoscaler_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
            /bin/sleep 30
            count="`/usr/bin/expr ${count} + 1`"
        done

        status "It looks like the machine has booted OK"
        ASIP=${ip}
        ASIP_PRIVATE=${private_ip}

        status "Have got the ip addresses for your autoscaler"
        status "Public IP address: ${ASIP}"
        status "Private IP address: ${ASIP_PRIVATE}"

        #record the server ip address(es)
        /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASIP:*
        /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASPRIVATEIP:*
        /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASIP:${ASIP}
        /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASPRIVATEIP:${ASIP_PRIVATE}


        #We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
        #So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
        #We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
        /bin/echo "Host ${ASIP}" >> ~/.ssh/config
        /bin/echo "IdentityFile ~/.ssh/${FULL_SNAPSHOT_ID}.key" >> ~/.ssh/config
        /bin/echo "IdentitiesOnly yes" >> ~/.ssh/config
        no_autoscalers="`/usr/bin/expr ${no_autoscalers} + 1`"
    done
    
    ASIPS="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "*autoscaler*" ${CLOUDHOST} | /bin/grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | /bin/tr '\n' ':' | /bin/sed 's/\:$//g'`"
    ASIP_PRIVATES="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "*autoscaler*" ${CLOUDHOST} | /bin/grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | /bin/tr '\n' ':' | /bin/sed 's/\:$//g'`"
    ASIPS_CLEANED="`/bin/echo ${ASIPS} | /bin/sed 's/\:/ /g'`"
    
    status "#########################################################################################################"

    #Generate the webserver snapshot. Again, we use the username to create the identifier of the machine as this will remain
    #the same between the original machine and the machine built from a snapshot
    webserver_name="webserver-${RND}-${WEBSITE_NAME}-${BUILD_IDENTIFIER}"
    webserver_name="`/bin/echo ${webserver_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"

    #Build the machine from the snapshot. The snapshot image id is passed in as the final parameter
    ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${OS_TYPE}" "${REGION_ID}" "${WS_SERVER_TYPE}" "${webserver_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} "${SUBNET_ID}" "${WEBSERVER_IMAGE_ID}" 1>/dev/null 2>/dev/null

    #Get the ip addresses of the server we have just built
    ip=""
    private_ip=""
    count="0"
    while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "10" ] )
    do
        status "Interrogating for webserver ip addresses....."
        ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${webserver_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
        private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${webserver_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
        /bin/sleep 30
        count="`/usr/bin/expr ${count} + 1`"
    done

    status "It looks like the machine has booted OK"
    WSIP=${ip}
    WSIP_PRIVATE=${private_ip}

    status "Have got the ip addresses for your webserver"
    status "Public IP address: ${WSIP}"
    status "Private IP address: ${WSIP_PRIVATE}"

    #record the server ip address(es)
    /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/WSIP:*
    /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/WSPRIVATEIP:*
    /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/WSIP:${WSIP}
    /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/WSPRIVATEIP:${WSIP_PRIVATE}

    #We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
    #So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
    #We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
    /bin/echo "Host ${WSIP}" >> ~/.ssh/config
    /bin/echo "IdentityFile ~/.ssh/${FULL_SNAPSHOT_ID}.key" >> ~/.ssh/config
    /bin/echo "IdentitiesOnly yes" >> ~/.ssh/config
    
    status "#########################################################################################################"


    # generate the database snapshot. The username is used to create the identifier as it will remain consistent between the original machine
    # and the machine generated from a snapshot
    database_name="database-${RND}-${WEBSITE_NAME}-${BUILD_IDENTIFIER}"
    database_name="`/bin/echo ${database_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"
    ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${OS_TYPE}" "${REGION_ID}" "${DB_SERVER_TYPE}" "${database_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} "${SUBNET_ID}" "${DATABASE_IMAGE_ID}" 1>/dev/null 2>/dev/null

    #Get the ip addresses of the server we have just built
    ip=""
    private_ip=""
    count="0"
    while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "10" ] )
    do
        status "Interrogating for database ip addresses....."
        ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${database_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
        private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${database_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
        /bin/sleep 30
        count="`/usr/bin/expr ${count} + 1`"
    done

    status "It looks like the machine has booted OK"
    DBIP=${ip}
    DBIP_PRIVATE=${private_ip}

    status "Have got the ip addresses for your database"
    status "Public IP address: ${DBIP}"
    status "Private IP address: ${DBIP_PRIVATE}"

    #record the server ip address(es)
    /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBIP:*
    /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBPRIVATEIP:*
    /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBIP:${DBIP}
    /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBPRIVATEIP:${DBIP_PRIVATE}

    #We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
    #So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
    #We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
    /bin/echo "Host ${DBIP}" >> ~/.ssh/config
    /bin/echo "IdentityFile ~/.ssh/${FULL_SNAPSHOT_ID}.key" >> ~/.ssh/config
    /bin/echo "IdentitiesOnly yes" >> ~/.ssh/config

    #Remember the keys and config settings for use when we deploy these from these snapshots. The build process will try
    #and use new keys but we'll say, 'no you don't, you have to use the ones we recorded earlier'.

    /bin/mv  ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}  ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.$$

    /bin/cp ${BUILD_HOME}/snapshots/${FULL_SNAPSHOT_ID}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}

    /bin/mv  ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub  ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub.$$

    /bin/cp ${BUILD_HOME}/snapshots/${FULL_SNAPSHOT_ID}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub

    /bin/mv ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials.$$

    /bin/cp -r ${BUILD_HOME}/snapshots/${FULL_SNAPSHOT_ID}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/

    SERVER_USER_PASSWORD="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSERPASSWORD`"

    SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

    ########AUTOSCALER config#################
        
    for ASIP in ${ASIPS_CLEANED}
    do
       
        #Wait until the autoscaler has been fully provisioned from its snapshot

        status "Trying to connect to the autoscaler to perform initialisation...."

        /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "exit"

        while ( [ "$?" != "0" ] )
        do
            /bin/sleep 10
            status "Still trying to connect to the autoscaler to perform initialisation...."
            /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "exit"
        done

        status "Connected to the autoscaler, now initialising it..."

        #There might be some stuff on the autoscaler which is from the build when the snapshots were generated, like IP addresses and so on, so
        #clear them out as they have now been changed/renewed

    #    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVE:* /home/${FULL_SNAPSHOT_ID}/.ssh/KEYID:* /home/${FULL_SNAPSHOT_ID}/.ssh/SNAPAUTOSCALE:* /home/${FULL_SNAPSHOT_ID}/config/INSTALLEDSUCCESSFULLY /home/${FULL_SNAPSHOT_ID}/runtime/INITIALCONFIGSET /home/${FULL_SNAPSHOT_ID}/runtime/NETCONFIGURED /home/${FULL_SNAPSHOT_ID}/config/APPLICATION_DB_CONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/*lock* ${HOME}/runtime/INITIALCONFIGSET"


        #swap out the ip addresses that were from the preceeding build and update them with the new ones for our newly provisioned machines
    #    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/rm /home/${FULL_SNAPSHOT_ID}/.ssh/*IP*"

    #    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVE:${BUILD_ARCHIVE_CHOICE} /home/${FULL_SNAPSHOT_ID}/.ssh/AUTOSCALE:${WEBSERVER_SNAPSHOT_NAME} /home/${FULL_SNAPSHOT_ID}/.ssh/SNAPSHOTID:${WEBSERVER_IMAGE_ID} /home/${FULL_SNAPSHOT_ID}/.ssh/SNAPAUTOSCALE:1 /home/${FULL_SNAPSHOT_ID}/.ssh/KEYID:${PUBLIC_KEY_ID} /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDCLIENTIP:${BUILD_CLIENT_IP} /home/${FULL_SNAPSHOT_ID}/.ssh/MYPUBLICIP:${ASIP} /home/${FULL_SNAPSHOT_ID}/.ssh/MYIP:${ASIP_PRIVATE}"

    #    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/RefreshNetworking.sh"

        #Reinitialise everything by rebooting the machine
    #    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /sbin/shutdown -r now"

        /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/config/INSTALLEDSUCCESSFULLY /home/${FULL_SNAPSHOT_ID}/runtime/INITIALCONFIGSET /home/${FULL_SNAPSHOT_ID}/runtime/NETCONFIGURED /home/${FULL_SNAPSHOT_ID}/config/APPLICATION_DB_CONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/*lock*"

        /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDARCHIVE\" \"${BUILD_ARCHIVE_CHOICE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"AUTOSCALE\" \"${WEBSERVER_SNAPSHOT_NAME}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"SNAPSHOTID\" \"${WEBSERVER_IMAGE_ID}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"SNAPAUTOSCALE\" \"1\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"KEYID\" \"${PUBLIC_KEY_ID}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDCLIENTIP\" \"${BUILD_CLIENT_IP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYPUBLICIP\" \"${ASIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYIP\" \"${ASIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIPS\" \"${ASIPS}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP_PRIVATES\" \"${ASIP_PRIVATES}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASPUBLICIP\" \"${ASIP}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP\" \"${ASIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBPUBLICIP\" \"${DBIP}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBIP\" \"${DBIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEINSTALLATIONTYPE\" \"${DATABASE_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSDBNAME\" \"${DBaaS_DBNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSUSERNAME\" \"${DBaaS_USERNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSPASSWORD\" \"${DBaaS_PASSWORD}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEDBaaSINSTALLATIONTYPE\" \"${DATABASE_DBaaS_INSTALLATION_TYPE}\""

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/RefreshNetworking.sh"

        #Reinitialise everything by rebooting the machine
        /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /sbin/shutdown -r now"

    done

    ########WEBSERVER config############

    #Wait until the webserver has been fully provisioned from its snapshot
    status "Trying to connect to the webserver to perform initialisation...."

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "exit"

    while ( [ "$?" != "0" ] )
    do
        /bin/sleep 10
        status "Still trying to connect to the webserver to perform initialisation...."
        /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "exit"
    done

    #Clean what we need to so that the configuration will reinitialise on the machine.
    #NETCONFIGURED removing that means that the private ip networking will be refreshed to reflect the new ip addresses
    #APPLICATION_DB_CONFIGURED removing that will mean that the database reinitialises for the new ip addresses and so on
    #SSHTUNNELCONFIGURED removing that will mean that the SSH tunneling will be reinitialised in the case where we use DBaaS
    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/runtime/NETCONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/APPLICATION_DB_CONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/APPLICATION_CONFIGURATION_PREPARED /home/${FULL_SNAPSHOT_ID}/runtime/*lock*"

    status "Connected to the webserver, now initialising it..."

    #Clean out the old shit. The ip addresses are all invalid now
#    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/rm /home/${FULL_SNAPSHOT_ID}/.ssh/*IP*"

    #Update ourselves with all our new ip addresses that have been assigned when we created the new servers from their snapshots
#    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDCLIENTIP:${BUILD_CLIENT_IP} /bin/touch /home/${FULL_SNAPSHOT_ID}/runtime/FIREWALL-REFRESH /home/${FULL_SNAPSHOT_ID}/.ssh/ASIP:${ASIP_PRIVATE} /home/${FULL_SNAPSHOT_ID}/.ssh/ASPUBLICIP:${ASIP} /home/${FULL_SNAPSHOT_ID}/.ssh/DBIP:${DBIP_PRIVATE} /home/${FULL_SNAPSHOT_ID}/.ssh/MYPUBLICIP:${WSIP} /home/${FULL_SNAPSHOT_ID}/.ssh/MYIP:${WSIP_PRIVATE} "

    #Refesh the networking. This means that the firewall needs to be reset and regenerated as the ip addresses have changed and also,
    #private networking can be refreshed here if the way that the provider is setup to be, requires it
#    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/RefreshNetworking.sh"

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDCLIENTIP\" \"${BUILD_CLIENT_IP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP\" \"${ASIP_PRIVATE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASPUBLICIP\" \"${ASIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBIP\" \"${DBIP_PRIVATE}\" ;  ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBPUBLICIP\" \"${DBIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYPUBLICIP\" \"${WSIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYIP\" \"${WSIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIPS\" \"${ASIPS}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP_PRIVATES\" \"${ASIP_PRIVATES}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEINSTALLATIONTYPE\" \"${DATABASE_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSDBNAME\" \"${DBaaS_DBNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSUSERNAME\" \"${DBaaS_USERNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSPASSWORD\" \"${DBaaS_PASSWORD}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEDBaaSINSTALLATIONTYPE\" \"${DATABASE_DBaaS_INSTALLATION_TYPE}\""
   

    #Refesh the networking. This means that the firewall needs to be reset and regenerated as the ip addresses have changed and also,
    #private networking can be refreshed here if the way that the provider is setup to be, requires it
    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/RefreshNetworking.sh"

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /sbin/shutdown -r now"


    #If we get to here then we know that the webserver was built correctly
    #We have to configure it some more and add it to the DNS provider's DNS so we can access the webserver
    #Please note, we make use of the implicit DNS loadbalancing system with our webservers
    name="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"

    #Create  zone if it doesn't already exist
    ${BUILD_HOME}/providerscripts/dns/CreateZone.sh "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${WEBSITE_URL}" "${DNS_CHOICE}" "${DNS_REGION}"

    status "We are adding our DNS records to the DNS provider you selected, in this case ${DNS_CHOICE}"
    zonename="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
    zoneid="`${BUILD_HOME}/providerscripts/dns/GetZoneID.sh "${zonename}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}"`"
    recordids="`${BUILD_HOME}/providerscripts/dns/GetAllRecordIDs.sh  "${zoneid}" "${WEBSITE_URL}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}"`"

    if ( [ "${recordids}" != "" ] )
    then
        for recordid in ${recordids}
        do
            ${BUILD_HOME}/providerscripts/dns/DeleteRecord.sh "${zoneid}" "${recordid}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}" "${WEBSITE_URL}"
        done
    fi

    #Add our record to the dns. Please note, proxying has to be off, but we need the ip address to be active with our DNS provider
    #provider. The reason why proxying is off is that the system we use to install SSL certificates does not work when proxying is on

    if ( [ "${DNS_REGION}" = "" ] )
    then
        DNS_REGION="FILLER"
    fi
    
    ${BUILD_HOME}/providerscripts/dns/AddRecord.sh "${zoneid}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${WEBSITE_URL}" "${WSIP}" "true" "${DNS_CHOICE}" "${DNS_REGION}" "${WEBSITE_URL}"

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /sbin/shutdown -r now"

    ##############DB config#################################

    #Wait until we are sure our DB machine has been provisioned from the snapshot
    status "Trying to connect to the database to perform initialisation...."
    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "exit"

    while ( [ "$?" != "0" ] )
    do
        /bin/sleep 10
        status "Still trying to connect to the database to perform initialisation...."
        /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "exit"
    done

    status "Connected to the database, now initialising it..."

    #Remove the aspect of the configuration that are stale
    #Removing NETCONFIGURED will refresh the networking
    #Removing the stale ip addresses will mean we can place our new ones there instead
    #Removing the BUILDARCHIVECHOICE means that we can choose a new build archive to use, (baseline, hourly and so on, specific to this build)

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/runtime/NETCONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/*lock*"

    #Refresh all our ip addresses and so on
#    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVECHOICE:${BUILD_ARCHIVE_CHOICE} /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDCLIENTIP:${BUILD_CLIENT_IP} /home/${FULL_SNAPSHOT_ID}/.ssh/ASIP:${ASIP_PRIVATE} /home/${FULL_SNAPSHOT_ID}/.ssh/ASPUBLICIP:${ASIP} /home/${FULL_SNAPSHOT_ID}/.ssh/MYPUBLICIP:${DBIP} /home/${FULL_SNAPSHOT_ID}/.ssh/MYIP:${DBIP_PRIVATE} /home/${FULL_SNAPSHOT_ID}/.ssh/WSIP:${WSIP_PRIVATE}  "

   /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDCLIENTIP\" \"${BUILD_CLIENT_IP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDARCHIVECHOICE\" \"${BUILD_ARCHIVE_CHOICE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP\" \"${ASIP_PRIVATE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASPUBLICIP\" \"${ASIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYPUBLICIP\" \"${DBIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYIP\" \"${DBIP_PRIVATE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"WSIP\" \"${WSIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"WSPUBLICIP\" \"${WSIP}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIPS\" \"${ASIPS}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP_PRIVATES\" \"${ASIP_PRIVATES}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEINSTALLATIONTYPE\" \"${DATABASE_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSDBNAME\" \"${DBaaS_DBNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSUSERNAME\" \"${DBaaS_USERNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSPASSWORD\" \"${DBaaS_PASSWORD}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEDBaaSINSTALLATIONTYPE\" \"${DATABASE_DBaaS_INSTALLATION_TYPE}\""
   

    #This will refresh the private networking including the renewal of the firewall rules as the ip addresses have changed

    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/RefreshNetworking.sh"

    #to refresh everything, reboot the machine
    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /sbin/shutdown -r now"

fi

#We are satisfied that all is well, so let's try and see if the application is actually online and active
if ( [ "${DNS_CHOICE}" != "NONE" ] )
then
    status "Application has completed its initialisation, just checking that it is also online....."
    /bin/sleep 60
    serverinstalled="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/monitoring/CheckServerAlive.sh" 2>/dev/null`"
    while ( [ "`/bin/echo ${serverinstalled} | /bin/grep ALIVE`" = "" ] )
    do
        serverinstalled="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/monitoring/CheckServerAlive.sh" 2>/dev/null`"
        status "Application has completed its initialisation, just checking that it is also online....."
        /bin/sleep 60
    done
fi

#Check that the configuration directory is mounted
while ( [ "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/mount | /bin/grep '/home/${FULL_SNAPSHOT_ID}/config'"`" = "" ] )
do
    status "Wating for the configuration directory to be mounted...."
    /bin/sleep 30
done

#Check that the configuration directory is mounted
while ( [ "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/ls /home/${FULL_SNAPSHOT_ID}/config/credentials/shit"`" = "" ] )
do
    status "Wating for the database credentials to be available...."
    /bin/sleep 30
done

if ( [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
then
    /usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreDatabaseCredentials.sh \"${DBaaS_DBNAME}\" \"${DBaaS_PASSWORD}\" \"${DBaaS_USERNAME}\" "
fi

# A snapshot might have been made weeks ago and there's been some application modifications or new data is in the database.
# We want to sync, therefore with our latest db backups and repos. Note if the snapshot is generated during a baseline build
# then, when we rerun the config process, we need to select an hourly backup, for example, to sync here with our hourly backup repo/db
#/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/rm /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVECHOICE:*"
#/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVECHOICE:${BUILD_ARCHIVE_CHOICE}"
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDARCHIVECHOICE\" \"${BUILD_ARCHIVE_CHOICE}\""
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/applicationscripts/SyncLatestApplication.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${BUILD_ARCHIVE_CHOICE} ${DATASTORE_CHOICE} ${BUILD_IDENTIFIER} ${WEBSITE_NAME}"

#/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/rm /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVECHOICE:*"
#/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/.ssh/BUILDARCHIVECHOICE:${BUILD_ARCHIVE_CHOICE}"
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDARCHIVECHOICE\" \"${BUILD_ARCHIVE_CHOICE}\""
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /home/${FULL_SNAPSHOT_ID}/applicationdb/InstallApplicationDB.sh force"



/usr/bin/ssh -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/config/autoscalerip/* /home/${FULL_SNAPSHOT_ID}/config/autoscalerpublicip/* /home/${FULL_SNAPSHOT_ID}/config/beingbuiltips/* /home/${FULL_SNAPSHOT_ID}/config/bootedwebserverips/* /home/${FULL_SNAPSHOT_ID}/config/databaseip/* /home/${FULL_SNAPSHOT_ID}/config/databasepublicip/* /home/${FULL_SNAPSHOT_ID}/config/lowcpuaudit/* /home/${FULL_SNAPSHOT_ID}/config/lowdiskaudit/* /home/${FULL_SNAPSHOT_ID}/config/lowmemoryaudit/* /home/${FULL_SNAPSHOT_ID}/config/shuttingdownwebserverips/* /home/${FULL_SNAPSHOT_ID}/config/webrootsynctunnel/* /home/${FULL_SNAPSHOT_ID}/config/webserverips/* /home/${FULL_SNAPSHOT_ID}/config/webserverpublicips/* /home/${FULL_SNAPSHOT_ID}/runtime/*lock*"

#Refresh the native firewalling system
for ip in ${ASIPS}
do
    /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${ip} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/runtime/FIREWALL-REFRESH"
done

#Tell our infrastructure, 'yes, I am happy that you are up and running and functioning correctly'. Other
#scripts can then check if the build has completed before any action is taken
#/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/config/INSTALLEDSUCCESSFULLY"

#Allow synctunnel to become active
#/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${FULL_SNAPSHOT_ID}@${ASIP} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/config/ENABLESYNCTUNNEL"

${BUILD_HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${WEBSITE_URL} INSTALLEDSUCCESSFULLY INSTALLEDSUCCESSFULLY
${BUILD_HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${WEBSITE_URL} ENABLESYNCTUNNEL ENABLESYNCTUNNEL


# If we got to here then we really are doing quite well and we can assume that the environment is Ok to use next
# time around, so dump it to a config file

#################################################################################################################
#If you are a developer and you modify these scripts, you will need to update the envdump.dat file below
#with the variables you have added
#################################################################################################################

/bin/rm ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}

while read line
do
    name="`/bin/echo ${line} | /usr/bin/awk -F':' '{print $1}'`"
    value="`/bin/echo ${line} | /usr/bin/awk -F':' '{print $NF}'`"
    value="`eval /bin/echo ${value}`"
    /bin/echo "export ${name}=\"${value}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
done < ${BUILD_HOME}/builddescriptors/envdump.dat
