#!/bin/bash
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2016
# Description : This is the script which will build a functioning webserver. It contains
# all the configuration settings and remote calls to the webserver we are building to ensure
# that it is built correctly and functions as it is supposed to.
# These scripts look more complicated than they really are. All that is happening is we are
# copying over some files to our new autoscaler and executing a few commands (mostly to
# install software) remotely on the autoscaler.
########################################################################################
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
#########################################################################################
#########################################################################################
#set -x
done=0
counter="0"
count="0"

status ""
status ""
status ""
status "#########################WEBSERVER#######################"

#These are the options that we want to use to connect to the remote server. Using a variable for them keeps our code cleaner
#and simpler and also if we want to change a parameter globally, we can change it here and it will change throughout
OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "

if ( [ "${DEFAULT_USER}" = "root" ] )
then
    SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
else
    SUDO="DEBIAN_FRONTEND=noninteractive /usr/bin/sudo -S -E "
fi

CUSTOM_USER_SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

status ""
status ""
status ""
status ""
status "========================================================="
status "=================BUILDING WEBSERVER======================"
status "========================================================="

status "Logging for this server build is located at ${BUILD_HOME}/logs/${OUT_FILE}"
status "The error stream for this server build is located at ${BUILD_HOME}/logs/${ERR_FILE}"
status "========================================================="

ASIPS="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "*autoscaler*" ${CLOUDHOST} | /bin/grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | /bin/tr '\n' ':' | /bin/sed 's/\:$//g'`"

#If "done" is set to 1, then we know that a webserver has been successfully built and is running.
#Try up to 5 times if the webserver is failing to complete its build
while ( [ "${done}" != "1" ] && [ "${counter}" -lt "5" ] )
do
    counter="`/usr/bin/expr ${counter} + 1`"
    status "OK... Building a webserver. This is the ${counter} attempt of 5"
    WEBSITE_IDENTIFIER="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`"

    #Check if there is a webserver already running. If there is, then skip building the webserver
    if ( [ "`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "webserver" ${CLOUDHOST} 2>/dev/null`" -eq "0" ] )
    then
        ip=""
        #Construct a unique name for this webserver
        RND="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1`"

        webserver_name="webserver-${RND}-${WEBSITE_NAME}-${BUILD_IDENTIFIER}"
        webserver_name="`/bin/echo ${webserver_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"
        
        #What OS type are we building for. Currently, only ubuntu is supported
        
        if ( [ "${OS_TYPE}" = "" ] )
        then
            ostype="`${BUILD_HOME}/providerscripts/cloudhost/GetOperatingSystemVersion.sh ${WS_SIZE} ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"
        else
            ostype="${OS_TYPE}"
        fi

        status "Initialising a new server machine, please wait......"

        #Actually start the server machine. Following this, there will be an active machine instance running on your cloud provider
        ${BUILD_HOME}/providerscripts/server/CreateServer.sh "'${ostype}'" "${REGION_ID}" "${WS_SERVER_TYPE}" "${webserver_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} ${SUBNET_ID} ${WEBSERVER_IMAGE_ID}

        #Keep trying if the first time wasn't successful
        while ( [ "$?" != "0" ] )
        do
            ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${ostype}" "${REGION_ID}" "${WS_SERVER_TYPE}" "${webserver_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} ${SUBNET_ID} ${WEBSERVER_IMAGE_ID}
        done

        #Check that the server has been assigned its IP addresses and that they are active
        ip=""
        private_ip=""
        count="0"

        #Keep trying until we get the ip addresses of our new machine, both public and private ips
        while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) || [ "${ip}" = "0.0.0.0" ] && [ "${count}" -lt "20" ] )
        do
            ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${webserver_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
            private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${webserver_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
            /bin/sleep 10
            count="`/usr/bin/expr ${count} + 1`"
        done

        WSIP=${ip}
        WSIP_PRIVATE=${private_ip}

        status "Have got the ip addresses for your webserver"
        status "Public IP address: ${WSIP}"
        status "Private IP address: ${WSIP_PRIVATE}"

        #Persist our new ip addresses on our filesystem for later usage
        /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/WSIP:*
        /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/WSPRIVATEIP:*

        /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/WSIP:${WSIP}
        /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/WSPRIVATEIP:${WSIP_PRIVATE}
        
        IP_TO_ALLOW="${WSIP}"
        . ${BUILD_HOME}/providerscripts/server/AllowDBAccess.sh
        . ${BUILD_HOME}/providerscripts/server/AllowCachingAccess.sh


        #We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
        #So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
        #We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
        /bin/echo "Host ${WSIP}" >> ~/.ssh/config
        /bin/echo "IdentityFile ~/.ssh/${SERVER_USER}.key" >> ~/.ssh/config
        /bin/echo "IdentitiesOnly yes" >> ~/.ssh/config

        #Test to see if we can connect to our machine with our ssh key
        #If we can't connect with out ssh keys, we will try with a text based username and password. If that works we will later
        #harden ourselves by blocking password based and root authentication and enforce the use of our ssh keys
        loop="0"
        connected="0"
        while ( [ "${loop}" -lt "3" ] )
        do
            /usr/bin/ssh ${OPTIONS} -o "PasswordAuthentication=no" ${DEFAULT_USER}@${ip} 'DEBIAN_FRONTEND=noninteractive exit'
            if ( [ "$?" = "0" ] )
            then
                connected="1"
                break
            fi
            loop="`/usr/bin/expr ${loop} + 1`"
            /bin/sleep 10
        done

        #If it is not possible, then possibly the provider requires password authentication in the first instance, which we can use
        #here to get going and then switch off in favour of ssh keys
        if ( [ "${connected}" != "1" ] )
        then
            connected="0"
            loop="0"

            if ( [ "${CLOUDHOST_PASSWORD}" != "" ] )
            then
                /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} 'DEBIAN_FRONTEND=noninteractive exit'

                if ( [ "$?" = "0" ] )
                then
                    connected="1"
                fi

                #Keep trying in case there is some "holdup" with the server coming on line
                while ( [ "${connected}" = "0" ] && [ "${loop}" -lt "10" ] )
                do
                    status "Haven't successfully connected to the Webserver, maybe it is still initialising, trying again...."
                    /bin/sleep 5
                    loop="`/usr/bin/expr ${loop} + 1`"
                    /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} 'DEBIAN_FRONTEND=noninteractive exit'

                    if ( [ "$?" = "0" ] )
                    then
                        connected="1"
                    fi
                done
            else
                status "Failed to connect to webserver, cloudhost password not set"
                exit
            fi


            if ( [ "${connected}" != "1" ] )
            then
                status "Sorry could not connect to the webserver. This might be due to provider networking issues. Please investigate..."
                exit
            fi


            #If we are here then we had to use password based authentication, so the next thing to do is setup our ssh keys and

            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/mkdir -p /home/${SERVER_USER}/.ssh"
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/mkdir /root/.ssh"
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/chmod 700 /home/${SERVER_USER}/.ssh"
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/chmod 700 /root/.ssh"

            #Make sure that we can use the ssh key in the future
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ${CLOUDHOST_USERNAME}@${ip}:/root/.ssh/authorized_keys
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ${CLOUDHOST_USERNAME}@${ip}:/home/${SERVER_USER}/.ssh/authorized_keys
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} -o "PasswordAuthentication=no" ${CLOUDHOST_USERNAME}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/mkdir -p /home/${SERVER_USER}/.ssh"
        else
            #If we are here, then, we are using our ssh keys for authentication. Do the same thing as we did for the password based authentication
            #so that our server knows our keys implicitly.
            /usr/bin/ssh ${OPTIONS} -o "PasswordAuthentication=no" ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive ${SUDO} /bin/sh -c '/bin/mkdir -p /home/${SERVER_USER}/.ssh ; /bin/chmod 700 /home/${SERVER_USER}/.ssh ; /bin/chmod 700 /root/.ssh ; /bin/chown -R ${SERVER_USER}:${SERVER_USER} /home/${SERVER_USER}'"
            /bin/cat ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub | /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "${SUDO} /bin/cat - >> /root/.ssh/authorized_keys"
            /bin/cat ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub | /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "${SUDO} /bin/chmod 777 /home/${DEFAULT_USER}/.ssh ; /bin/cat - >> /home/${DEFAULT_USER}/.ssh/authorized_keys ; ${SUDO} /bin/chmod 700 /home/${DEFAULT_USER}/.ssh"
            /bin/cat ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub | /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "${SUDO} /bin/chmod 777 /home/${SERVER_USER}/.ssh ; /bin/cat - >> /home/${SERVER_USER}/.ssh/authorized_keys ; ${SUDO} /bin/chmod 700 /home/${SERVER_USER}/.ssh"
        fi

        #Now we prep our server properly by hardening it a bit and so on
        #This command will 1) Make sure we are up to date on our new server
        #                  2) Add a new user according to the username and password that we have generated and recorded
        #                  3) Switch off root login on our new server
        #                  4) Set up sshd to keep alive ssh connections on this server and restart sshd

        /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c ' ${SUDO} /usr/bin/apt-get -qq -y update'"
        while ( [ "$?" != "0" ] )
        do
            /bin/sleep 10
            /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c ' ${SUDO} /usr/bin/apt-get -qq -y update'"
        done
        
        /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '${SUDO} /usr/sbin/adduser --disabled-password --force-badname --gecos \"\" ${SERVER_USER} ; /bin/echo ${SERVER_USER}:${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/chpasswd ; ${SUDO} /usr/bin/gpasswd -a ${SERVER_USER} sudo ; ${SUDO} /bin/mkdir -p /home/${SERVER_USER}/.ssh ; ${SUDO} /bin/chown -R ${SERVER_USER}.${SERVER_USER} /home/${SERVER_USER}/ ; ${SUDO} /bin/chmod 700 /home/${SERVER_USER}/.ssh ; ${SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/authorized_keys' ; ${SUDO} /bin/sed -i '$ a\ ClientAliveInterval 60\nTCPKeepAlive yes\nClientAliveCountMax 10000' /etc/ssh/sshd_config ; ${SUDO} /bin/sed -i 's/.*PermitRootLogin.*$/PermitRootLogin no/g' /etc/ssh/sshd_config ;  ${SUDO} /usr/sbin/service sshd restart"

        status "It looks like the machine is booted and accepting connections, so, let's pass it all our configuration stuff that it needs"

        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY
                
        /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat
        
        while read param
        do
             param1="`eval /bin/echo ${param}`"
             if ( [ "${param1}" != "" ] )
             then
                 /bin/echo ${param1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat
             fi
        done < ${BUILD_HOME}/builddescriptors/webserverscp.dat
        
        if ( [ "${ASIP}" != "" ] )
        then
                /usr/bin/scp ${OPTIONS} -P ${SSH_PORT} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat ${SERVER_USER}@${ASIP}:/home/${SERVER_USER}/.ssh >/dev/null 2>&1
        fi        
        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh >/dev/null 2>&1
        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/builddescriptors/buildstylesscp.dat ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/buildstyles.dat >/dev/null 2>&1    
     
        #configure for the cloudhost provider we are using
        ${BUILD_HOME}/providerscripts/cloudhost/ConfigureProvider.sh ${BUILD_HOME} ${CLOUDHOST} ${BUILD_IDENTIFIER} ${ALGORITHM} ${ip} ${SERVER_USER}


        #Here we are configuring our datastore provider. Earlier, when we we inputting all out config details at the beginning of
        #the scripts, we got all the credential information for our datastore provider. So, we can safely assume that this is OK
        #to reuse and we pass it to our autoscaler which can then pass it to any webservers it spawns and so on giving us a single
        #place where we authenticated for our datastore and then we simply reuse those credentials multiple times and in multiple places

        ${BUILD_HOME}/providerscripts/datastore/ConfigureDatastoreProvider.sh ${DATASTORE_CHOICE} ${ip} ${CLOUDHOST} ${BUILD_IDENTIFIER} ${ALGORITHM} ${BUILD_HOME} ${SERVER_USER} ${SERVER_USER_PASSWORD}

        #Our sourcecode which actually defines what a webserver will do and how it will function is held in a git repo. So, if
        #We are to have any chance of getting a working autoscaler, then we must install git on our machine as it is not bundled
        #or available be default, so, lets do that

        /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '/bin/touch /home/${SERVER_USER}/${MACHINETYPE} ; ${CUSTOM_USER_SUDO} /usr/bin/apt-get install -qq git ; cd /home/${SERVER_USER} ; /usr/bin/git init ; /bin/mkdir /home/${SERVER_USER}/bootstrap ; ${CUSTOM_USER_SUDO}  /usr/bin/git config --global init.defaultBranch master ; ${CUSTOM_USER_SUDO} /usr/bin/git config --global pull.rebase false'"

        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/providerscripts/git/GitPull.sh ${BUILD_HOME}/providerscripts/git/GitFetch.sh ${BUILD_HOME}/providerscripts/git/GitCheckout.sh ${SERVER_USER}@${ip}:/home/${SERVER_USER}/bootstrap

        /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /home/${SERVER_USER}/bootstrap/GitPull.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-webserver-scripts"
        #There was a sporadic issue on Linode debian instances at the time of testing where the first GitPull would fail, so I have put in a second
        #call for that reason and that reason alone
        /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /home/${SERVER_USER}/bootstrap/GitPull.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-webserver-scripts"

        status "About to build the webserver"
        status "Please Note: The process of building the webserver is running on a remote machine with ip address : ${WSIP}"
        status "To access this machine once it has finished provisioning you can use the scripts in ${BUILD_HOME}/helperscripts"
        status "Log files (stderr and stdout) are stored on the remote machine in the directory /home/${SERVER_USER}/logs"
        /bin/date >&3

        #Which one is a called depends on what we are building from. Virgin, hourly, weekly, monthly or bimonthly
        if ( [ "${BUILD_CHOICE}" = "0" ] )
        then
            #We are building a virgin system
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'virgin' ${SERVER_USER}"
    elif ( [ "${BUILD_CHOICE}" = "1" ] )
        then
            #We are building from a baseline
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'baseline' ${SERVER_USER}"
    elif ( [ "${BUILD_CHOICE}" = "2" ] )
        then
            #We are building from an hourly backup
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'hourly' ${SERVER_USER}"
    elif ( [ "${BUILD_CHOICE}" = "3" ] )
        then
            #We are building from an daily backup
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'daily' ${SERVER_USER}"
    elif ( [ "${BUILD_CHOICE}" = "4" ] )
        then
            #We are building from an weekly backup
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'weekly' ${SERVER_USER}"
    elif ( [ "${BUILD_CHOICE}" = "5" ] )
        then
            #We are building from an monthly backup
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'monthly' ${SERVER_USER}"
    elif ( [ "${BUILD_CHOICE}" = "6" ] )
        then
            #We are building from an bimonthly backup
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'bimonthly' ${SERVER_USER}"
            home/
        fi

        status "Finished building the webserver"
        /bin/date >&3
        
        #Wait for the machine to become responsive before we check its integrity

        pingcount="0"

        while ( [ "$?" != "0" ] )
        do
            /usr/bin/ping -c 10 ${ip}
            pingcount="`/usr/bin/expr ${pingcount} + 1`"
            if ( [ "${pingcount}" = "10" ] )
            then
                status "I am having trouble pinging your new webserver."
                status "If you see this message repeatedly, maybe check that your security policy allows ping requests"
                status "----------------------------------------------------------------------------------------------"
                pingcount="0"
            fi
        done

        /bin/sleep 10

        #So, looking good. Now what we have to do is keep monitoring for the build process for our webserver to complete
        done="0"
        alive=""
        status "We are checking that our webserver is alive and well and has built correctly"
        count1="0"

        while ( [ "${alive}" != "/home/${SERVER_USER}/runtime/WEBSERVER_READY" ] && [ "${count1}" -lt "10" ] )
        do
            count1="`/usr/bin/expr ${count1} + 1`"
            status "Seems like the shiny new webserver isn't responding yet, trying again...."
            alive="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/ls /home/${SERVER_USER}/runtime/WEBSERVER_READY"`"
            /bin/sleep 30
        done

        if ( [ "${alive}" = "/home/${SERVER_USER}/runtime/WEBSERVER_READY" ] && [ "${DNS_CHOICE}" != "NONE" ] )
        then
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

            ${BUILD_HOME}/providerscripts/dns/AddRecord.sh "${zoneid}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${WEBSITE_URL}" "${ip}" "true" "${DNS_CHOICE}" "${DNS_REGION}" "${WEBSITE_URL}"


            . ${BUILD_HOME}/providerscripts/server/InstallSSLCertificate.sh

            #Restart the webserver to install the new certificate and whatnot
            status "We are restarting the webserver to make sure that the SSL certificate is installed and active"
            /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /home/${SERVER_USER}/providerscripts/webserver/RestartWebserver.sh"
            status "Making sure all is fine and dandy with the DNS provider"

            #Use brute force to ensure that there are no IP addresses for our domain name in the dns and then add our ip address with proxying
            #switched on ready for "go live" when the webserver actually begins to service requests

            zoneid="`${BUILD_HOME}/providerscripts/dns/GetZoneID.sh "${zonename}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}"`"

            recordids="`${BUILD_HOME}/providerscripts/dns/GetAllRecordIDs.sh  "${zoneid}" "${WEBSITE_URL}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}"`"

            if ( [ "${recordids}" != "" ] )
            then
                for recordid in ${recordids}
                do
                    ${BUILD_HOME}/providerscripts/dns/DeleteRecord.sh "${zoneid}" "${recordid}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}" "${WEBSITE_URL}"
                done
            fi

            ${BUILD_HOME}/providerscripts/dns/AddRecord.sh "${zoneid}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${WEBSITE_URL}" "${ip}" "true" "${DNS_CHOICE}" "${DNS_REGION}" "${WEBSITE_URL}"

            if ( [ "${PRODUCTION}" != "0" ] && [ "${DEVELOPMENT}" != "1" ] )
            then
                # Give a copy of the ssl certificate generated to the autoscaler for use when building new webservers when autoscaling
                #ASIP="`/bin/ls ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASIP:* | /usr/bin/awk -F':' '{print $2}'`"

                ASIPS_CLEANED="`/bin/echo ${ASIPS} | /bin/sed 's/\:/ /g`"
                for ASIP in ${ASIPS_CLEANED}
                do
                    /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ${SERVER_USER}@${ASIP}:/home/${SERVER_USER}/.ssh/fullchain.pem

                    if ( [ "$?" != "0" ] )
                    then
                        status"Failed to copy fullchain.pem for the SSL Certificate to the autoscaler. This is fatal and could be caused by a network glitch. Try rebuilding. Exiting"
                        exit
                    fi

                    /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ${SERVER_USER}@${ASIP}:/home/${SERVER_USER}/.ssh/privkey.pem

                    if ( [ "$?" != "0" ] )
                    then
                        status "Failed to copy privkey.pem for the SSL Certificate to the autoscaler. This is fatal and could be caused by a network glitch. Try rebuilding. Exiting..."
                        exit
                    fi
                    
                    if ( [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/${WEBSITE_URL}.json ] )
                    then
                        /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/${WEBSITE_URL}.json ${SERVER_USER}@${ASIP}:/home/${SERVER_USER}/.ssh/${WEBSITE_URL}.json

                        if ( [ "$?" != "0" ] )
                        then
                            status "Failed to copy ${WEBSITE_URL}.json for the SSL Certificate to the autoscaler. This is fatal and could be caused by a network glitch. Try rebuilding. Exiting..."
                            exit
                        fi
                    fi

                    #We also need the account dir generated by lego to be on our servers so that the renew process of lego when we want to
                    #renew our certs doesn't go wonky. What we do is store the account details on the autoscaler and then move them to the
                    #shared config directory which the webservers can query each time they need to do a renew if they don't already have
                    #access to them.

                    /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ASIP} "${SUDO} /bin/chown -R ${SERVER_USER}.${SERVER_USER} /home/${SERVER_USER}/.ssh/accounts"

                    /usr/bin/scp -r -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/.lego/accounts ${SERVER_USER}@${ASIP}:/home/${SERVER_USER}/.ssh/
                    if ( [ "$?" != "0" ] )
                    then
                        status "Failed to copy ${WEBSITE_URL}.json for the SSL Certificate to the autoscaler. This is fatal and could be caused by a network glitch. Try rebuilding. Exiting..."
                        exit
                    fi
                done
            fi

            done="1"
            #Remeber Webserver IP
            WSIP=${ip}
        fi

        #If $done != 1, then the webserver didn't build properly, so, destroy the machine
        if ( [ "${done}" != "1" ] )
        then
            status "################################################################################################################"
            status "Hi, an webserver didn't seem to build correctly. I can destroy it and I can try to build a new webserver for you"
            status "################################################################################################################"
            status "Press the <enter> key to be continue with the next attempt <ctrl - c> to exit"
            read response

            ${BUILD_HOME}/providerscripts/server/DestroyServer.sh ${ip} ${CLOUDHOST}
            
            if ( [ "${DBaaS_DBSECURITYGROUP}" != "" ] )
            then
                IP_TO_DENY="${ip}"
                . ${BUILD_HOME}/providerscripts/server/DenyDBAccess.sh
            fi
            
            if ( [ "${IN_MEMORY_SECURITY_GROUP}" != "" ] )
            then
                IP_TO_DENY="${ip}"
                . ${BUILD_HOME}/providerscripts/server/DenyCachingAccess.sh
            fi


            #Wait until we are sure that the image server(s) are destroyed because of a faulty build
            while ( [ "`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "webserver" ${CLOUDHOST} 2>/dev/null`" != "0" ] )
            do
                /bin/sleep 30
            done
        else
            status "It seems like the webserver has built correctly and is accepting connections"
        fi
    else
        status "A webserver is already running, using that one"
        status "Press enter if this is OK with you"
        read response
        done=1
    fi
done

#If we get to here then we know that the webserver didn't build properly, so report it and exit

if ( [ "${counter}" = "5" ] )
then
    status "The infrastructure failed to intialise because of a build problem, plese investigate, correct and rebuild"
    exit
fi
