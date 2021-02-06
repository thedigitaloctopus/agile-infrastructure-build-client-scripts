#!/bin/sh
###############################################################################################
# Description: This is the the expedited version of the top level build script for the 
# Agile Deployment Toolkit.
# Author Peter Winter
# Date 22/9/2020
##############################################################################################
#This is the Expedited Agile Deployment toolkit with all the interaction stripped out.
#This is to be called from provider dependent init scripts such as Stack Scripts from linode.
#The init script can override all values set in a template based on what "UDF" values are 
#defined in the init script. In this way, you can create an init script which will then
#run when you spin up a VPS machine and allow the user defined values to override the settings
#that are defined in the template. 
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

export PUBLIC_KEY_NAME="AGILE_TOOLKIT_PUBLIC_KEY"

status () {
    /bin/echo "$1" | /usr/bin/tee /dev/fd/3
}

export BUILD_HOME="`/bin/pwd`"
export USER="`/usr/bin/whoami`"
/bin/chmod -R 700 ${BUILD_HOME}/.
#Get the ip address of our build machine
BUILD_CLIENT_IP="`/usr/bin/wget http://ipinfo.io/ip -qO -`"

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

if ( [ ! -f ./HardcoreAgileDeploymentToolkit.sh ] )
then
    status "#############################################################################################################"
    status "This script is expected to run from the same directory as the ExpeditedAgileDeploymentToolkit.sh script is in"
    status "#############################################################################################################"
    exit
fi

#If this is set, the user who ran it previously, then we know that this is not our first time running the script
if ( [ ! -f ${BUILD_HOME}/runtimedata/INSTALLUSER ] )
then
    /bin/mkdir -p ${BUILD_HOME}/runtimedata
    /bin/echo "${USER}" > ${BUILD_HOME}/runtimedata/INSTALLUSER
fi

if ( [ ! -f ${BUILD_HOME}/runtimedata/EXUPDATEDSOFTWARE ] )
then
    if ( "`/usr/bin/find "${BUILD_HOME}/runtimedata/EXUPDATEDSOFTWARE" -mtime +10 -print 2>/dev/null`" = "" ] )
    then
        /bin/rm ${BUILD_HOME}/runtimedata/EXUPDATEDSOFTWARE
    else
        if ( [ ! -f ${BUILD_HOME}/runtimedata/EXUPDATEDSOFTWARE ] )
        then
            UPGRADE_LOG="${BUILD_HOME}/logs/upgrade_out-`/bin/date | /bin/sed 's/ //g'`"
            
            if ( [ "`/usr/bin/awk -F= '/^NAME/{print $2}' /etc/os-release | /bin/grep "Ubuntu"`" != "" ] )
            then
                ${BUILD_HOME}/installscripts/Update.sh "ubuntu"  >>${UPGRADE_LOG} 2>&1
             #   status "Performing software upgrade....."
             #   ${BUILD_HOME}/installscripts/Upgrade.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                #Make Sure python PIP is at the latest version:
                status "Updating python"
                ${BUILD_HOME}/installscripts/PurgePython.sh "ubuntu" >>${UPGRADE_LOG} 2>&1 
                ${BUILD_HOME}/installscripts/InstallPythonPIP.sh "ubuntu" >>${UPGRADE_LOG} 2>&1 
                ${BUILD_HOME}/installscripts/InstallPythonDateUtil.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                status "Updating the CS tool"
                ${BUILD_HOME}/installscripts/InstallCS.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                status "Updating curl"
                ${BUILD_HOME}/installscripts/InstallCurl.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                status "Updating go"
                ${BUILD_HOME}/installscripts/InstallGo.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                status "Updating JQ"
                ${BUILD_HOME}/installscripts/InstallJQ.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                status "Updating Lego"
                ${BUILD_HOME}/installscripts/InstallLego.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                status "Updating Ruby"
                ${BUILD_HOME}/installscripts/InstallRuby.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                status "Updating SSHPass"
                ${BUILD_HOME}/installscripts/InstallSSHPass.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                status "Updating Sudo"
                ${BUILD_HOME}/installscripts/InstallSudo.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                status "Updating SysVBanner"
                ${BUILD_HOME}/installscripts/InstallSysVBanner.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                status "Updating UFW"
                ${BUILD_HOME}/installscripts/InstallUFW.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
                status "Updating Datastore tools"
                ${BUILD_HOME}/providerscripts/datastore/InstallDatastoreTools.sh 'S3CMD' "ubuntu"
                /bin/touch ${BUILD_HOME}/runtimedata/EXUPDATEDSOFTWARE
            elif ( [ "`/usr/bin/awk -F= '/^NAME/{print $2}' /etc/os-release | /bin/grep "Debian"`" != "" ] )
            then
                status "Performing software update....."
                ${BUILD_HOME}/installscripts/Update.sh "debian"  >>${UPGRADE_LOG} 2>&1
            #    status "Performing software upgrade....."
            #    ${BUILD_HOME}/installscripts/Upgrade.sh "debian" >>${UPGRADE_LOG} 2>&1
                #Make Sure python PIP is at the latest version:
                status "Updating python"
                ${BUILD_HOME}/installscripts/PurgePython.sh "debian" >>${UPGRADE_LOG} 2>&1 
                ${BUILD_HOME}/installscripts/InstallPythonPIP.sh "debian" >>${UPGRADE_LOG} 2>&1 
                ${BUILD_HOME}/installscripts/InstallPythonDateUtil.sh "debian" >>${UPGRADE_LOG} 2>&1
                status "Updating the CS tool"
                ${BUILD_HOME}/installscripts/InstallCS.sh "debian" >>${UPGRADE_LOG} 2>&1
                status "Updating curl"
                ${BUILD_HOME}/installscripts/InstallCurl.sh "debian" >>${UPGRADE_LOG} 2>&1
                status "Updating go"
                ${BUILD_HOME}/installscripts/InstallGo.sh "debian" >>${UPGRADE_LOG} 2>&1
                status "Updating JQ"
                ${BUILD_HOME}/installscripts/InstallJQ.sh "debian" >>${UPGRADE_LOG} 2>&1
                status "Updating Lego"
                ${BUILD_HOME}/installscripts/InstallLego.sh "debian" >>${UPGRADE_LOG} 2>&1
                status "Updating Ruby"
                ${BUILD_HOME}/installscripts/InstallRuby.sh "debian" >>${UPGRADE_LOG} 2>&1
                status "Updating SSHPass"
                ${BUILD_HOME}/installscripts/InstallSSHPass.sh "debian" >>${UPGRADE_LOG} 2>&1
                status "Updating Sudo"
                ${BUILD_HOME}/installscripts/InstallSudo.sh "debian" >>${UPGRADE_LOG} 2>&1
                status "Updating SysVBanner"
                ${BUILD_HOME}/installscripts/InstallSysVBanner.sh "debian" >>${UPGRADE_LOG} 2>&1
                status "Updating UFW"
                ${BUILD_HOME}/installscripts/InstallUFW.sh "debian" >>${UPGRADE_LOG} 2>&1 
                status "Updating Datastore tools"
                ${BUILD_HOME}/providerscripts/datastore/InstallDatastoreTools.sh 'S3CMD' "debian" >>${UPGRADE_LOG} 2>&1 
                /bin/touch ${BUILD_HOME}/runtimedata/EXUPDATEDSOFTWARE
            fi
       fi
    fi
fi

${BUILD_HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}

status "Your cloudhost is set to ${CLOUDHOST}"

#Check that we are 64 bit
if ( [ "`/usr/bin/dpkg --print-architecture`" = "i386" ] )
then
    status "############################################################################################################"
    status "Darn it. This script requires a 64 bit machine to run on. I have to exit. If you don't have a 64 bit machine"
    status "To build on of your own, you can spin one up in the cloud (ubuntu 20.04 and up) or (debian 10 and up ) and use that as your build machine to deploy from"
    status "############################################################################################################"
    exit
fi

#Check that you are root and if not make some recommendations
if ( [ "`/usr/bin/id -u`" != "0" ] )
then
    status ""
    status ""
    status "###################################################################################################################################"
    status "You need to run this script either directly as root or with the sudo command as it needs to make some installations to your machine"
    status "If this is a problem and you don't want stuff installed on your machine, I recommend that you spin up a dedicated build machine"
    status "in the cloud for dedicated use when building/deploying with this toolkit (ubuntu 20.04 or debian 10) are suitable build machines to use"
    status "###################################################################################################################################"
    exit
fi

/bin/echo "Most of the messages you will see here are soft errors. All errors are recorded though, should you need to review them" > ${BUILD_HOME}/logs/${ERR_FILE}


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

/usr/sbin/ufw default deny incoming
/usr/sbin/ufw default allow outgoing
/usr/sbin/ufw allow ssh
/usr/sbin/ufw enable

BUILD_IDENTIFIER="`/bin/echo ${BUILD_IDENTIFIER} | /usr/bin/tr '[:upper:]' '[:lower:]' | /bin/sed 's/-//g'`"

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

. ${BUILD_HOME}/templatedconfigurations/ConfigureTemplate.sh
. ${BUILD_HOME}/buildscripts/InitialiseSMTPMailServer.sh
. ${BUILD_HOME}/providerscripts/datastore/SetupConfiguration.sh
. ${BUILD_HOME}/providerscripts/cloudhost/ValidateProviderAuthorisation.sh

#Set a username and password which we can set on all our servers. Once the machines are built, password authentication is
#switched off and you can find some ssh key based helper scripts here that will enable you to authenticate to your machines.
SERVER_USER="X`/usr/bin/perl -le 'print map { (a..z,A..Z,0..9)[rand 62] } 1..18'`X"
SERVER_USER_PASSWORD="`/usr/bin/perl -le 'print map { (a..z,A..Z,0..9)[rand 62] } 1..18'`"

/bin/echo "${SERVER_USER}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSER
/bin/echo "${SERVER_USER_PASSWORD}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSERPASSWORD

. ${BUILD_HOME}/buildscripts/InitialiseSecurityKeys.sh

PUBLIC_KEY_ID="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/PUBLICKEYID`"
/bin/sed -i '/PUBLIC_KEY_ID=/d' ${templatefile}
/bin/echo "export PUBLIC_KEY_ID=\"${PUBLIC_KEY_ID}\"" >> ${templatefile}
#
#Get the ip address of our build machine
export BUILD_CLIENT_IP="`/usr/bin/wget http://ipinfo.io/ip -qO -`"

/bin/rm ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/*

/bin/rm ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/* 2>/dev/null

/bin/mkdir -p ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}
/bin/touch ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/${BUILD_CLIENT_IP}

#I ask for these here because it's easy to overlook them in a template and that's a potential waste of time

. ${BUILD_HOME}/providerscripts/server/ObtainSubnetID.sh
. ${BUILD_HOME}/providerscripts/server/ProvisionElasticFS.sh

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
    fi

    . ${BUILD_HOME}/buildscripts/BuildFromSnapshots.sh

    status ""
    status "##########################################################################################################"
    status "Build from snapshots completed"
    status "It will take a few minutes before your site comes online. Anything more than 10 minutes before it is online"
    status "Means that there is something wrong and you should start to investigate"
    status "##########################################################################################################"
else
    if ( [ "${PRODUCTION}" != "0" ] && [ "${DEVELOPMENT}" != "1" ] )
    then
        . ${BUILD_HOME}/buildscripts/BuildAutoscaler.sh
    fi
    . ${BUILD_HOME}/buildscripts/BuildWebserver.sh
    . ${BUILD_HOME}/buildscripts/BuildDatabase.sh
    ##Do the build finalisation procedures
    . ${BUILD_HOME}/buildscripts/FinaliseBuildProcessing.sh
    #If we have any messages to put out to the user post build, we add them to this script
    . ${BUILD_HOME}/PostProcessingMessages.sh
    
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
