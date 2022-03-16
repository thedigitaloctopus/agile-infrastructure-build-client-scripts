#!/bin/sh
###############################################################################################################
# Author: Peter Winter
# Date  : 12/07/2016
# Description : This script builds the autoscaler. It depends on having the environment it requires set up through the
#"initialisation" scripts which you can find in the same directory. These scripts look more complicated than they really
# are. All that is happening is we are copying over some files to our new autoscaler and executing a few commands (mostly
# to install software) remotely on the autoscaler.
# The purpose of the autoscaler is to monitor the number of active and responsive webservers and if, according to
# configuration, there should be more or less than are currently active, they are shutdown or newly provisioned
# accordingly. For more information on how to configure the autoscaling, please review the documentation.
# Note, the autoscaling is not dynamic, so in a way it is scaling rather than autoscaling. Autoscaling requires that
# machine usage is monitored and additional capacity provisioned or removed accordingly. The way this works is
# you review machine usage and adjust your capacity accordingly which will then be automatically scaled out.
# If you application has huge and unpredicable swings in usage, then this mechanism might not be suitable rather,
# it is for applications that have consistent predictable usage profiles within tight bounds.
###############################################################################################################
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

done=0
counter="0"
count="0"

status ""
status ""
status ""
status "#########################AUTOSCALER#######################"

#For our remote commands, we have various options that we want to be set. To keep things as clean as possible
#We set out options for our ssh command and scp command here and pass them in through the variable ${OPTIONS}

OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

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
status "========================================================="
status "=================BUILDING AUTOSCALER====================="
status "========================================================="

status "Logging for this server build is located at ${BUILD_HOME}/logs/${OUT_FILE}"
status "The error stream for this server build is located at ${BUILD_HOME}/logs/${ERR_FILE}"
status "========================================================="
ASIPS=""
ASIP_PRIVATES=""

# If done=1, then we know that the autoscaler has been successfully built. We try up to 5 times before we give up if it fails
while ( [ "${done}" != "1" ] && [ "${counter}" -lt "5" ] )
do
    counter="`/usr/bin/expr ${counter} + 1`"
    no_autoscalers="`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "autoscaler" ${CLOUDHOST} 2>/dev/null`"
    
    status ""
    status ""
    status "######################################################################################################"
    status "OK... Building autoscaler `/usr/bin/expr ${no_autoscalers} + 1`. This is the ${counter} attempt of 5"
    
    WEBSITE_IDENTIFIER="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`"

    #Check that an autoscaler isn't already running - if one is, then we report it  and exit, we can only have one autoscaler active
    if ( [ "${no_autoscalers}" -le "${NO_AUTOSCALERS}" ] )
    then
        ip=""
        #Set a unique identifier and name for our new autoscaler server
        RND="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1`"
        autoscaler_name="${no_autoscalers}-autoscaler-${RND}-${WEBSITE_NAME}-${BUILD_IDENTIFIER}"
        autoscaler_name="`/bin/echo ${autoscaler_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"

        #See what os type we are building on. Currently only Ubuntu and debian are supported
        if ( [ "${OS_TYPE}" = "" ] )
        then
            OS_TYPE="`${BUILD_HOME}/providerscripts/cloudhost/GetOperatingSystemVersion.sh ${AS_SIZE} ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"
        fi
        
        status "Initialising a new server machine, please wait......"
        
        server_started="0"
        while ( [ "${server_started}" = "0" ] )
        do

            #Actually create the autoscaler machine. If the create fails, keep trying again - it must be a provider issue
            ${BUILD_HOME}/providerscripts/server/CreateServer.sh "'${OS_TYPE}'" "${REGION_ID}" "${AS_SERVER_TYPE}" "${autoscaler_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} ${SUBNET_ID} ${AUTOSCALER_IMAGE_ID}

            #Somehow we failed, let's try again...
            while ( [ "$?" != 0 ] )
            do
                ${BUILD_HOME}/providerscripts/server/CreateServer.sh "'${OS_TYPE}'" "${REGION_ID}" "${AS_SERVER_TYPE}" "${autoscaler_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} ${SUBNET_ID} ${AUTOSCALER_IMAGE_ID}
            done

            #Get the ip addresses of the server we have just built
            ip=""
            private_ip=""
            count="0"

            while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "20" ] )
            do
                status "Interrogating for autoscaler ip addresses....."
                ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${autoscaler_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
                private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${autoscaler_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
                /bin/sleep 10
                count="`/usr/bin/expr ${count} + 1`"
            done
            
            if ( [ "${ip}" != "" ] && [ "${private_ip}" != "" ] )
            then
                server_started="1"
            else
                status "I haven't been able to start your server for you, trying again...."
            fi
       done
      
        status "It looks like the machine has booted OK"
        ASIP=${ip}
        ASIP_PRIVATE=${private_ip}
        
        ASIPS="${ASIPS}${ASIP}:"
        ASIP_PRIVATES="${ASIP_PRIVATES}${ASIP_PRIVATE}:"

        status "Have got the ip addresses for your autoscaler"
        status "Public IP address: ${ASIP}"
        status "Private IP address: ${ASIP_PRIVATE}"

        #record the server ip address(es)
        /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASIP:*
        /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASPRIVATEIP:*

        /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASIP:${ASIP}
        /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASPRIVATEIP:${ASIP_PRIVATE}

        #We know various parameters which have been set by the initialisation scripts - so we store then like this on our filesystem so that they
        #can be passed using scp as configuration parameters to our autoscaling server
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/${BUILD_IDENTIFIER}

        #We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
        #So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
        #We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
        /bin/echo "Host ${ASIP}" >> ~/.ssh/config
        /bin/echo "IdentityFile ~/.ssh/${SERVER_USER}.key" >> ~/.ssh/config
        /bin/echo "IdentitiesOnly yes" >> ~/.ssh/config

        #Test if it is possible to connect to the server using ssh keys
        loop="0"
        connected="0"
        while ( [ "${loop}" -lt "3" ] )
        do
            #If it is a debian OS, then, we can pass in our DEBIAN_FRONTEND variable which will just be ignored by any other type of OS,
            /usr/bin/ssh ${OPTIONS} -o "PasswordAuthentication=no" ${DEFAULT_USER}@${ip} 'DEBIAN_FRONTEND=noninteractive exit'

            if ( [ "$?" = "0" ] )
            then
                connected="1"
                break
            fi
            loop="`/usr/bin/expr ${loop} + 1`"
            /bin/sleep 10
        done

        #If it is not possible, then possibly the provider requires password authentication in the first instance
        #If we can "get going" with a text password, after that, we can harden ourselves with our ssh keys and switching off
        #Root based authentication
        if ( [ "${connected}" != "1" ] )
        then
            connected="0"
            loop="0"
            if ( [ "${CLOUDHOST_PASSWORD}" != "" ] )
            then
                /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTION} ${CLOUDHOST_USERNAME}@${ip} 'DEBIAN_FRONTEND=noninteractive exit'

                if ( [ "$?" = "0" ] )
                then
                    connected="1"
                fi

                #Keep trying in case there is some "holdup" with the server coming on line
                while ( [ "${connected}" = "0" ] && [ "${loop}" -lt "10" ] )
                do
                    status "Haven't successfully connected to the Autoscaler, maybe it is still initialising, trying again...."
                    /bin/sleep 5
                    loop="`/usr/bin/expr ${loop} + 1`"
                    /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} 'DEBIAN_FRONTEND=noninteractive exit'
                    if ( [ "$?" = "0" ] )
                    then
                        connected="1"
                    fi
                done
            else
                status "Failed to connect to autoscaler, cloudhost password not set"
                exit
            fi

            if ( [ "${connected}" != "1" ] )
            then
                status "Sorry could not connect to the autoscaler server. This might be due to provider networking issues. Please investigate..."
                exit
            fi

            #Make things nice for our keys and other security tokens
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '/bin/mkdir -p /home/${SERVER_USER}/.ssh ; /bin/mkdir -p /root/.ssh ; /bin/chmod 700 /home/${SERVER_USER}/.ssh ; /bin/chmod 700 /root/.ssh'"

            #Make sure that we can use the ssh key in the future
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ${CLOUDHOST_USERNAME}@${ip}:/root/.ssh/authorized_keys
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ${CLOUDHOST_USERNAME}@${ip}:/home/${SERVER_USER}/.ssh/authorized_keys
        else
            #Do the same thing as we would do for password based authentication, but authenticate with our keys instead.
            /usr/bin/ssh ${OPTIONS} -o "PasswordAuthentication=no" ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive ${SUDO} /bin/sh -c '/bin/mkdir -p /home/${SERVER_USER}/.ssh ; /bin/chmod 700 /home/${SERVER_USER}/.ssh ; /bin/chmod 700 /root/.ssh ; /bin/chown -R ${SERVER_USER}:${SERVER_USER} /home/${SERVER_USER}'"
        fi

        /bin/cat ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub | /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "${SUDO} /bin/cat - >> /root/.ssh/authorized_keys"
        /bin/cat ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub | /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "${SUDO} /bin/chmod 777 /home/${DEFAULT_USER}/.ssh ; /bin/cat - >> /home/${DEFAULT_USER}/.ssh/authorized_keys ; ${SUDO} /bin/chmod 700 /home/${DEFAULT_USER}/.ssh"
        /bin/cat ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub | /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "${SUDO} /bin/chmod 777 /home/${SERVER_USER}/.ssh ; /bin/cat - >> /home/${SERVER_USER}/.ssh/authorized_keys ; ${SUDO} /bin/chmod 700 /home/${SERVER_USER}/.ssh"

        #Now we prep our server properly by hardening it a bit and so on
        #This command will 1) Make sure we are up to date on our new server
        #                  2) Add a new user according to the username and password that we have generated and recorded
        #                  3) Switch off root login on our new server
        #                  4) Set up sshd to keep alive ssh connections on this server and restart sshd


        if ( [ "${BUILDOS}" = "ubuntu" ] || [ "${BUILDOS}" = "debian" ] )
        then
            /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c ' ${SUDO} /usr/bin/apt-get -qq -y update'"
            while ( [ "$?" != "0" ] )
            do
                /bin/sleep 10
                /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c ' ${SUDO} /usr/bin/apt-get -qq -y update'"
            done
        fi
        
        /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '${SUDO} /usr/sbin/adduser --disabled-password --force-badname --gecos \"\" ${SERVER_USER} ; /bin/echo ${SERVER_USER}:${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/chpasswd ; ${SUDO} /usr/bin/gpasswd -a ${SERVER_USER} sudo ; ${SUDO} /bin/mkdir -p /home/${SERVER_USER}/.ssh ; ${SUDO} /bin/chown -R ${SERVER_USER}.${SERVER_USER} /home/${SERVER_USER}/ ; ${SUDO} /bin/chmod 700 /home/${SERVER_USER}/.ssh ; ${SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/authorized_keys' ; ${SUDO} /bin/sed -i '$ a\ ClientAliveInterval 60\nTCPKeepAlive yes\nClientAliveCountMax 10000' /etc/ssh/sshd_config ; ${SUDO} /bin/sed -i 's/.*PermitRootLogin.*$/PermitRootLogin no/g' /etc/ssh/sshd_config ;  ${SUDO} /usr/sbin/service sshd restart"

        #Make a copy of our private key on our server also. The reason for having a copy of the private key on the server also is that
        #the server may wish to authenticate itself to one of the other machines in the setup and so the private key will be needed
        #All machines in a given deployment use the same public/private keys for their authentication. It's a one key fits all machines setup.
        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY

        status "It looks like the machine is booted and accepting connections, so, let's pass it all our configuration stuff that it needs"

        WEBSITE_DISPLAY_NAME_FILE="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/ /_/g'`"
        
        /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat
        
        while read param
        do
             param1="`eval /bin/echo ${param}`"
             if ( [ "${param1}" != "" ] )
             then
                 /bin/echo ${param1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat
             fi
        done < ${BUILD_HOME}/builddescriptors/autoscalerscp.dat
        
        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh >/dev/null 2>&1
        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/builddescriptors/buildstylesscp.dat ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/buildstyles.dat >/dev/null 2>&1

        #This is a call to our script to configure out provider. Have a look in the script to see what it's up to
        ${BUILD_HOME}/providerscripts/cloudhost/ConfigureProvider.sh ${BUILD_HOME} ${CLOUDHOST} ${BUILD_IDENTIFIER} ${ALGORITHM} ${ip} ${SERVER_USER} ${SERVER_USER_PASSWORD}

        #Here we are configuring our datastore provider. Earlier, when we we inputting all out config details at the beginning of
        #the scripts, we got all the credential information for our datastore provider. So, we can safely assume that this is OK
        #to reuse and we pass it to our autoscaler which can then pass it to any webservers it spawns and so on giving us a single
        #place where we authenticated for our datastore and then we simply reuse those credentials multiple times and in multiple places

        ${BUILD_HOME}/providerscripts/datastore/ConfigureDatastoreProvider.sh ${DATASTORE_CHOICE} ${ip} ${CLOUDHOST} ${BUILD_IDENTIFIER} ${ALGORITHM} ${BUILD_HOME} ${SERVER_USER} ${SERVER_USER_PASSWORD}

        /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '${CUSTOM_USER_SUDO} /bin/cat /home/${SERVER_USER}/.ssh/authorized_keys.tmp >> /home/${SERVER_USER}/.ssh/authorized_keys ; ${CUSTOM_USER_SUDO} /bin/rm /home/${SERVER_USER}/.ssh/authorized_keys.tmp ; ${CUSTOM_USER_SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/authorized_keys ; ${CUSTOM_USER_SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/id_rsa'"

        #Add the private build key to the autoscaler. Because the autoscaler is responsible for building new webserver instances,
        #it needs the build key so that it can bootstrap with the provider
        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}
        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub

        #Our sourcecode which actually defines what an autoscaler will do and how it will function is held in a git repo. So, if
        #We are to have any chance of getting a working autoscaler, then we must install git on our machine as it is not bundled
        #or available be default, so, lets do that
        
        if ( [ "${BUILDOS}" = "ubuntu" ] || [ "${BUILDOS}" = "debian" ] )
        then
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '/bin/chmod 400 /home/${SERVER_USER}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ; /bin/chmod 400 /home/${SERVER_USER}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ; /bin/touch /home/${SERVER_USER}/${MACHINE_TYPE} ; ${CUSTOM_USER_SUDO} /usr/bin/apt-get -qq -y update ; ${CUSTOM_USER_SUDO} /usr/bin/apt-get install -qq -y git ;  /usr/bin/git init ; /bin/mkdir -p /home/${SERVER_USER}/bootstrap ; ${CUSTOM_USER_SUDO}  /usr/bin/git config --global init.defaultBranch master ; ${CUSTOM_USER_SUDO} /usr/bin/git config --global pull.rebase false'"
        
            while ( [ "$?" != "0" ] )
            do
                /bin/sleep 10
                /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '/bin/chmod 400 /home/${SERVER_USER}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ; /bin/chmod 400 /home/${SERVER_USER}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ; /bin/touch /home/${SERVER_USER}/${MACHINE_TYPE} ; ${CUSTOM_USER_SUDO} /usr/bin/apt-get -qq -y update ; ${CUSTOM_USER_SUDO} /usr/bin/apt-get install -qq -y git ;  /usr/bin/git init ; /bin/mkdir -p /home/${SERVER_USER}/bootstrap ; ${CUSTOM_USER_SUDO}  /usr/bin/git config --global init.defaultBranch master ; ${CUSTOM_USER_SUDO} /usr/bin/git config --global pull.rebase false'"
            done
        fi

        #We need some of our scripts to bootstrap our access to git from our autoscaler so copy the scripts we need to our autoscaler
        #and from there we can get our scripts out of the git repo and start them running

        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/providerscripts/git/GitPull.sh ${BUILD_HOME}/providerscripts/git/GitFetch.sh ${BUILD_HOME}/providerscripts/git/GitCheckout.sh ${SERVER_USER}@${ip}:/home/${SERVER_USER}/bootstrap

        #So, using the GitPull script that we copied across in our bootstrap set, we can pull the scripts down from the git repo
        #and install them on our machine ready for action
        /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive cd /home/${SERVER_USER} && /home/${SERVER_USER}/bootstrap/GitPull.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-autoscaler-scripts"

        #There was a sporadic issue on Linode debian instances at the time of testing where the first GitPull would fail, so I have put in a second
        #call for that reason and that reason alone
        /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive cd /home/${SERVER_USER} && /home/${SERVER_USER}/bootstrap/GitPull.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-autoscaler-scripts"

        #The BUILD_CHOICE relates to which periodicity of backup we want to build our webserver(s) from. This is recorded on our autoscaler here
        if ( [ "${BUILD_CHOICE}" = "0" ] )
        then
            #This is a virgin build so this is something like a vanilla version of a CMS system
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/providerscripts/utilities/StoreConfigValue.sh 'BUILDARCHIVE' 'virgin'" 
        elif ( [ "${BUILD_CHOICE}" = "1" ] )
        then
            #This is a virgin build from the baseline of our application. When we developed our application, the last thing we should
            #have done is made a final baseline which can then be used to take our application live. Once it is live we will start
            #makeing periodic backups and we can build off those backups if we want to
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/providerscripts/utilities/StoreConfigValue.sh 'BUILDARCHIVECHOICE' 'baseline'" 
        elif ( [ "${BUILD_CHOICE}" = "2" ] )
        then
            #This builds from a backup which is one hour old
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/providerscripts/utilities/StoreConfigValue.sh 'BUILDARCHIVECHOICE' 'hourly'" 
        elif ( [ "${BUILD_CHOICE}" = "3" ] )
        then
            #This builds from a backup which is one day old
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/providerscripts/utilities/StoreConfigValue.sh 'BUILDARCHIVECHOICE' 'daily'" 
        elif ( [ "${BUILD_CHOICE}" = "4" ] )
        then
            #This builds from a backup which is one week old
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/providerscripts/utilities/StoreConfigValue.sh 'BUILDARCHIVECHOICE' 'weekly'" 
        elif ( [ "${BUILD_CHOICE}" = "5" ] )
        then
            #This builds from a backup which is one month old
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/providerscripts/utilities/StoreConfigValue.sh 'BUILDARCHIVECHOICE' 'monthly'" 
        elif ( [ "${BUILD_CHOICE}" = "6" ] )
        then
            #This builds from a backup which is two months old
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/providerscripts/utilities/StoreConfigValue.sh 'BUILDARCHIVECHOICE' 'bimonthly'" 
        fi

        #Wicked, we have our scripts so we can build our autoscaler now

        status "About to build the autoscaler"
        status "Please Note: The process of building the autoscaler is running on a remote machine with ip address : ${ASIP}"
        status "To access this machine once it has finished provisioning you can use the scripts in ${BUILD_HOME}/helperscripts"
        status "Log files (stderr and stdout) are stored on the remote machine so if you need to review them, you will find them there"
        status "in the directory /home/${SERVER_USER}/logs"
        /bin/date >&3

        /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/as.sh ${SERVER_USER}"

        status "Finished building the autoscaler"
        /bin/date >&3
        
        #Wait for the machine to become responsive before we check its integrity

        pingcount="0"

        while ( [ "$?" != "0" ] )
        do
            /usr/bin/ping -c 10 ${ip}
            pingcount="`/usr/bin/expr ${pingcount} + 1`"
            if ( [ "${pingcount}" = "10" ] )
            then
                status "I am having trouble pinging your new autoscaling server."
                status "If you see this message repeatedly, maybe check that your security policy allows ping requests"
                status "----------------------------------------------------------------------------------------------"
                pingcount="0"
            fi
        done

        /bin/sleep 10

        done="0"
        alive=""
        #Start checking that the autoscaler is "built and alive" The last thing that the as.sh script does is reboot the machine
        #that is our autoscaler. We do some rudimentary checking to detect when it is back up again post reboot.

        status "Checking to see if the autoscaler is alive and well and has been built successfully"
        count1="0"
        while ( [ "${alive}" != "/home/${SERVER_USER}/runtime/AUTOSCALER_READY" ] && [ "${count1}" -lt "20" ] )
        do
            count1="`/usr/bin/expr ${count1} + 1`"
            alive="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/ls /home/${SERVER_USER}/runtime/AUTOSCALER_READY"`"
            status "Testing if the autoscaler built correctly and is allowing connections....."
            /bin/sleep 30

            if ( [ "${alive}" = "/home/${SERVER_USER}/runtime/AUTOSCALER_READY" ] )
            then
                counter="0"
                if ( [ "`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "autoscaler" ${CLOUDHOST} 2>/dev/null`" -eq "${NO_AUTOSCALERS}" ] )
                then
                    done=1
                fi
            fi
        done

        if ( [ "${alive}" != "/home/${SERVER_USER}/runtime/AUTOSCALER_READY" ] )
        then
            status "#########################################################################################################################"
            status "Hi, an autoscaler didn't seem to build correctly. I can destroy it and I can try again to build a new autoscaler for you."
            status "#########################################################################################################################"
            status "Press the <enter> key to be continue with the next attempt <ctrl - c> to exit"
            read response

            ${BUILD_HOME}/providerscripts/server/DestroyServer.sh ${ip} ${CLOUDHOST}
            
            if ( [ "${DBaaS_DBSECURITYGROUP}" != "" ] )
            then
                IP_TO_DENY="${ip}"
                . ${BUILD_HOME}/providerscripts/server/DenyDBAccess.sh
            fi

            #Wait until we are sure that the image server(s) are destroyed because of a faulty build
            while ( [ "`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "autoscaler" ${CLOUDHOST} 2>/dev/null`" != "0" ] )
            do
                /bin/sleep 30
            done
        else
            status "The autoscaler appears to have built correctly"
        fi
    else
        status "Autoscaler is already running. Will use that one..."
        status "Press Enter if this is OK"
        read response
        done=1
    fi
done

#If our count got to 5, then we know that none of the attempts succeeded in building our autoscaler, so, report this and exit because we can't run without an autoscaler

if ( [ "${counter}" = "5" ] )
then
    status "The infrastructure failed to intialise because of a build problem with the autoscaler, please investigate, correct and rebuild"
    exit
fi
