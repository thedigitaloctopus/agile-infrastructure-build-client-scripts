#!/bin/bash
##############################################################################################################
# Author: Peter Winter
# Date  : 12/07/2016
# Description : This is the script to build the database. It will build a single database server and check
# that it seems to be running OK. These scripts look more complicated than they really are. All that is
# happening is we are copying over some files to our new database and executing a few commands (mostly to
# install software) remotely on the database.
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

#If done=1 then we know that we have build a database correctly so we don't need to run again
#If databases fail to build, we try again up to 5 times

status ""
status ""
status ""
status "#########################DATABASE#######################"

#For our remote commands, we have various options that we want to be set. To keep things as clean as possible
#We set out options for our ssh command and scp command here and pass them in through the variable ${OPTIONS}
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
status "=================BUILDING DATABASE======================="
status "========================================================="

status "Logging for this server build is located at ${BUILD_HOME}/logs/${OUT_FILE}"
status "The error stream for this server build is located at ${BUILD_HOME}/logs/${ERR_FILE}"
status "========================================================="

#If we don't need a database, then just skip the process of installing a database
#We may have an application which doesn't require a database
if ( [ "${DATABASE_INSTALLATION_TYPE}" = "None" ] )
then
    status "This deployment doesn't need a database passing...."
fi

built="0"

#If we are done then we can stop otherwise retry up to 5 times

while ( [ "${done}" != "1" ] && [ "${counter}" -lt "5" ] && [ "${DATABASE_INSTALLATION_TYPE}" != "None" ] )
do
    counter="`/usr/bin/expr ${counter} + 1`"
    status "OK... building a database server. This is attempt ${counter} of 5"

    #Make sure a database is not already running
    WEBSITE_IDENTIFIER="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`"
    if ( [ "`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "database" ${CLOUDHOST} 2>/dev/null`" -eq "0" ] )
    then

        ip=""
        #Create an identifier from our the user name we allocated to identify the database server
        RND="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1`"
        database_name="database-${RND}-${WEBSITE_NAME}-${BUILD_IDENTIFIER}"
        database_name="`/bin/echo ${database_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"

        #What type of OS are we building for. Currently, (April 2018) only ubuntu and debian are supported
        ostype="`${BUILD_HOME}/providerscripts/cloudhost/GetOperatingSystemVersion.sh ${DB_SIZE} ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"

        status "Initialising a new server machine, please wait......"

        #Actually spin up the machine we are going to build on
        ${BUILD_HOME}/providerscripts/server/CreateServer.sh "'${ostype}'" "${REGION_ID}" "${DB_SERVER_TYPE}" "${database_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} ${SUBNET_ID} ${DATABASE_IMAGE_ID}
        #If for some reason, we failed to build the machine, then, give it another try
        while ( [ "$?" != "0" ] )
        do
            ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${ostype}" "${REGION_ID}" "${DB_SERVER_TYPE}" "${database_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} ${SUBNET_ID} ${DATABASE_IMAGE_ID}
        done

        #Check that the server has been assigned its IP addresses and that they are active
        ip=""
        private_ip=""
        count="0"

        while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "20" ] )
        do
            status "Interrogating for database ip address"
            ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${database_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
            private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${database_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
            /bin/sleep 10
            count="`/usr/bin/expr ${count} + 1`"
        done

        DBIP="${ip}"
        DBIP_PRIVATE="${private_ip}"
        #We create an ip mask for our server this is used when we set access privileges and so on within the database
        #and we want to allow access from machines on our private network
        IPMASK="`/bin/echo ${DBIP_PRIVATE} | /bin/grep -oE '[0-9]{1,3}\.[0-9]{1,3}' | /usr/bin/head -1`"
        IPMASK=${IPMASK}".%.%"

        status "Have got the ip addresses for your database"
        status "Public IP address: ${DBIP}"
        status "Private IP address: ${DBIP_PRIVATE}"

        #Persist our IP addresses on our filesystems for later usage
        /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBIP:${DBIP}
        /bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBPRIVATEIP:${DBIP_PRIVATE}
        
       IP_TO_ALLOW="${DBIP}"
       . ${BUILD_HOME}/providerscripts/server/AllowDBAccess.sh


        #We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
        #So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
        #We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
        /bin/echo "Host ${DBIP}" >> ~/.ssh/config
        /bin/echo "IdentityFile ~/.ssh/${SERVER_USER}.key" >> ~/.ssh/config
        /bin/echo "IdentitiesOnly yes" >> ~/.ssh/config

        #Test if it is possible to connect to the server using ssh keys
        loop="0"
        connected="0"
        while ( [ "${loop}" -lt "3" ] )
        do
            #If it is a debian OS, then, we can pass in our DEBIAN_FRONTEND variable which will just be ignored by any other type of OS, so don't need to worry
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
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} 'DEBIAN_FRONTEND=noninteractive exit'

            if ( [ "$?" = "0" ] )
            then
                connected="1"
            fi

            #Keep trying in case there is some "holdup" with the server coming on line
            while ( [ "${connected}" = "0" ] && [ "${loop}" -lt "10" ] )
            do
                status "Haven't successfully connected to the database, maybe it is still initialising, trying again...."
                /bin/sleep 5
                loop="`/usr/bin/expr ${loop} + 1`"
                /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} 'DEBIAN_FRONTEND=noninteractive exit'
                if ( [ "$?" = "0" ] )
                then
                    connected="1"
                fi
            done

            if ( [ "${connected}" != "1" ] )
            then
                status "Sorry could not connect to the database server. This might be due to provider networking issues. Please investigate..."
                exit
            fi
            #Set some permissions as we require
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/mkdir /home/${SERVER_USER}/.ssh"
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/mkdir /root/.ssh"
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/chmod 700 /home/${SERVER_USER}/.ssh"
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/ssh ${OPTIONS} ${CLOUDHOST_USERNAME}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/chmod 700 /root/.ssh"

            #Make sure that we can use the ssh key in the future
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ${CLOUDHOST_USERNAME}@${ip}:/root/.ssh/authorized_keys
            /usr/bin/sshpass -p ${CLOUDHOST_PASSWORD} /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ${CLOUDHOST_USERNAME}@${ip}:/home/${SERVER_USER}/.ssh/authorized_keys
        else
            #Do the same thing as we would do for password based authentication, but authenticate with our keys instead.
            /usr/bin/ssh ${OPTIONS} -o "PasswordAuthentication=no" ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '/bin/chmod 700 /home/${SERVER_USER}/.ssh ; /bin/chmod 700 /root/.ssh'"
        fi

        #Add our new user. This user will be used when we connect to the machine and will have sudo privileges.
        #Operationally, the password for this user will be stored on the machine in the ${HOME}/.ssh directory
        #and you can use the password (SERVERUSERPASSWORD) to sudo into the root user when you need to
        
        /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c ' ${SUDO} /usr/bin/apt-get -qq -y update'"
        while ( [ "$?" != "0" ] )
        do
            /bin/sleep 10
            /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c ' ${SUDO} /usr/bin/apt-get -qq -y update'"
        done
        
        /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '${SUDO} /usr/sbin/adduser --disabled-password --force-badname --gecos \"\" ${SERVER_USER} ; /bin/echo ${SERVER_USER}:${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/chpasswd ; ${SUDO} /usr/bin/gpasswd -a ${SERVER_USER} sudo ; ${SUDO} /bin/mkdir -p /home/${SERVER_USER}/.ssh'"

        /bin/cat ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub | /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "${SUDO} /bin/cat - >> /root/.ssh/authorized_keys"
        /bin/cat ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub | /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "${SUDO} /bin/chmod 777 /home/${DEFAULT_USER}/.ssh ; /bin/cat - >> /home/${DEFAULT_USER}/.ssh/authorized_keys ; ${SUDO} /bin/chmod 700 /home/${DEFAULT_USER}/.ssh"
        /bin/cat ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub | /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "${SUDO} /bin/chmod 777 /home/${SERVER_USER}/.ssh ; /bin/cat - >> /home/${SERVER_USER}/.ssh/authorized_keys ; ${SUDO} /bin/chmod 700 /home/${SERVER_USER}/.ssh"

        #This key is the key that was generated when we wish to use DBaaS over an SSH tunnel. This key gets us access to the remote end
        #of our ssh tunnel and from there we are port forwarded to our database which is running as a service.

        if ( [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS-secured" ] )
        then
            /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/dbaas_server_key.pem ${DEFAULT_USER}@${ip}:/home/${SERVER_USER}/.ssh/dbaas_server_key.pem
        fi

        #Harden ourselves by switching off root based authentication. After this, we cannot remotely access this machine as root, even if we want to
        /usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get update ; /usr/bin/apt-get install sudo ; /bin/sh -c '${SUDO} /bin/chown -R ${SERVER_USER}.${SERVER_USER} /home/${SERVER_USER}/ ; ${SUDO} /bin/chmod 700 /home/${SERVER_USER}/.ssh ; ${SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/authorized_keys' ; ${SUDO} /bin/sed -i '$ a\ ClientAliveInterval 60\nTCPKeepAlive yes\nClientAliveCountMax 10000' /etc/ssh/sshd_config ; ${SUDO} /bin/sed -i 's/PermitRootLogin yes.\*$/PermitRootLogin no/g' /etc/ssh/sshd_config ;  ${SUDO} /usr/sbin/service sshd restart"

        #Ask the person making the deployment if they would like to have block storage added to the machine.
        #By using block storage, a machine can be given much higher capacity without necessarily adding on a
        #whole load more compute which is expensive and possibly not needed. You can review articles online for
        #how to add block storage to a database server in an effective way
        status
        status "============================================================================================================="
        status "If your cloudhost supports it, you might like to add block storage to this Database server"
        status "If you do, then now is the time to add it. Press <enter> when you have added it (or not) if you don't need it"
        status "Please review the documentation from your provider about how to add block storage"
        status "============================================================================================================="


        read response

        #If we are here, then we know that the machine has passed it's test to see if it is online, so, we can proceed
        status "It looks like the machine is booted and accepting connections, so, let's pass it all our configuration stuff that it needs"

        #This is the way I decided to pass all the configuration over. This creates files with bits of information and configuration
        #Encoded in the file name. I could have passed it all over as a config file but that isn't the choice I made and probably
        #this is as good a method as any.
        command="/usr/bin/scp ${OPTIONS}"

        while read scpparam
        do
            scpparam1="`eval /bin/echo ${scpparam}`"

            if ( [ "${scpparam1}" != "" ] )
            then
                /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/"${scpparam1}"
                command="${command} \"${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/${scpparam1}\""
            fi
        done < ${BUILD_HOME}/builddescriptors/databasescp.dat

        command="${command} ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh >/dev/null 2>&1"
        eval ${command}

        #Despite what I just said above, there is one case where using files as a way of passing configuration details over
        #which is that sometimes, if you have a credential which has a slash embedded in it, then you can't have a file name
        #with a slash in it. The only place I have seen this is in some generated passwords for email authentication which
        #cannot be changed. So, in this case, there is an exception and I bundle the credential in a file.
        if ( [ -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SYSTEMEMAILPASSWORD.dat ] )
        then
            /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SYSTEMEMAILPASSWORD.dat ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/SYSTEMEMAILPASSWORD.dat
        fi


        #Run our configuration for this provider so that it has it's necessary access keys and so on
        ${BUILD_HOME}/providerscripts/cloudhost/ConfigureProvider.sh ${BUILD_HOME} ${CLOUDHOST} ${BUILD_IDENTIFIER} ${ALGORITHM} ${ip} ${SERVER_USER}

        /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '/bin/chmod 400 /home/${SERVER_USER}/.ssh/id_rsa '"

        # Configure our datastore provider
        ${BUILD_HOME}/providerscripts/datastore/ConfigureDatastoreProvider.sh ${DATASTORE_CHOICE} ${ip} ${CLOUDHOST} ${BUILD_IDENTIFIER} ${ALGORITHM} ${BUILD_HOME} ${SERVER_USER} ${SERVER_USER_PASSWORD}

        #Check if we are switching on super safe for our backups (recommended)
        #If super safe backups are switched on, then during operational usage, backups are made to the code repository (github, for example)
        #and they are also made to the datastore (amazon S3, for example). In this way, we have solid backups.
        #Individual backups occur hourly, daily, weekly, monthly and bimonthly
        if ( [ "${SUPERSAFE_DB}" = "1" ] )
        then
            status "Supersafe is set on"
            /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/SUPERSAFEDB:1
            /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/SUPERSAFEDB:1 ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/SUPERSAFEDB:1
        else
            status "Supersafe is set off"
            /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/SUPERSAFEDB:0
            /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/SUPERSAFEDB:0 ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/SUPERSAFEDB:0
        fi

        #If we want to get our scripts out of the git repo, we better have git installed, so let's do it
        /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '${CUSTOM_USER_SUDO} /usr/bin/apt-get install -qq git ; /usr/bin/git init ; /bin/mkdir -p /home/${SERVER_USER}/bootstrap'"
        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/providerscripts/git/GitPull.sh ${BUILD_HOME}/providerscripts/git/GitFetch.sh ${BUILD_HOME}/providerscripts/git/GitCheckout.sh ${SERVER_USER}@${ip}:/home/${SERVER_USER}/bootstrap

        #Actually get our scripts from git repo
        /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '/home/${SERVER_USER}/bootstrap/GitPull.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-database-scripts ; /home/${SERVER_USER}/bootstrap/GitCheckout.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} db.sh ; /bin/chmod 700 /home/${SERVER_USER}/db.sh ; /bin/touch /home/${SERVER_USER}/${MACHINETYPE}'"
        #There was a sporadic issue on Linode debian instances at the time of testing where the first GitPull would fail, so I have put in a second
        #call for that reason and that reason alone
        /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/sh -c '/home/${SERVER_USER}/bootstrap/GitPull.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-database-scripts ; /home/${SERVER_USER}/bootstrap/GitCheckout.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} db.sh ; /bin/chmod 700 /home/${SERVER_USER}/db.sh ; /bin/touch /home/${SERVER_USER}/${MACHINETYPE}'"

        # Get the autoscaler ip address
        ASIP_PRIVATE="`/bin/ls ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/ASPRIVATEIP:* | /usr/bin/awk -F':' '{print $NF}'`"
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/CLOUDHOST:${CLOUDHOST}

        if ( [ "${BASELINE_DB_REPOSITORY}" != "" ] )
        then
            /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/BASELINEDBREPOSITORY:${BASELINE_DB_REPOSITORY}
            /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/BASELINEDBREPOSITORY:${BASELINE_DB_REPOSITORY} ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/BASELINEDBREPOSITORY:${BASELINE_DB_REPOSITORY}
        fi

        status "We are about to run the build script to actually build the machine into a database server"
        status "Please Note: The process of building the database is running on a remote machine with ip address : ${DBIP}"
        status "To access this machine once it has finished provisioning you can use the scripts in ${BUILD_HOME}/helperscripts"
        status "Log files (stderr and stdout) are stored on the remote machine in /home/${SERVER_USER}/logs"
        /bin/date >&3

        #Decide which build we are selecting to build from - virgin, hourly, daily, weekly, monthly, bimonthly
        if ( [ "${BUILD_CHOICE}" = "0" ] )
        then
            #We are building a virgin installation
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'virgin' ${SERVER_USER} ${BUILD_TYPE}"
    elif ( [ "${BUILD_CHOICE}" = "1" ] )
        then
            #We are building from a baseline
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'baseline' ${SERVER_USER} ${BUILD_TYPE}"
    elif ( [ "${BUILD_CHOICE}" = "2" ] )
        then
            #We are building from an hourly backup
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'hourly' ${SERVER_USER} ${BUILD_TYPE}"
    elif ( [ "${BUILD_CHOICE}" = "3" ] )
        then
            #We are building from an daily backup
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'daily' ${SERVER_USER} ${BUILD_TYPE}"
    elif ( [ "${BUILD_CHOICE}" = "4" ] )
        then
            #We are building from an weekly backup
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'weekly' ${SERVER_USER} ${BUILD_TYPE}"
    elif ( [ "${BUILD_CHOICE}" = "5" ] )
        then
            #We are building from an monthly backup
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'monthly' ${SERVER_USER} ${BUILD_TYPE}"
    elif ( [ "${BUILD_CHOICE}" = "6" ] )
        then
            #We are building from an bimonthly backup
            /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'bimonthly' ${SERVER_USER} ${BUILD_TYPE}"
        fi

        status "Finished building the database server"
        /bin/date >&3
        
        #Wait for the machine to become responsive before we check its integrity

        /usr/bin/ping -c 10 ${ip}

        while ( [ "$?" != "0" ] )
        do
            /usr/bin/ping -c 10 ${ip}
        done

        /bin/sleep 10

        done="0"
        #Check that the database is built and ready for action
        alive=""
        count2="0"
        while ( [ "${alive}" != "/home/${SERVER_USER}/runtime/DATABASE_READY" ] && [ "${count2}" -lt "10" ] )
        do
            count2="`/usr/bin/expr ${count2} + 1`"
            status "Checking that the database server has built correctly and is receiving connections..."
            alive="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "DEBIAN_FRONTEND=noninteractive /bin/ls /home/${SERVER_USER}/runtime/DATABASE_READY"`"
            /bin/sleep 30
        done

        if ( [ "${alive}" = "/home/${SERVER_USER}/runtime/DATABASE_READY" ] )
        then
            done=1
            built="`/usr/bin/expr ${built} + 1`"
        fi

        #If $done != 1 then it means the DB server didn't build correctly and fully, so destroy the machine it was being built on
        if ( [ "${done}" != "1" ] )
        then
            status "###########################################################################################################################"
            status "Hi, a database server didn't seem to build correctly. I can destroy it and try again to build a new database server for you"
            status "###########################################################################################################################"
            status "Press the <enter> key to be continue with the next attempt <ctrl - c> to exit"
            read response

            ${BUILD_HOME}/providerscripts/server/DestroyServer.sh ${ip} ${CLOUDHOST}
            
            if ( [ "${DBaaS_DBSECURITYGROUP}" != "" ] )
            then
                IP_TO_DENY="${ip}"
                . ${BUILD_HOME}/providerscripts/server/DenyDBAccess.sh
            fi

            /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBIP:${DBIP}
            /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBPRIVATEIP:${DBIP_PRIVATE}
            /bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBPRIVATEIP:${DBIP_PRIVATE}

            #Wait until we are sure that the database server(s) are destroyed because of a faulty build
            while ( [ "`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "database" ${CLOUDHOST} 2>/dev/null`" != "${built}" ] )
            do
                /bin/sleep 30
            done

            count1="`/usr/bin/expr ${count1} - 1`"

        else
            status "The database server seems to have built correctly, congratulations"
        fi
    else
        status "A Database is already running, using that one......"
        status "Press enter if that is OK"
        read response
        done=1
    fi
done

#If we get to here then we know that the database hasn't built correctly, so report it and exit
if ( [ "${counter}" = "5" ] )
then
    status "The infrastructure failed to intialise because of a build problem, please investigate, correct and rebuild"
    exit
fi
