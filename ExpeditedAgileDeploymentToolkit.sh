#!/bin/sh
###############################################################################################
# Description: This is the the expedited version of the top level build script for the 
# Agile Deployment Toolkit.
# Author Peter Winter
# Date 22/9/2020
##############################################################################################
# Recommended best practice is to spin up a linux server on a cloud provider of your choice and
# once you have secured it, run this script. Currently supported are Ubuntu 18.04, 20.04 and
# debian 9 and 10. Security of your build server is important because sensitive information will
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

#Check that our current working directory is the same directory as this script

if ( [ ! -f ./ExpeditedAgileDeploymentToolkit.sh ] )
then
    status "#############################################################################################################"
    status "This script is expected to run from the same directory as the ExpeditedAgileDeploymentToolkit.sh script is in"
    status "#############################################################################################################"
    exit
fi

export BUILD_HOME="`/bin/pwd`"
export USER="`/usr/bin/whoami`"
/bin/chmod -R 700 ${BUILD_HOME}/.

if ( [ ! -d ${BUILD_HOME}/logs ] )
then
    /bin/mkdir -p ${BUILD_HOME}/logs
fi

status "##################################################################################################################################"
status "WARNING, THIS SCRIPT WILL MAKE CHANGES AND INSTALL SOFTWWARE ON YOUR MACHINE. YOU SHOULD BE USING A DEDICATED LINUX MACHINE EITHER"
status "RUNNING ON A VPS SYSTEM, OR POSSIBLY OFF A PERSISTENT USB ON YOUR LOCAL MACHINE"
status "IF YOU ARE RUNNING THIS ON A LOCAL MACHINE, I RECOMMEND 'MX LINUX' ON A PERSISTENT USB"
status "IF YOU ARE RUNNING ON A VPS SYSTEM, UBUNTU 20.04 and DEBIAN 10 ARE SUPPORTED"
status "ENSURE THE MACHINE YOU ARE RUNNING THIS SCRIPT ON IS SECURED AS IT WILL HOLD SENSITIVE CREDENTIALS AND SO ON WITHIN ITS FILESYSTEM"
status "ONCE THE BUILD PROCESS COMPLETES"
status "IF YOU CONTINUE, YOU ACKNOWLEDGE THIS....."
status "##################################################################################################################################"
status "PRESS ENTER KEY TO CONTINUE"
read x

actioned="0"
if ( [ -f /etc/ssh/ssh_config ] && [ "`/bin/cat /etc/ssh/ssh_config | /bin/grep 'ServerAliveInterval 240'`" = "" ] )
then
    /bin/echo ""
    /bin/echo ""
    /bin/echo "########################################################################################################################"
    /bin/echo "Updating your client ssh config so that connections don't drop."
    /bin/echo "If this is OK, press the <enter> key, if not, then ctrl-c to exit"
    /bin/echo "########################################################################################################################"
    read response
    /bin/echo "ServerAliveInterval 240" >> /etc/ssh/ssh_config
    /bin/echo "ServerAliveCountMax 5" >> /etc/ssh/ssh_config
    actioned="1"  
fi

if ( [ -f /etc/ssh/sshd_config ] && [ "`/bin/cat /etc/ssh/sshd_config | /bin/grep 'ClientAliveInterval 60'`" = "" ] )
then
    /bin/echo ""
    /bin/echo ""
    /bin/echo "########################################################################################################################"
    /bin/echo "Updating your server ssh config so that connections don't drop from clients to this machine."
    /bin/echo "If this is OK, press the <enter> key, if not, then ctrl-c to exit"
    /bin/echo "########################################################################################################################"
    read response
    /bin/echo "ClientAliveInterval 60
TCPKeepAlive yes
ClientAliveCountMax 10000" >> /etc/ssh/sshd_config
    /usr/sbin/service sshd restart
    actioned="1"
fi

if ( [ "${actioned}" = "1" ] )
then
    /bin/echo "############################YOU WILL ONLY NEED TO DO THIS ON THE FIRST RUN THROUGH ################################################################"
    /bin/echo "SSH configuration settings have been updated, please rerun the ExpeditedAgileDeploymentToolkit script so that they are picked up"
    /bin/echo "NOTE: if this is a VPS machine running remotely to your desktop, please make sure that you desktop machine is also configured to not drop"
    /bin/echo "SSH connections within a few minutes as this will interrupt the build"
    /bin/echo "############################YOU WILL ONLY NEED TO DO THIS ON THE FIRST RUN THROUGH ################################################################"
    exit
fi

status "#########################################################################################################################################################"
status "This is the Expedited Agile Deployment toolkit. It REQUIRES a configuration template which has ALL the necessary parameters populated within it"
status "Templates for each cloudhost are stored under ${BUILD_HOME}/templatedconfigurations/<yourcloudhost>/template[n].tmpl"
status "You can create a new template for selection by naming it ${BUILD_HOME}/templatedconfigurations/<yourcloudhost>/template[n+1].tmpl
status "ALL of the configuration parameters must be sane and correct and without errors for a build to complete correctly"
status "There's a few ways you can run a build process. You can use the AgileDeploymentToolkit or the ExpeditedAgileDeploymentToolkit. Each are a little different"
status "To perform a build with this toolkit."
status "1: You can run the ExpeditedAgileDeploymentToolkit.sh and use one of the predefined configuration templates that we have provided"
status "   In this case, as a minimum, you will need to modify the following configuration settings to match your own needs within in your copy of the default template:"




status "2: You can take one of the predefined templates, make a copy and modify it to make a custom configuration template"
status "3: You can run the AgileDeploymentToolkit.sh script and at the end it will create a basic template which you can copy make your own template out of"
status "   This is a safe and easy way to create templates such that you can perform expedited builds. You will need to modify values within your template"
status "   if, for example, you are using different credentials, if, for example you are switching to a managed database from a regular VPS hosted deployment"
status "4. Expert: You can completely hand craft your own template from scratch. This requires that you know what you are doing in detail and is the most error prone"
status "#########################################################################################################################################################"
status "Press the <enter> key to acknowledge this"
read x

UPGRADE_LOG="${BUILD_HOME}/logs/upgrade_out-`/bin/date | /bin/sed 's/ //g'`"

/bin/echo "##############################################################################################################"
/bin/echo "Checking that the build software is up to date on this machine. Please wait .....This might take a few minutes"
/bin/echo "A log of the process is available at: ${UPGRADE_LOG}"
/bin/echo "##############################################################################################################"

if ( [ "`/usr/bin/awk -F= '/^NAME/{print $2}' /etc/os-release | /bin/grep "Ubuntu"`" != "" ] )
then
    ./installscripts/Update.sh "ubuntu"  >>${UPGRADE_LOG} 2>&1
    ./installscripts/Upgrade.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
    #Make Sure python PIP is at the latest version:
    ./installscripts/PurgePython.sh "ubuntu" >>${UPGRADE_LOG} 2>&1 
    ./installscripts/InstallPythonPIP.sh "ubuntu" >>${UPGRADE_LOG} 2>&1 
    ./installscripts/InstallPythonDateUtil.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
    . ${BUILD_HOME}/buildscripts/InitialiseBuild.sh >>${UPGRADE_LOG} 2&1

elif ( [ "`/usr/bin/awk -F= '/^NAME/{print $2}' /etc/os-release | /bin/grep "Debian"`" != "" ] )
then
    ./installscripts/Update.sh "debian" >>${UPGRADE_LOG} 2>&1
    ./installscripts/Upgrade.sh "debian" >>${UPGRADE_LOG} 2>&1
    #Make Sure Python PIP is at the latest version:
    ./installscripts/PurgePython.sh "debian" >>${UPGRADE_LOG} 2>&1
    ./installscripts/InstallPythonPIP.sh "debian" >>${UPGRADE_LOG} 2>&1
    ./installscripts/InstallPythonDateUtil.sh "debian" >>${UPGRADE_LOG} 2>&1
    . ${BUILD_HOME}/buildscripts/InitialiseBuild.sh >>${UPGRADE_LOG} 2&1
fi

#Check that we are 64 bit
if ( [ "`/usr/bin/dpkg --print-architecture`" = "i386" ] )
then
    /bin/echo "############################################################################################################"
    /bin/echo "Darn it. This script requires a 64 bit machine to run on. I have to exit. If you don't have a 64 bit machine"
    /bin/echo "To build on of your own, you can spin one up in the cloud (ubuntu 20.04 and up) or (debian 10 and up ) and use that as your build machine to deploy from"
    /bin/echo "############################################################################################################"
    exit
fi

#Check that you are root and if not make some recommendations
if ( [ "`/usr/bin/id -u`" != "0" ] )
then
    /bin/echo
    /bin/echo
    /bin/echo "###################################################################################################################################"
    /bin/echo "You need to run this script either directly as root or with the sudo command as it needs to make some installations to your machine"
    /bin/echo "If this is a problem and you don't want stuff installed on your machine, I recommend that you spin up a dedicated build machine"
    /bin/echo "in the cloud for dedicated use when building/deploying with this toolkit (ubuntu 20.04 or debian 10) are suitable build machines to use"
    /bin/echo "###################################################################################################################################"
    exit
fi

exec 3>&1
OUT_FILE="build_out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${BUILD_HOME}/logs/${OUT_FILE}
ERR_FILE="build_err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${BUILD_HOME}/logs/${ERR_FILE}

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

status ""
status ""

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

if ( [ ! -f /usr/sbin/ufw ] )
then
    ${BUILD_HOME}/installscripts/InstallUFW.sh "${BUILDOS}"
fi

status ""
status ""
status "########################################################################################################################"
status "Setting up and enabling the firewall to help lock down this machine"
status "If this is OK, press the <enter> key, if not, then ctrl-c to exit"
status "########################################################################################################################"

/usr/sbin/ufw default deny incoming
/usr/sbin/ufw default allow outgoing
/usr/sbin/ufw allow ssh
/usr/sbin/ufw enable


. ${BUILD_HOME}/SelectCloudhost.sh
. ${BUILD_HOME}/providerscripts/datastore/SetupConfiguration.sh

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

#Perform all the initialisation necessary

. ${BUILD_HOME}/buildscripts/InitialiseSourcecodeRepository.sh
. ${BUILD_HOME}/buildscripts/InitialiseSecurityKeys.sh
. ${BUILD_HOME}/buildscripts/InitialiseCaching.sh
. ${BUILD_HOME}/buildscripts/InitialiseDatabase.sh
. ${BUILD_HOME}/buildscripts/InitialiseBuildParams.sh
. ${BUILD_HOME}/buildscripts/InitialiseDatastore.sh
. ${BUILD_HOME}/buildscripts/InitialiseBuildChoice.sh
/bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/* 2>/dev/null

#Get the ip address of our build machine
BUILD_CLIENT_IP="`/usr/bin/wget http://ipinfo.io/ip -qO -`"

/bin/mkdir -p ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/${BUILD_CLIENT_IP}

. ${BUILD_HOME}/providerscripts/server/ObtainSubnetID.sh
. ${BUILD_HOME}/providerscripts/server/ProvisionElasticFS.sh


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

#Set a username and password which we can set on all our servers. Once the machines are built, password authentication is
#switched off and you can find some ssh key based helper scripts here that will enable you to authenticate to your machines.
SERVER_USER="X`/bin/cat /dev/urandom | /usr/bin/tr -dc 'a-zA-Z' | /usr/bin/fold -w 18 | /usr/bin/head -n 1`X"
SERVER_USER_PASSWORD="`/bin/cat /dev/urandom | /usr/bin/tr -dc 'a-zA-Z' | /usr/bin/fold -w 18 | /usr/bin/head -n 1`"

/bin/echo "${SERVER_USER}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSER
/bin/echo "${SERVER_USER_PASSWORD}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSERPASSWORD

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

    if ( [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS-secured" ] || [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
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
        if ( [ "${DEFAULT_DBaaS_OS_USER}" != "" ] && [ "${DBaaS_REMOTE_SSH_PROXY_IP}" != "" ] )
        then
            status "A default remote proxy os user set to: ${DEFAULT_DBaaS_OS_USER}"
            status "Remote ssh proxy ip(s) of: ${DBaaS_REMOTE_SSH_PROXY_IP}"
        fi
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

    status ""
    status "##########################################################################################################"
    status "Build from snapshots completed"
    status "It will take a few minutes before your site comes online. Anything more than 10 minutes before it is online"
    status "Means that there is something wrong and you should start to investigate"
    status "##########################################################################################################"
else
    status "###############################################################################################################################################"
    status "Performing a regular style build (no snapshots used). If this is what you want, press <enter> if not <ctrl-c> to reconfigure"
    status "###############################################################################################################################################"
    read carryon
    #Call the build scripts. These actually build and deploy the machines. Until this point, there was nothing new running on
    #our cloudhosts machines.
    if ( [ "${PRODUCTION}" != "0" ] && [ "${DEVELOPMENT}" != "1" ] )
    then
        status "How many autoscalers do you want to deploy?"
        read NO_AUTOSCALERS
        while ! ( [ "${NO_AUTOSCALERS}" -eq "${NO_AUTOSCALERS}" ] )
        do
            status "Sorry, invalid input, try again"
            read NO_AUTOSCALERS
        done
        . ${BUILD_HOME}/buildscripts/BuildAutoscaler.sh
    fi

    . ${BUILD_HOME}/buildscripts/BuildWebserver.sh
    . ${BUILD_HOME}/buildscripts/BuildDatabase.sh
    ##Do the build finalisation procedures
    . ${BUILD_HOME}/buildscripts/FinaliseBuildProcessing.sh

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
fi

#Output how long the build took
end=`/bin/date +%s`
runtime="`/usr/bin/expr ${end} - ${start}`"
status "This script took `/bin/date -u -d @${runtime} +\"%T\"` to complete"

