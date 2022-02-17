#!/bin/sh
######################################################################################################################
# Description: This is the script which asks which of the supported cloud host providers the user wishes to deploy to.
# Author: Peter Winter
# Date: 17/01/2017
######################################################################################################################
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
######################################################################################################
#set -x

#Give the user the choice of which of the supported cloudhosts they want to build to - could be as many as you like, it's
#just a matter of adding support

status ""
status ""
status "##################################################################################################"
status "#####Please select your cloudhosting provider                                                #####"
status "#####currently we support: 1) DIGITAL OCEAN www.digitalocean.com                             #####"
status "#####                      2) EXOSCALE      www.exoscale.ch                                  #####"
status "#####                      3) LINODE        www.linode.com                                   #####"
status "#####                      4) VULTR         www.vultr.com                                    #####"
status "#####                      5) AWS           aws.amazon.com                                   #####"
status "##################################################################################################"
status "Enter 1: for Digital Ocean 2: For Exoscale 3: for Linode 4: for Vultr 5: for AWS"
read choice

while ( [ "${choice}" = "" ] || [ "`/bin/echo "1 2 3 4 5" | /bin/grep ${choice}`" = "" ] )
do
    status "Invalid choice, please try again..."
    read choice
done

if ( [ "${choice}" = "1" ] )
then
    CLOUDHOST="digitalocean"
    MACHINE_TYPE="DROPLET"
    ALGORITHM="ecdsa"

    if ( [ ! -d ${BUILD_HOME}/runtimedata/digitalocean ] )
    then
        /bin/mkdir -p ${BUILD_HOME}/runtimedata/digitalocean
    fi
    ${BUILD_HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
    ${BUILD_HOME}/providerscripts/cloudhost/GetProviderAuthorisation.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION} ${SSH_PORT}
    . ${BUILD_HOME}/providerscripts/cloudhost/SetupAdditionalCloudhostTools.sh


    #Digital ocean supports snapshots, so we offer that as a choice. With autoscaling using snapshots, new webservers
    #will be built using a snapshot rather than a fresh build using repositories and so on. It's probably faster like
    #that which means we can scale up quickly, but we have to make sure that the snapshot is fresh.

    status ""
    status ""
    status "##################################################################################################"
    status "#####This cloudhost provider supports the use of snapshots                                   #####"
    status "#####would you like to use snapshots?                                                        #####"
    status "##################################################################################################"
    status "Please enter, (Y/N)"
    read response

    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        status ""
        status ""
        status "##############################################################################################"
        status "OK, you have selected to make use of snapshots. This means there you have to select one of two"
        status "Different scenarios depending on where you are in your workflow"
        status ""
        status "1) Perform full build and take snapshots of all servers for use in 2) - autoscaling events are"
        status "still full builds of webservers"
        status ""
        status "2) Build from snapshots generated in 1) - autoscaling events use snapshot images to build from"
        status ""
        status "##############################################################################################"
        status "So, please choose by entering a number, scenario 1, scenario 2"
        status "##############################################################################################"
        status "Enter 1,2"

        read response

        while (  [ "${response}" = "" ] || [ "`/bin/echo "1 2" | /bin/grep ${response}`" = "" ] )
        do
            status "That is illegal, please try again"
            read response
        done
    fi

    AUTOSCALE_FROM_SNAPSHOTS="0"
    GENERATE_SNAPSHOTS="0"

    if ( [ "${response}" = "1" ] )
    then
        AUTOSCALE_FROM_SNAPSHOTS="0"
        GENERATE_SNAPSHOTS="1"
    fi

    if ( [ "${response}" = "2" ] )
    then
        AUTOSCALE_FROM_SNAPSHOTS="1"
        GENERATE_SNAPSHOTS="0"

        if ( [ -d ${BUILD_HOME}/snapshots ] && [ "`/bin/ls ${BUILD_HOME}/snapshots/ | /usr/bin/wc -l`" != "0" ] )
        then
            status ""
            status ""
            status "########################################################################################################"
            status "Here are the identifiers for your pre existing snapshots"
            status "Note, the snapshots must still exist with your cloudhost if you have deleted the snapshots then, obviously"
            status "the build will fail..."
            status "########################################################################################################"
            status "SNAPSHOT IDENTIFIERS"
            status ""
            /bin/ls -tr ${BUILD_HOME}/snapshots >&3
            status ""
            status "##########################################################################################################"
            status "Please enter the ***first four characters*** from the snapshot id from this list that you want to build from"
            status "You can review (and check that corresponding snapshots exist) with your cloudhost provider"
            status "##########################################################################################################"
            status "Enter your 4 shapshot id characters please:"
            read SNAPSHOT_ID
            status "#############################################################################################################"
            status "INFORMATION:"
            status "Even though we are building from a snapshot, if there is no acceptable configuration file with pre existing settings"
            status "We will have to run through setting up the configuration even though we only need bits and pieces of it, like"
            status "What machines sizes you are deploying to this time around and so on"
            status "You should make sure that settings such as which repository to use are the same as they were when the snapshots"
            status "were generated...."
            status "#############################################################################################################"
            status "Press <enter>, to display image identifiers, there will then be a brief pause"
            read x
        else
            status "There are no pre-existing snapshots, will have to exit"
            exit
        fi
        
        . ${HOME}/providerscripts/cloudhost/GetSnaspshotIDs.sh

        status ""
        status ""
        status "###########################################################"
        status "The image id's that we will be using to build from are:"
        status "If any of these do not show an identifier your build will"
        status "will fail and you will need to investigate why"
        status "Webserver: ${WEBSERVER_IMAGE_ID}"
        status "Autoscaler: ${AUTOSCALER_IMAGE_ID}"
        status "Database: ${DATABASE_IMAGE_ID}"
        status "###########################################################"
    else
        SNAPSHOT_ID=""
    fi
elif ( [ "${choice}" = "2" ] )
then
    CLOUDHOST="exoscale"
    MACHINE_TYPE="EXOSCALE"
    ALGORITHM="rsa"

    if ( [ ! -d ${BUILD_HOME}/runtimedata/exoscale ] )
    then
        /bin/mkdir -p ${BUILD_HOME}/runtimedata/exoscale
    fi

    ${BUILD_HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
    ${BUILD_HOME}/providerscripts/cloudhost/GetProviderAuthorisation.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION} ${SSH_PORT}
    
    if ( [ "${CLOUDHOST_EMAIL_ADDRESS}" = "" ] )
    then
        status "#####################################################################################################"
        status "##### This provider needs your account email address to be supplied. You can find it from your  #####"
        status "##### console, it is the email address that you use to log in to your account.                  #####"
        status "#####################################################################################################"
        status "Exoscale account email address:"
        read CLOUDHOST_EMAIL_ADDRESS
    fi
    
    . ${BUILD_HOME}/providerscripts/cloudhost/SetupAdditionalCloudhostTools.sh
    

    if ( [ "${BUILDOS}" = "ubuntu" ] )
    then
        DEFAULT_USER="ubuntu"
    elif ( [ "${BUILDOS}" = "debian" ] )
    then
        DEFAULT_USER="debian"
    fi

    #Ask the user if they want to build from snapshots

    status ""
    status "##################################################################################################"
    status "#####This cloudhost provider supports the use of snapshots                                   #####"
    status "#####would you like to use snapshots?                                                        #####"
    status "##################################################################################################"
    status "Please enter, (Y/N)"
    read response

    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        status ""
        status ""
        status "##############################################################################################"
        status "OK, you have selected to make use of snapshots. This means there you have to select one of two"
        status "Different scenarios depending on where you are in your workflow"
        status ""
        status "1) Perform full build and take snapshots of all servers for use in 2) - autoscaling events are"
        status "still full builds of webservers"
        status ""
        status "2) Build from snapshots generated in 1) - autoscaling events use snapshot images to build from"
        status ""
        status "##############################################################################################"
        status "So, please choose by entering a number, scenario 1, scenario 2"
        status "##############################################################################################"
        status "Enter 1,2"

        read response

        while (  [ "${response}" = "" ] || [ "`/bin/echo "1 2" | /bin/grep ${response}`" = "" ] )
        do
            status "That is illegal, please try again"
            read response
        done
    fi

    AUTOSCALE_FROM_SNAPSHOTS="0"
    GENERATE_SNAPSHOTS="0"

    if ( [ "${response}" = "1" ] )
    then
        AUTOSCALE_FROM_SNAPSHOTS="0"
        GENERATE_SNAPSHOTS="1"
    fi

    if ( [ "${response}" = "2" ] )
    then
        AUTOSCALE_FROM_SNAPSHOTS="1"
        GENERATE_SNAPSHOTS="0"

        if ( [ -d ${BUILD_HOME}/snapshots ] && [ "`/bin/ls ${BUILD_HOME}/snapshots/ | /usr/bin/wc -l`" != "0" ] )
        then
            status ""
            status ""
            status "########################################################################################################"
            status "Here are the identifiers for your pre existing snapshots"
            status "Note, the snapshots must still exist with your cloudhost if you have deleted the snapshots then, obviously"
            status "the build will fail..."
            status "########################################################################################################"
            status "SNAPSHOT IDENTIFIERS"
            status ""
            /bin/ls -tr ${BUILD_HOME}/snapshots >&3
            status ""
            status "##########################################################################################################"
            status "Please enter the ***first four characters*** from the snapshot id from this list that you want to build from"
            status "You can review (and check that corresponding snapshots exist) with your cloudhost provider"
            status "##########################################################################################################"
            status "Enter your 4 shapshot id characters please:"
            read SNAPSHOT_ID
            status "#############################################################################################################"
            status "INFORMATION:"
            status "Even though we are building from a snapshot, if there is no acceptable configuration file with pre existing settings"
            status "We will have to run through setting up the configuration even though we only need bits and pieces of it, like"
            status "What machines sizes you are deploying to this time around and so on"
            status "You should make sure that settings such as which repository to use are the same as they were when the snapshots"
            status "were generated...."
            status "#############################################################################################################"
            status "Press <enter>, to display image identifiers, there will then be a brief pause"
            read x
        else
            status "There are no pre-existing snapshots, will have to exit"
            exit
        fi

       zones="`/usr/bin/exo -O json zone list | /usr/bin/jq '(.[]) | .name' | /bin/sed 's/\"//g'`"
       status "Please select which zone your snapshot template is in"
       status "Please enter one of: ${zones}"
       read zone
       while ( [ "`/bin/echo ${zones} | /bin/grep ${zone}`" = "" ] )
       do
           status "That doesn't look like a valid zone, please try again...."
           read zone
       done

        . ${HOME}/providerscripts/cloudhost/GetSnaspshotIDs.sh

        status ""
        status ""
        status "###########################################################"
        status "The image id's that we will be using to build from are:"
        status "If any of these do not show an identifier your build will"
        status "will fail and you will need to investigate why"
        status "Webserver: ${WEBSERVER_IMAGE_ID}"
        status "Autoscaler: ${AUTOSCALER_IMAGE_ID}"
        status "Database: ${DATABASE_IMAGE_ID}"
        status "###########################################################"
        status "Press <enter> to accept ctrl-c to exit"
        read x
    else
        SNAPSHOT_ID=""
    fi

elif ( [ "${choice}" = "3" ] )
then
    CLOUDHOST="linode"
    MACHINE_TYPE="LINODE"
    ALGORITHM="rsa"

    if ( [ ! -d ${BUILD_HOME}/runtimedata/linode ] )
    then
        /bin/mkdir -p ${BUILD_HOME}/runtimedata/linode
    fi

    ${BUILD_HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
    ${BUILD_HOME}/providerscripts/cloudhost/GetProviderAuthorisation.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION} ${SSH_PORT}
    . ${BUILD_HOME}/providerscripts/cloudhost/SetupAdditionalCloudhostTools.sh

    status "#####################################################################################################"
    status "##### This provider requires a root password to your account to be able to proceed. This will   #####"
    status "##### only be used during the build process and then set inactive. SSH keys will then be used   #####"
    status "##### Password must be between 6 and 128 characters                                             #####"                                                                           
    status "##### Password must contain at least 2 of these 4 character classes:                            #####"
    status "#####                          lowercase letters, uppercase letters, numbers                    #####"
    status "##### NOTE : PLEASE AVOID USING PUNCTUATION IN YOUR PASSWORD AS IT MIGHT CAUSE US TO HAVE ISSUES#####"
    status "#####################################################################################################"
    CLOUDHOST_USERNAME="root"
    status "Linode root Password (at least 8 characters):"
    read CLOUDHOST_PASSWORD

    if ( [ ! -d ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials ] )
    then
        /bin/mkdir -p ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials
    fi

    status ""
    status ""
    status "##################################################################################################"
    status "#####This cloudhost supports snapshots.                                                      #####"
    status "#####Would you like to make use of snapshots?                                                #####"
    status "##################################################################################################"
    status "Please enter, (Y/N)"
    read response

    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        status ""
        status ""
        status "##############################################################################################"
        status "OK, you have selected to make use of snapshots. This means there you have to select one of two"
        status "Different scenarios depending on where you are in your workflow"
        status ""
        status "1) Perform full build and take snapshots of all servers for use in 2) - autoscaling events are"
        status "still full builds of webservers"
        status ""
        status "2) Build from snapshots generated in 1) - autoscaling events use snapshot images to build from"
        status ""
        status "##############################################################################################"
        status "So, please choose by entering a number, scenario 1, scenario 2"
        status "##############################################################################################"
        status "Enter 1 or 2"
        read response

        while (  [ "${response}" = "" ] || [ "`/bin/echo "1 2" | /bin/grep ${response}`" = "" ] )
        do
            status "That is illegal, please try again"
            read response
        done
    fi

    if ( [ "${response}" = "1" ] )
    then
        AUTOSCALE_FROM_SNAPSHOTS="0"
        GENERATE_SNAPSHOTS="1"
    fi

    if ( [ "${response}" = "2" ] )
    then
        AUTOSCALE_FROM_SNAPSHOTS="1"
        GENERATE_SNAPSHOTS="0"

        if ( [ -d ${BUILD_HOME}/snapshots ] && [ "`/bin/ls ${BUILD_HOME}/snapshots/ | /usr/bin/wc -l`" != "0" ] )
        then
            status ""
            status "########################################################################################################"
            status "Here are the identifiers for your pre existing snapshots"
            status "Note, the snapshots must still exist with your cloudhost if you have deleted the snapshots then, obviously"
            status "the build will fail..."
            status "########################################################################################################"
            status "SNAPSHOT IDENTIFIERS"
            status ""
            /bin/ls -tr ${BUILD_HOME}/snapshots >&3
            status ""
            status "##########################################################################################################"
            status "Please enter the ***first four characters*** from the snapshot id from this list that you want to build from"
            status "You can review (and check that corresponding snapshots exist) with your cloudhost provider"
            status "##########################################################################################################"
            status "Enter your 4 shapshot id characters please:"
            read SNAPSHOT_ID
            status "#############################################################################################################"
            status "INFORMATION:"
            status "*** Make sure your snapshots are stored in the same region as you are deploying your servers to...***"
            status "Even though we are building from a snapshot, if there is no acceptable configuration file with pre existing settings"
            status "We will have to run through setting up the configuration even though we only need bits and pieces of it, like"
            status "What machines sizes you are deploying to this time around and so on"
            status "You should make sure that settings such as which repository to use are the same as they were when the snapshots"
            status "were generated...."
            status "#############################################################################################################"
            status "Press <enter>, to display image identifiers, there will then be a brief pause"
            read x
        else
            /bin/echo "There are no pre-existing snapshots, will have to exit"
            exit
        fi
        
        . ${HOME}/providerscripts/cloudhost/GetSnaspshotIDs.sh

        status ""
        status ""
        status "###########################################################"
        status "The image id's that we will be using to build from are:"
        status "If any of these do not show an identifier your build will"
        status "will fail and you will need to investigate why"
        status "Webserver: ${WEBSERVER_IMAGE_ID}"
        status "Autoscaler: ${AUTOSCALER_IMAGE_ID}"
        status "Database: ${DATABASE_IMAGE_ID}"
        status "###########################################################"
    else
        SNAPSHOT_ID=""
    fi

    /bin/echo "${CLOUDHOST_USERNAME}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/CLOUDHOSTUSERNAME
    /bin/echo "${CLOUDHOST_PASSWORD}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/CLOUDHOSTPASSWORD
elif ( [ "${choice}" = "4" ] )
then
    CLOUDHOST="vultr"
    MACHINE_TYPE="VULTR"
    ALGORITHM="rsa"

    if ( [ ! -d ${BUILD_HOME}/runtimedata/vultr ] )
    then
        /bin/mkdir -p ${BUILD_HOME}/runtimedata/vultr
    fi

    ${BUILD_HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
    ${BUILD_HOME}/providerscripts/cloudhost/GetProviderAuthorisation.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION} ${SSH_PORT}
    . ${BUILD_HOME}/providerscripts/cloudhost/SetupAdditionalCloudhostTools.sh

    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN`"


    #Vultr supports snapshots, so we offer that as a choice. With autoscaling using snapshots, new webservers
    #will be built using a snapshot rather than a fresh build using repositories and so on. It's probably faster like
    #that which means we can scale up quickly, but we have to make sure that the snapshot is fresh.

    status ""
    status ""
    status "##################################################################################################"
    status "#####This cloudhost supports snapshots.                                                      #####"
    status "#####Would you like to make use of snapshots?                                                #####"
    status "##################################################################################################"
    status "Please enter, (Y/N)"
    read response

    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        status ""
        status ""
        status "##############################################################################################"
        status "OK, you have selected to make use of snapshots. This means there you have to select one of two"
        status "Different scenarios depending on where you are in your workflow"
        status ""
        status "1) Perform full build and take snapshots of all servers for use in 2) - autoscaling events are"
        status "still full builds of webservers"
        status ""
        status "2) Build from snapshots generated in 1) - autoscaling events use snapshot images to build from"
        status ""
        status "##############################################################################################"
        status "So, please choose by entering a number, scenario 1, scenario 2"
        status "##############################################################################################"
        status "Enter 1 or 2"
        read response

        while (  [ "${response}" = "" ] || [ "`/bin/echo "1 2" | /bin/grep ${response}`" = "" ] )
        do
            status "That is illegal, please try again"
            read response
        done
    fi

    if ( [ "${response}" = "1" ] )
    then
        AUTOSCALE_FROM_SNAPSHOTS="0"
        GENERATE_SNAPSHOTS="1"
    fi

    if ( [ "${response}" = "2" ] )
    then
        AUTOSCALE_FROM_SNAPSHOTS="1"
        GENERATE_SNAPSHOTS="0"

        if ( [ -d ${BUILD_HOME}/snapshots ] && [ "`/bin/ls ${BUILD_HOME}/snapshots/ | /usr/bin/wc -l`" != "0" ] )
        then
            status ""
            status "########################################################################################################"
            status "Here are the identifiers for your pre existing snapshots"
            status "Note, the snapshots must still exist with your cloudhost if you have deleted the snapshots then, obviously"
            status "the build will fail..."
            status "########################################################################################################"
            status "SNAPSHOT IDENTIFIERS"
            status ""
            /bin/ls -tr ${BUILD_HOME}/snapshots >&3
            status ""
            status "##########################################################################################################"
            status "Please enter the ***first four characters*** from the snapshot id from this list that you want to build from"
            status "You can review (and check that corresponding snapshots exist) with your cloudhost provider"
            status "##########################################################################################################"
            status "Enter your 4 shapshot id characters please:"
            read SNAPSHOT_ID
            status "#############################################################################################################"
            status "INFORMATION:"
            status "*** Make sure your snapshots are stored in the same region as you are deploying your servers to...***"
            status "Even though we are building from a snapshot, if there is no acceptable configuration file with pre existing settings"
            status "We will have to run through setting up the configuration even though we only need bits and pieces of it, like"
            status "What machines sizes you are deploying to this time around and so on"
            status "You should make sure that settings such as which repository to use are the same as they were when the snapshots"
            status "were generated...."
            status "#############################################################################################################"
            status "Press <enter>, to display image identifiers, there will then be a brief pause"
            read x
        else
            /bin/echo "There are no pre-existing snapshots, will have to exit"
            exit
        fi

        . ${HOME}/providerscripts/cloudhost/GetSnaspshotIDs.sh

        status ""
        status ""
        status "###########################################################"
        status "The image id's that we will be using to build from are:"
        status "If any of these do not show an identifier your build will"
        status "will fail and you will need to investigate why"
        status "Webserver: ${WEBSERVER_IMAGE_ID}"
        status "Autoscaler: ${AUTOSCALER_IMAGE_ID}"
        status "Database: ${DATABASE_IMAGE_ID}"
        status "###########################################################"
    else
        SNAPSHOT_ID=""
    fi
elif ( [ "${choice}" = "5" ] )
then
    CLOUDHOST="aws"
    MACHINE_TYPE="AWS"
    ALGORITHM="rsa"

    if ( [ ! -d ${BUILD_HOME}/runtimedata/aws ] )
    then
        /bin/mkdir -p ${BUILD_HOME}/runtimedata/aws
    fi

    ${BUILD_HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
    ${BUILD_HOME}/providerscripts/cloudhost/GetProviderAuthorisation.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION} ${SSH_PORT}
    . ${BUILD_HOME}/providerscripts/cloudhost/SetupAdditionalCloudhostTools.sh

    export AWS_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN`"
    status "#########################################################################################################################"
    status "OK, your cloudhost is set to aws"
    status "Make sure the account you are using has a security policy which allows full access to EC2, S3 and EFS services"
    status "#########################################################################################################################"
    status "Press enter when ready"
    read response
    if ( [ "${BUILDOS}" = "ubuntu" ] )
    then
        DEFAULT_USER="ubuntu"
elif ( [ "${BUILDOS}" = "debian" ] )
    then
        DEFAULT_USER="admin"
    fi

    #AWS supports snapshots, so we offer that as a choice. With autoscaling using snapshots, new webservers
    #will be built using a snapshot rather than a fresh build using repositories and so on. It's probably faster like
    #that which means we can scale up quickly, but we have to make sure that the snapshot is fresh.

    status ""
    status ""
    status "##################################################################################################"
    status "#####This cloudhost supports snapshots.                                                      #####"
    status "#####Would you like to make use of snapshots?                                                #####"
    status "##################################################################################################"
    status "Please enter, (Y/N)"
    read response

    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        status ""
        status ""
        status "##############################################################################################"
        status "OK, you have selected to make use of snapshots. This means there you have to select one of two"
        status "Different scenarios depending on where you are in your workflow"
        status ""
        status "1) Perform full build and take snapshots of all servers for use in 2) - autoscaling events are"
        status "still full builds of webservers"
        status ""
        status "2) Build from snapshots generated in 1) - autoscaling events use snapshot images to build from"
        status ""
        status "##############################################################################################"
        status "So, please choose by entering a number, scenario 1, scenario 2"
        status "##############################################################################################"
        status "Enter 1 or 2"
        read response

        while (  [ "${response}" = "" ] || [ "`/bin/echo "1 2" | /bin/grep ${response}`" = "" ] )
        do
            status "That is illegal, please try again"
            read response
        done
    fi

    if ( [ "${response}" = "1" ] )
    then
        AUTOSCALE_FROM_SNAPSHOTS="0"
        GENERATE_SNAPSHOTS="1"
    fi

    if ( [ "${response}" = "2" ] )
    then
        AUTOSCALE_FROM_SNAPSHOTS="1"
        GENERATE_SNAPSHOTS="0"

        if ( [ -d ${BUILD_HOME}/snapshots ] && [ "`/bin/ls ${BUILD_HOME}/snapshots/ | /usr/bin/wc -l`" != "0" ] )
        then
            status ""
            status "########################################################################################################"
            status "Here are the identifiers for your pre existing snapshots"
            status "Note, the snapshots must still exist with your cloudhost if you have deleted the snapshots then, obviously"
            status "the build will fail..."
            status "########################################################################################################"
            status "SNAPSHOT IDENTIFIERS"
            status ""
            /bin/ls -tr ${BUILD_HOME}/snapshots >&3
            status ""
            status "##########################################################################################################"
            status "Please enter the ***first four characters*** from the snapshot id from this list that you want to build from"
            status "You can review (and check that corresponding snapshots exist) with your cloudhost provider"
            status "##########################################################################################################"
            status "Enter your 4 shapshot id characters please:"
            read SNAPSHOT_ID
            status "#############################################################################################################"
            status "INFORMATION:"
            status "*** Make sure your snapshots are stored in the same region as you are deploying your servers to...***"
            status "Even though we are building from a snapshot, if there is no acceptable configuration file with pre existing settings"
            status "We will have to run through setting up the configuration even though we only need bits and pieces of it, like"
            status "What machines sizes you are deploying to this time around and so on"
            status "You should make sure that settings such as which repository to use are the same as they were when the snapshots"
            status "were generated...."
            status "#############################################################################################################"
            status "Press <enter>, to display image identifiers, there will then be a brief pause"
            read x
        else
            /bin/echo "There are no pre-existing snapshots, will have to exit"
            exit
        fi
        
        . ${HOME}/providerscripts/cloudhost/GetSnaspshotIDs.sh
   
        status ""
        status ""
        status "###########################################################"
        status "The image id's that we will be using to build from are:"
        status "If any of these do not show an identifier your build will"
        status "will fail and you will need to investigate why they don't display"
        status "Webserver: ${WEBSERVER_IMAGE_ID}"
        status "Autoscaler: ${AUTOSCALER_IMAGE_ID}"
        status "Database: ${DATABASE_IMAGE_ID}"
        status "###########################################################"
    else
        SNAPSHOT_ID=""
    fi
else
    status "Invalid choice, please try again..."
fi
