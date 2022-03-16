#!/bin/sh
###############################################################################################
# Description: This is the top level build script for the Agile Deployment Toolkit.
# Author Peter Winter
# Date 07/06/2016
##############################################################################################
# Recommended best practice is to spin up a linux server on a cloud provider of your choice and
# once you have secured it, run this script. Currently supported are Ubuntu 20.04, 22.04 and
# debian 10 and debian 11. Security of your build server is important because sensitive information will
# be aggregated on it during the running of this script and you should consider a breach of your
# build server to be equivalent to a breach of your actual live server machines that you are deploying.
# This script is self explanatory, but, there are some additional notes in the documentation directory
# if you want to see some more detail about what it can do. 
# Likelihood is, it will take a couple of attempts to get a successful deploy but once you see how it
# all hangs together, you will be all set. 
###############################################################################################
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
################################################################################################
###############################################################################################
#set -x

status () {
    /bin/echo "$1" | /usr/bin/tee /dev/fd/3
}

#Couple of variables for you
export USER="`/usr/bin/whoami`"
export BUILD_HOME="`/bin/pwd`"

/bin/chmod -R 700 ${BUILD_HOME}/.

if ( [ ! -d ${BUILD_HOME}/logs ] )
then
    /bin/mkdir -p ${BUILD_HOME}/logs
fi

exec 3>&1
OUT_FILE="build_out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${BUILD_HOME}/logs/${OUT_FILE}
ERR_FILE="build_err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${BUILD_HOME}/logs/${ERR_FILE}

#Check that our current working directory is the same directory as this script
if ( [ ! -f ./AgileDeploymentToolkit.sh ] )
then
    status "####################################################################################################"
    status "This script is expected to run from the same directory as the AgileDeploymentToolkit.sh script is in"
    status "####################################################################################################"
    exit
fi

status "##################################################################################################################################"
status "WARNING, THIS SCRIPT WILL MAKE CHANGES AND INSTALL SOFTWWARE ON YOUR MACHINE. YOU SHOULD BE USING A DEDICATED LINUX MACHINE EITHER"
status "RUNNING ON A VPS SYSTEM, OR POSSIBLY OFF A PERSISTENT USB ON YOUR LOCAL MACHINE"
status "IF YOU ARE RUNNING THIS ON A LOCAL MACHINE, I RECOMMEND 'MX LINUX' ON A PERSISTENT USB"
status "IF YOU ARE RUNNING ON A VPS SYSTEM, UBUNTU 20.04 and up and DEBIAN 10 and up ARE SUPPORTED"
status "ENSURE THE MACHINE YOU ARE RUNNING THIS SCRIPT ON IS SECURED AS IT WILL HOLD SENSITIVE CREDENTIALS AND SO ON WITHIN ITS FILESYSTEM"
status "ONCE THE BUILD PROCESS COMPLETES"
status "IF YOU CONTINUE, YOU ACKNOWLEDGE THIS....."
status "##################################################################################################################################"
status "PRESS ENTER KEY TO CONTINUE"
read x

#source the environment
. `/bin/pwd`/buildscripts/BuildEnvironment.sh

export BUILD_HOME="`/bin/pwd`"

UPGRADE_LOG="${BUILD_HOME}/logs/upgrade_out-`/bin/date | /bin/sed 's/ //g'`"

status "#################################################################################################################################################"
status "Checking that the build software is up to date on this machine. Please wait .....This might take a few minutes the first time you run this script"
status "This is best practice to make sure that all the software is at its latest versions prior to the build process"
status "A log of the process is available at: ${UPGRADE_LOG}"
status "#################################################################################################################################################"

if ( [ ! -f ${BUILD_HOME}/runtimedata/AGUPDATEDSOFTWARE ] )
then
    if ( "`/usr/bin/find "${BUILD_HOME}/runtimedata/AGUPDATEDSOFTWARE" -mtime +10 -print 2>/dev/null`" = "" ] )
    then
        /bin/rm ${BUILD_HOME}/runtimedata/AGUPDATEDSOFTWARE
    else
        if ( [ ! -f ${BUILD_HOME}/runtimedata/AGUPDATEDSOFTWARE ] )
        then
            UPGRADE_LOG="${BUILD_HOME}/logs/upgrade_out-`/bin/date | /bin/sed 's/ //g'`"
	    
	    status "##################################################################################################"
	    status "I am about to make software changes on this machine. If you are OK with that, please press <enter>"
	    status "##################################################################################################"
	    read x

            status "##################################################################################################################################################"
            status "Checking that the build software is up to date on this machine. Please wait .....This might take a few minutes the first time you run this script"
            status "This is best practice to make sure that all the software is at its latest versions prior to the build process"
            status "A log of the process is available at: ${UPGRADE_LOG}"
            status "##################################################################################################################################################"

            if ( [ "`/usr/bin/awk -F= '/^NAME/{print $2}' /etc/os-release | /bin/grep "Ubuntu"`" != "" ] )
            then
                status "Performing software update....."
                ${BUILD_HOME}/installscripts/Update.sh "ubuntu"  >>${UPGRADE_LOG} 2>&1
                status "Performing software upgrade....."
                ${BUILD_HOME}/installscripts/Upgrade.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                #Make Sure python PIP is at the latest version:
                status "Updating Python....."
                ${BUILD_HOME}/installscripts/InstallPythonPIP.sh "ubuntu" >>${UPGRADE_LOG} 2>&1 
                ${BUILD_HOME}/installscripts/InstallPythonDateUtil.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                /bin/touch ${BUILD_HOME}/runtimedata/AGUPDATEDSOFTWARE
            elif ( [ "`/usr/bin/awk -F= '/^NAME/{print $2}' /etc/os-release | /bin/grep "Debian"`" != "" ] )
            then
                status "Performing software update....."
                ${BUILD_HOME}/installscripts/Update.sh "debian" >>${UPGRADE_LOG} 2>&1
                status "Performing software upgrade....."
                ${BUILD_HOME}/installscripts/Upgrade.sh "debian" >>${UPGRADE_LOG} 2>&1
                #Make Sure python PIP is at the latest version:
                status "Updating Python....."
                ${BUILD_HOME}/installscripts/InstallPythonPIP.sh "debian" >>${UPGRADE_LOG} 2>&1
                ${BUILD_HOME}/installscripts/InstallPythonDateUtil.sh "debian" >>${UPGRADE_LOG} 2>&1
                /bin/touch ${BUILD_HOME}/runtimedata/AGUPDATEDSOFTWARE
            fi
       fi
    fi
fi

actioned="0"
if ( [ -f /etc/ssh/ssh_config ] && [ "`/bin/grep 'ServerAliveInterval 240' /etc/ssh/ssh_config`" = "" ] )
then
    status ""
    status ""
    status "########################################################################################################################"
    status "Updating your client ssh config so that connections don't drop."
    status "If this is OK, press the <enter> key, if not, then ctrl-c to exit"
    status "########################################################################################################################"
    read response
    /bin/echo "" >> /etc/ssh/ssh_config
    /bin/echo "ServerAliveInterval 240" >> /etc/ssh/ssh_config
    /bin/echo "ServerAliveCountMax 5" >> /etc/ssh/ssh_config
    actioned="1"  
fi

if ( [ -f /etc/ssh/sshd_config ] && [ "`/bin/grep 'ClientAliveInterval 60' /etc/ssh/sshd_config`" = "" ] )
then
    status ""
    status ""
    status "########################################################################################################################"
    status "Updating your server ssh config so that connections don't drop from clients to this machine."
    status "If this is OK, press the <enter> key, if not, then ctrl-c to exit"
    status "########################################################################################################################"
    read response
    /bin/echo "" >> /etc/ssh/sshd_config
    /bin/echo "ClientAliveInterval 60
TCPKeepAlive yes
ClientAliveCountMax 10000" >> /etc/ssh/sshd_config
    /usr/sbin/service sshd restart
    actioned="1"
fi

if ( [ "${actioned}" = "1" ] )
then
    status "############################YOU WILL ONLY NEED TO DO THIS ON THE FIRST RUN THROUGH ################################################################"
    status "SSH configuration settings have been updated, please rerun the AgileDeploymentToolkit script so that they are picked up"
    status "NOTE: if this is a VPS machine running remotely to your desktop, please make sure that you desktop machine is also configured to not drop"
    status "SSH connections within a few minutes as this will interrupt the build"
    status "############################YOU WILL ONLY NEED TO DO THIS ON THE FIRST RUN THROUGH ################################################################"
    exit
fi

#Check that we are 64 bit
if ( [ "`/usr/bin/dpkg --print-architecture`" = "i386" ] )
then
    status "############################################################################################################"
    status "Darn it. This script requires a 64 bit machine to run on. I have to exit. If you don't have a 64 bit machine"
    status "To build on of your own, you can spin one up in the cloud (ubuntu 20.04 and up) or (debian 10 and up ) and use that as your build machine to deploy from"
    status "############################################################################################################"
    exit
fi

#Display a brief message to compel the user to take extra care with their inputs
status ""
status "######################################################################################################################"
status "When you put in the data for this build process, take your time and double check it to make sure it is exactly correct"
status "Entering erroneous, incorrect or unintended answers may result unexpected behaviour from this build script including failure to complete"
status "Assuredly, I tried to put as much fail safe as possible into it."
status "#######################################################################################################################"
status "Press <enter> to start"
read answer

#Check that you are root and if not make some recommendations
if ( [ "`/usr/bin/id -u`" != "0" ] )
then
    status ""
    status ""
    status "###################################################################################################################################"
    status "You need to run this script either directly as root or with the sudo command as it needs to make some installations to your machine"
    status "If this is a problem and you don't want stuff installed on your machine, I recommend that you spin up a dedicated build machine"
    status "in the cloud for dedicated use when building/deploying with this toolkit (ubuntu 20.04 and up or debian 10 and up) are suitable build machines to use"
    status "###################################################################################################################################"
    exit
fi
/bin/echo "Most of the messages you will see here are soft errors. All errors are recorded though, should you need to review them" > ${BUILD_HOME}/logs/${ERR_FILE}

status "#################################################################################################"
status "If the build process freezes or fails to complete for some reason, please review the error stream"
status "The error stream for this build is located at: ${BUILD_HOME}/logs/${ERR_FILE}"
status "#################################################################################################"
status "Press <enter> to continue"
read x

#If this is set, the user who ran it previously, then we know that this is not our first time running the script
if ( [ ! -f ${BUILD_HOME}/runtimedata/INSTALLUSER ] )
then
    status "##############################################"
    status "It doesn't seem like you have run this before"
    status "Press <enter> when you are ready"
    status "##############################################"
    read response
    /bin/mkdir -p ${BUILD_HOME}/runtimedata
    /bin/echo "${USER}" > ${BUILD_HOME}/runtimedata/INSTALLUSER
fi

#Here we set the ports we want the DB and the ssh daemon to listen on. If you choose your own port
#for these, please ensure that they are free on your server. There are no checks or work arounds
#if the port is already taken and it is likely the build will fail.
#YOU ARE ENCOURAGED TO SET YOUR OWN PORT FOR YOUR DATABASE. CHECK WITH YOUR DATBASE WHEN IT
#IS RUNNING AND SELECT A PORT WHICH IS FREE IF YOU ARE USING DBaaS, MAKE SURE THE DATABASE
#HAS BEEN DEPLOYED WITH THE CORRECT PORT WITH YOUR DB as a Service provider
status ""
status ""
status "###########################################################################################"
status "By default the port used for the database (if you deploy one) is 2035."
status "If you would like to use another port, please enter it now. Press <enter> to accept default"
status "###########################################################################################"
status "Enter your preferred port or <enter> to accept default (2035)"
read DB_PORT

if ( [ "${DB_PORT}" = "" ] )
then
    DB_PORT="2035"
    status "Database port set to default value: 2035"
else
    /usr/bin/expr "${DB_PORT}" : '[0-9][0-9]*$' >/dev/null 2>&1
    while ( [ "$?" != "0" ] )
    do
        status "Doesn't look like a port number, try again..."
        read DB_PORT

        if ( [ "${DB_PORT}" = "" ] )
        then
            DB_PORT="2035"
        fi

        /usr/bin/expr ${DB_PORT} : '[0-9][0-9]*$' >/dev/null 2>&1
    done
fi

status
status
status "####################################################################################################"
status "By default the port used for secure shell connections is 1035."
status "If you would like to use another port, please enter it now, othewise press <enter> to accept default"
status "####################################################################################################"
status "Please enter your preferred SSH port, <enter> to accept the default (1035)"
read SSH_PORT


if ( [ "${SSH_PORT}" = "" ] )
then
    SSH_PORT="1035"
    status "Secure Shell port set to default value: 1035"
else
    /usr/bin/expr "${SSH_PORT}" : '[0-9][0-9]*$'
    while ( [ "$?" != "0" ] )
    do
        status "Doesn't look like a port number, try again..."
        read SSH_PORT

        if ( [ "${SSH_PORT}" = "" ] )
        then
            SSH_PORT="1035"
        fi

        /usr/bin/expr "${SSH_PORT}" : '[0-9][0-9]*$'
    done
fi

status ""
status ""

#Let the user set the timezone they are in. This will be used on the deployed servers also.
#So, be aware, if you are in a different timezone to where you are making your deployment,
#you way want to set the timezone to be where your servers are, not where you are, necessarily
. ${BUILD_HOME}/SelectTimezone.sh

#Set a unique identifier for this build so it can be easily distinguised from all the other builds
#A good unique identifier is the subdomain of your deployment. So, if you are deploying to
#london.marionettes.community a good unique identifier might be 'london'. Then if you are deploying
#to edinburgh.marionettes.community, then a good unique identifier might be 'edinburgh' and so on.

status ""
status ""
status "##################################################################################################"
status "#####Please enter a unique build identifier for this build. It needs to uniquely identify     #####"
status "#####This build. For example, if I am building my sample 'nuocial' application with subdomain #####"
status "#####testbuild1, then I would set my buildidentifier as testbuild1nuocial. If I then performed#####"
status "#####another build for subdomain testbuild2 I would set my build identifier to testbuild2     #####" 
status "#####If you use the same build identifier that you used for a previous (successful) build,    #####"
status "#####Then, I will present you with an option to use the same build settings as you used for   #####"
status "#####that build which will expedite the process for you                                       #####"
status "###################################################################################################"
status "Enter Build Identifier please:"
read BUILD_IDENTIFIER

while ( [ "${BUILD_IDENTIFIER}" = "" ] )
do
    status "The build identifier can't be blank, try again...."
    read BUILD_IDENTIFIER
done

BUILD_IDENTIFIER="`/bin/echo ${BUILD_IDENTIFIER} | /usr/bin/tr '[:upper:]' '[:lower:]' | /bin/sed 's/-//g'`"

status ""
status ""

if ( [ "`/usr/bin/crontab -l | /bin/grep "BackupBuildMachine.sh" | /bin/grep "${BUILD_IDENTIFIER}"`" != "" ] )
then
    status "Your system is set to make backups of your build machine on a daily basis for build identifier ${BUILD_IDENTIFIER}"
    status "Press <enter> to continue"
    read x
else
    BACKUP_PASSWORD="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-8`"
    status "###############################################################################################"
    status "YOUR BACKUP PASSWORD IS SET TO: ${BACKUP_PASSWORD} FOR THIS BUILD, PLEASE MAKE A NOTE OF IT"
    status "###############################################################################################"
    status "If you you don't want to make backups of your build machine for safety enter N other wise  press <enter>"
    read response
    if ( [ "${response}" = "N" ] || [ "${response}" = "n" ] )
    then
        BACKUP_PASSWORD=""
    fi
fi

/bin/chown -R ${USER} ${BUILD_HOME}/.
/bin/chmod -R 700 ${BUILD_HOME}/.

#Make sure that our ssh connections are long lasting. In the case where the user is building from their own desktop machine,
#this will be changing settings on their machine so we ask it it is OK. If they are using a dedicated build server in the cloud,
#then it shouldn't matter so much
if ( [ ! -d ~/.ssh ] )
then
    /bin/mkdir ~/.ssh
fi

#Create a build configuration directory. This is where we persist our build settings so that they can be reused between builds.
#So, if you make a deployment of an application, you can reuse your settings if you ever take it offline and redeploy again.
if ( [ ! -d ${BUILD_HOME}/buildconfiguration ] )
then
    /bin/mkdir ${BUILD_HOME}/buildconfiguration
fi

#Just make a note of the build home directory for future use
/bin/echo "${BUILD_HOME}" > ${BUILD_HOME}/buildconfiguration/buildhome

#Interrogate the user as to which OS they want to run on their servers
. ${BUILD_HOME}/SelectDeploymentOS.sh

if ( [ ! -f /usr/sbin/ufw ] )
then
    ${BUILD_HOME}/installscripts/InstallUFW.sh "${BUILDOS}"
fi

#These have to be persisted here for later use (necessary in case we decide to use the .dat file from a previous build, in which case these
#values may be different to what we have set this time). To see where these are mostly set, look to the end of the Finaliser script in the
#buildscripts directory

if ( [ ! -d ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} ] )
then
    /bin/mkdir -p ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}
fi
/bin/touch ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}

/bin/sed -i '/DB_PORT=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export DB_PORT=\"${DB_PORT}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/SSH_PORT=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export SSH_PORT=\"${SSH_PORT}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/SERVER_TIMEZONE_CONTINENT=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export SERVER_TIMEZONE_CONTINENT=\"${SERVER_TIMEZONE_CONTINENT}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/SERVER_TIMEZONE_CITY=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export SERVER_TIMEZONE_CITY=\"${SERVER_TIMEZONE_CITY}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/BUILDOS=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export BUILDOS=\"${BUILDOS}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/BUILDOS_VERSION=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export BUILDOS_VERSION=\"${BUILDOS_VERSION}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/CLOUDHOST=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export CLOUDHOST=\"${CLOUDHOST}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/MACHINE_TYPE=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export MACHINE_TYPE=\"${MACHINE_TYPE}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/ALGORITHM=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export ALGORITHM=\"${ALGORITHM}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/CLOUDHOST_USERNAME=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export CLOUDHOST_USERNAME=\"${CLOUDHOST_USERNAME}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/CLOUDHOST_PASSWORD=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export CLOUDHOST_EMAIL_ADDRESS=\"${CLOUDHOST_EMAIL_ADDRESS}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/CLOUDHOST_EMAIL_ADDRESS=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export CLOUDHOST_PASSWORD=\"${CLOUDHOST_PASSWORD}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/AUTOSCALE_FROM_SNAPSHOTS=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export AUTOSCALE_FROM_SNAPSHOTS=\"${AUTOSCALE_FROM_SNAPSHOTS}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/WEBSERVER_SNAPSHOT_NAME=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export WEBSERVER_SNAPSHOT_NAME=\"${WEBSERVER_SNAPSHOT_NAME}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/WEBSERVER_IMAGE_ID=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export WEBSERVER_IMAGE_ID=\"${WEBSERVER_IMAGE_ID}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/AUTOSCALER_IMAGE_ID=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export AUTOSCALER_IMAGE_ID=\"${AUTOSCALER_IMAGE_ID}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/DATABASE_IMAGE_ID=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export DATABASE_IMAGE_ID=\"${DATABASE_IMAGE_ID}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/GENERATE_SNAPSHOTS=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export GENERATE_SNAPSHOTS=\"${GENERATE_SNAPSHOTS}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/sed -i '/SNAPSHOT_ID=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/echo "export SNAPSHOT_ID=\"${SNAPSHOT_ID}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}

#Ask the user what cloudhost (has to be a supported cloudhost) they want to deploy to this time
. ${BUILD_HOME}/SelectCloudhost.sh

#Configure the datastore (s3cmd tool)
. ${BUILD_HOME}/providerscripts/datastore/SetupConfiguration.sh
. ${BUILD_HOME}/providerscripts/datastore/ObtainSnapshotData.sh
. ${BUILD_HOME}/initscripts/InitialiseSMTPMailServer.sh

if (    [ "`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh "autoscale*" ${CLOUDHOST} 2> /dev/null`" != "" ] )
then
    status "#####################################################################################"
    status "It seems like there is an autoscaler already running please close it down and rebuild"
    status "#####################################################################################"
    exit
fi

if ( [ "`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh "webserver*" ${CLOUDHOST} 2> /dev/null`" != "" ] )
then
    status "###############################################################################"
    status "It seems like the webserver is already running please close it down and rebuild"
    status "###############################################################################"
    exit
fi

if ( [ "`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh "database*" ${CLOUDHOST} 2> /dev/null`" != "" ] )
then
    status "##############################################################################"
    status "It seems like the database is already running please close it down and rebuild"
    status "##############################################################################"
    exit
fi

if ( [ ! -d ${BUILD_HOME}/runtimedata/${CLOUDHOST}${BUILD_IDENTIFIER} ] )
then
    /bin/mkdir -p ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}
fi

if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} ] )
then
    /bin/mkdir -p ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}
    /bin/touch ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
fi

if ( [ ! -d ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials ] )
then
    /bin/mkdir -p ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials
fi

#Get the ip address of our build machine
BUILD_CLIENT_IP="`/usr/bin/wget http://ipinfo.io/ip -qO -`"

#Initialise required software for the build process
. ${BUILD_HOME}/initscripts/InitialiseBuild.sh

#Setup logging directory
if ( [ ! -d ${BUILD_HOME}/logs ] )
then
    /bin/mkdir -p ${BUILD_HOME}/logs
fi

/bin/rm ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/*

if ( [ ! -d ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials ] )
then
    /bin/mkdir -p ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials
fi

if ( [ ! -d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/ips ] )
then
    /bin/mkdir -p ${BUILD_HOME}/runtimedata/${CLOUDHOST}/ips
fi
if ( [ ! -d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/names ] )
then
    /bin/mkdir -p ${BUILD_HOME}/runtimedata/${CLOUDHOST}/names
fi

#If we are reusing a configuration from a previous build, this will be set to 1. By default it is set to 0, meaning it is a
#fresh build by default
PREVIOUS_BUILD_CONFIG="0"

#Check if we have persisted the configuration from a previous build. We can reuse it if we desire or setup a new configuration
if ( [ "`/bin/grep 'GIT_EMAIL_ADDRESS' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}`" != "" ] )
then
    status ""
    status ""
    status "#####################################################################################################"
    status "#####It seems like you have built the ${BUILD_IDENTIFIER} build before                          #####"
    status "#####################################################################################################"
    status "Press <enter> to list and review the settings of the previous build"
    read response
    /bin/cat  ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} >&3

    status ""
    status ""
    status "####################################################################################################"
    status "I have listed the current configuration settings. You have a few options:"
    status "1) Accept the listed settings from a previous build as they are (Enter Y and accept settings)"
    status "2) Go and edit the config file: ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} and"
    status "  press <ctrl-c> and begin the build process again and select Y when you get to here to accept the mods"
    status "3) Entirely reject the listed settings displayed and re run the configuration process in full (enter N below)"
    status "####################################################################################################"
    status "Please review the listed settings and enter (Y|y) to use the settings that have been previously stored in:"
    status "${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}"
    read response

    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        if ( [ -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} ] )
        then
            #We have successfully found a config file with the full complement of variables, so we can source it here
            . ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
            PREVIOUS_BUILD_CONFIG="1"
        else
            #We didn't find a valid config file, notify, but then continue with the build process as normal
            status "Config file: ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} doesn't have the full set of variables"
            status "Continuing with runtime configuration process instead...which should correct it"
        fi
    else
        /bin/rm ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
        /bin/touch ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
    fi
fi

#If we are not using a previous build configuration, then we have to interogate the user for build configuration options
if ( [ "${PREVIOUS_BUILD_CONFIG}" = "0" ] )
then
    #Run through a whole sequence of steps to actually make sure we are ready to perform our build process
    . ${BUILD_HOME}/SelectApplicationIdentifier.sh
    . ${BUILD_HOME}/SelectApplicationLanguage.sh
    . ${BUILD_HOME}/EnterDisplayName.sh
    . ${BUILD_HOME}/EnterWebsiteURL.sh
    . ${BUILD_HOME}/SelectWebserver.sh
    . ${BUILD_HOME}/SelectDNSProvider.sh
    . ${BUILD_HOME}/SelectSSLMethod.sh
    . ${BUILD_HOME}/SelectMapsKey.sh
fi

#Set a username and password which we can set on all our servers. Once the machines are built, password authentication is
#switched off and you can find some ssh key based helper scripts here that will enable you to authenticate to your machines.
SERVER_USER="X`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-18`X"
SERVER_USER_PASSWORD="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-18`"

/bin/echo "${SERVER_USER}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSER
/bin/echo "${SERVER_USER_PASSWORD}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSERPASSWORD

#Perform all the initialisation necessary

. ${BUILD_HOME}/initscripts/InitialiseSourcecodeRepository.sh
. ${BUILD_HOME}/initscripts/InitialiseSecurityKeys.sh
. ${BUILD_HOME}/initscripts/InitialiseCaching.sh
. ${BUILD_HOME}/initscripts/InitialiseGuardianGateway.sh
. ${BUILD_HOME}/initscripts/InitialiseDatabase.sh
. ${BUILD_HOME}/BackupBuildMachine.sh
. ${BUILD_HOME}/initscripts/InitialiseBuildParams.sh
. ${BUILD_HOME}/initscripts/InitialiseDatastore.sh
. ${BUILD_HOME}/initscripts/InitialiseBuildChoice.sh
. ${BUILD_HOME}/providerscripts/datastore/PersistBuildClientIP.sh
export PRE_BUILD="1"
. ${BUILD_HOME}/providerscripts/security/firewall/SetupNativeFirewall.sh

/bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/* 2>/dev/null

/bin/mkdir -p ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/${BUILD_CLIENT_IP}

. ${BUILD_HOME}/providerscripts/server/ObtainSubnetID.sh
. ${BUILD_HOME}/providerscripts/server/ProvisionElasticFS.sh

. ${BUILD_HOME}/buildscripts/BuildAndDeployDBaaS.sh

status "################################################################################################################################################"
status "Cleaning out the configuration bucket and expired config settings in the datastore"
status "################################################################################################################################################"
. ${BUILD_HOME}/providerscripts/datastore/PurgeDatastore.sh

status "##############################################################################################"
status "A recommended solution if you want to roll your own mail server with a custom domain for your"
status "users' email addresses is to be found at: https://www.iredmail.org/"
status "If you follow the instructions you should be able to have your own mail server which might have"
status "an advantage to your application in that you might be able to configure it such that new users"
status "have to have been allocated an email address with your custom domain before they can register"
status "for the application. This is neat from several points of view, not least that your users can"
status "separate out their application related emails to their community or application specific email address"
status "###############################################################################################"
status "Press <enter> to begin building your application"
read x

# I think the usual phrase is, 'we are all set'. So, tell the user we are starting the build proper.
status ""
status ""
status ""
/usr/bin/banner "Starting......" >&3
status "##############################################################################################"
status "About to actually build and configure the servers that your deployment will run on"
status "Some of these commands can take significant amounts of time to complete and it may look like  "
status "nothing is happening. This is the sanitised presentation of progress. If you want a warts and "
status "all view of the truth, then, you can look for the set -x command in each script and uncomment "
status "it. That will spew up all the info for the build."
status ""
status "OK, about to begin building your deployment........"
status "##############################################################################################"
status ""
status ""
status ""

#Set a timestamp so we can tell how long the build took. It various considerably by cloudhost provider.
start=`/bin/date +%s`

#If we have anything to say here, on an application by application basis before the build really begins we put it in this
#script
. ${BUILD_HOME}/PreProcessingMessages.sh

#Actually run the build scripts to build each of our server types

#We want to get our key store setup so that when we build the machines they can grab the private key from the keystore rather than
#passing the filename in as a -i parameter to ssh which is unwieldy.
/bin/cat ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} >> ~/.ssh/${SERVER_USER}.key
/bin/chmod 400 ~/.ssh/${SERVER_USER}.key
/bin/mv ~/.ssh/config ~/.ssh/config.${SERVER_USER}


if ( [ "${AUTOSCALE_FROM_SNAPSHOTS}" = "1" ] )
then
    status "###############################################################################################################################################"
    status "Performing a snapshot style build. If this is what you want, press <enter> if not <ctrl-c> to reconfigure"
    status "###############################################################################################################################################"
    read carryon

    if ( [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
    then
        status "##############################################################################################################"
        status "You have selected to use a 3rd party DBaaS for your database solution"
        status "It is fine to do this when building from snapshots, but there is a caveat that all the credentials have to be"
        status "the same as when you generated the snapshot as part of an initial build process"
        status "This means that you can't have changed the username, password, hostname, ip addresses and so on in the interim"
        status "period between when you generated the snapshot you are now building from and now."
        status "I am expecting you to have the following active and online"
        status "A Database with username: ${DBaaS_USERNAME}"
        status "A Database with password: ${DBaaS_PASSWORD}"
        status "A Database with the name: ${DBaaS_DBNAME}"
        status "A Database at Endpoint: ${DBaaS_HOSTNAME}"
        status "##############################################################################################################"
        status "If all these things are configured and set, then it is OK to :"
        status "Press the <enter> key to continue"
        read x
    fi
    
    status "How many autoscalers do you want to deploy?"
    read NO_AUTOSCALERS
    while ! ( [ "${NO_AUTOSCALERS}" -eq "${NO_AUTOSCALERS}" ] )
    do
        status "Sorry, invalid input, try again"
        read NO_AUTOSCALERS
    done
    . ${BUILD_HOME}/buildscripts/BuildFromSnapshots.sh
    . ${BUILD_HOME}/providerscripts/security/firewall/TightenDBaaSFirewall.sh
    /bin/touch /tmp/PRIME_FIREWALL
    . ${BUILD_HOME}/providerscripts/security/firewall/TightenBuildMachineFirewall.sh

    status ""
    status "##########################################################################################################"
    status "Build from snapshots completed"
    status "It will take a few minutes before your site comes online. Anything more than 10 minutes before it is online"
    status "Means that there is something wrong and you should start to investigate"
    status "##########################################################################################################"
else
    status "###############################################################################################################################################"
    status "Performing a regular style build (no snapshots used). If this is what you want, press <enter> if not <ctrl-c> to reconfigure"
    
    if ( [ "${GENERATE_SNAPSHOTS}" = "1" ] )
    then
         status "SNAPSHOTS OF YOUR MACHINES WILL BE GENERATED FOR FUTURE USE"
    else
         status "NO SNAPSHOTS ARE BEING GENERATED"
    fi
    
    status "###############################################################################################################################################"
    read carryon
    
    #Call the build scripts. These actually build and deploy the machines. Until this point, there was nothing new running on
    #our cloudhosts machines.
    NO_AUTOSCALERS="1"
    
    if ( [ "${PRODUCTION}" != "0" ] && [ "${DEVELOPMENT}" != "1" ] && [ "${BASELINE_DB_REPOSITORY}" != "VIRGIN" ] )
    then
    	if ( [ "${GENERATE_SNAPSHOTS}" != "1" ] )
	    then
            status "How many autoscalers do you want to deploy?"
            read NO_AUTOSCALERS
            while ! ( [ "${NO_AUTOSCALERS}" -eq "${NO_AUTOSCALERS}" ] )
            do
                status "Sorry, invalid input, try again"
                read NO_AUTOSCALERS
            done
	else
	    status "One autoscaler is being deployed (generate snapshots is active)"
        fi
        . ${BUILD_HOME}/buildscripts/BuildAutoscaler.sh
    fi

    . ${BUILD_HOME}/buildscripts/BuildWebserver.sh
    . ${BUILD_HOME}/buildscripts/BuildDatabase.sh
    . ${BUILD_HOME}/providerscripts/security/firewall/TightenDBaaSFirewall.sh
    /bin/touch /tmp/PRIME_FIREWALL
    . ${BUILD_HOME}/providerscripts/security/firewall/TightenBuildMachineFirewall.sh

    ##Do the build finalisation procedures
    . ${BUILD_HOME}/buildscripts/FinaliseBuildProcessing.sh
fi

    
status "Just making a final adjustment to your native firewalling system , please wait...."
export PRE_BUILD="0"
. ${BUILD_HOME}/providerscripts/security/firewall/SetupNativeFirewall.sh

#If we have any messages to put out to the user post build, we add them to this script
. ${BUILD_HOME}/PostProcessingMessages.sh

#We inform the users of their credentials. Sometimes, depending on the application, the user needs to know more or less
#Some applications we can configure for use behind the scenes, other times, the user has to do some stuff in the gui to
#get to the point where the application can be used. In the later case, any additional information will be added here.

status ""
status "###################################################################################################################"
status "IMPORTANT, THE USERNAME FOR YOUR SERVERS IS: ${SERVER_USER}"
status "THE PASSWORD FOR YOUR SERVERS IS: ${SERVER_USER_PASSWORD}"
status "CONSIDER ANY COMPROMISE OF THESE CREDENTIALS AS POTENTIALLY GIVING ROOT ACCESS TO YOUR SERVERS. KEEP THEM VERY SECURE"
status "A COPY OF THESE CREDENTIALS IS STORED IN:"
status "SERVER USERNAME :  ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSER"
status "SERVER PASSWORD :  ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSERPASSWORD"
status "###################################################################################################################"
status "That should be your application built and online."
status "OK, have fun with it...."

#Output how long the build took
end=`/bin/date +%s`
runtime="`/usr/bin/expr ${end} - ${start}`"
status "This script took `/bin/date -u -d @${runtime} +\"%T\"` to complete"

#Might be needed for the updates we applied at the start. The user can ssh onto the machie again and tail the logs to see what happened. 
/usr/sbin/shutdown -r now

