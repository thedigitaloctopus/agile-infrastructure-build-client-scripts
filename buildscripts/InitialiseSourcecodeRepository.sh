#!/bin/sh
#######################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script allows the user to decide which repository provider they wish
# to use. There's two basic repository sets. One is for the infrastructure files and the
# other is for the user's application files. PLEASE NOTE: If you are deploying
# your application to public repositories please make sure that there are no access keys
# embedded in your sourcecode or in your database dump. There are people who scan such
# repositories and access to your datastore, for example, may be compromised if
# you application uses a "secret" key which is present in your sourcecode or your data repository.
#######################################################################################
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

if ( [ "${PREVIOUS_BUILD_CONFIG}" = "0" ] )
then
    if ( [ -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/GITUSER ] )
    then
        status "##################################################################"
        status "Your Git username is set to `/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/GITUSER`"
        status "##################################################################"
        status "Do you want to keep this username value? (Y|y)"
        read response
        if ( [ "`/bin/echo y Y | /bin/grep ${response}`" != "" ] )
        then
            GIT_USER="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/GITUSER`"
        else
            status "Plese input the username that you use for your git application repository"
            read GIT_USER
            /bin/echo "${GIT_USER}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/GITUSER
        fi
    else
        status "Plese input the username that you use for your git application repository"
        read GIT_USER
        /bin/echo "${GIT_USER}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/GITUSER
    fi

    if ( [ -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/GITEMAIL ] )
    then
        status "##################################################################"
        status "Your Git email is set to `/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/GITEMAIL`"
        status "##################################################################"
        status "Do you want to keep this email value? (Y|y)"
        read response
        if ( [ "`/bin/echo y Y | /bin/grep ${response}`" != "" ] )
        then
            GIT_EMAIL_ADDRESS="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/GITEMAIL`"
        else
            status "Plese input the email that you use for your git application repository"
            read GIT_EMAIL_ADDRESS
            /bin/echo "${GIT_EMAIL_ADDRESS}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/GITEMAIL
        fi
    else
        status "Plese input the email that you use for your git application repository"
        read GIT_EMAIL_ADDRESS
        /bin/echo "${GIT_EMAIL_ADDRESS}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/GITEMAIL
    fi

    status ""
    status ""
    status "###############################################################################################################################"
    status "##### Your (or another person's application sourcecode needs to be kept in a repo where the repo name has the format:     #####"
    status "##### <UNIQUE_IDENTIFIER>-WEBROOT-SOURCECODE-BASELINE.                                                                    #####"
    status "##### We currently support 1)BITBUCKET 2)GITHUB 3)GITLAB                                                                  #####"
    status "###############################################################################################################################"
    status "Please select the repository provider where your application sourcecode resides (1|2|3)"
    read choice

    while ( [ "`/bin/echo "1 2 3" | /bin/grep ${choice}`" = "" ] )
    do
        status "Invalid choice, please try again..."
        read choice
    done

    if ( [ "`/bin/echo ${choice} | /bin/grep '1'`" != "" ] )
    then
        APPLICATION_REPOSITORY_PROVIDER="bitbucket"
    fi
    if ( [ "`/bin/echo ${choice} | /bin/grep '2'`" != "" ] )
    then
        APPLICATION_REPOSITORY_PROVIDER="github"
    fi
    if ( [ "`/bin/echo ${choice} | /bin/grep '3'`" != "" ] )
    then
        APPLICATION_REPOSITORY_PROVIDER="gitlab"
        status "For this repository provider, we need a 'private auithorisation token' to be generated"
        status "You can do this by logging into your account with them and clicking on Profile Settings -> Access Tokens and then generating one"
        status "If you make a note of the generated token and paste it below, that will be all we need"
        read APPLICATION_REPOSITORY_TOKEN
    fi
    status "##############################################################################################################"
    status "#### We now need to know who the owner of the application repo is. If the owner is not you, then the     #####"
    status "#### the owner of the application repo will have to grant your username read access rights to your repo  #####"
    status "##############################################################################################################"
    status "Plese enter the owner of you application stored with ${APPLICATION_REPOSITORY_PROVIDER} here:              "
    read APPLICATION_REPOSITORY_OWNER

    status ""
    status ""
    status "###############################################################################################################"
    status "##### Now enter **YOUR** personal credentials for ${APPLICATION_REPOSITORY_PROVIDER} here:                #####"
    status "###############################################################################################################"
    status "YOUR ${APPLICATION_REPOSITORY_PROVIDER} USERNAME: "
    read APPLICATION_REPOSITORY_USERNAME
    status "YOUR ${APPLICATION_REPOSITORY_PROVIDER} PASSWORD: "
    /bin/stty -echo >&3
    read APPLICATION_REPOSITORY_PASSWORD
    /bin/stty echo >&3

    status ""
    status "##############################################################################################################"
    status "##### Please choose the repo provier where the infrastructure system scripts are kept, currently github  #####"
    status "##### Agile Infrastructure Database Scripts                                                              #####"
    status "##### Agile Infrastructure Webserver Scripts                                                             #####"
    status "##### Agile Infrastructure Autoscaler Scripts                                                            #####"
    status "##############################################################################################################"
    status "PLEASE ENTER (y|Y) TO CONFIRM"
    read choice

    while ( [ "`/bin/echo "y Y" | /bin/grep ${choice}`" = "" ] )
    do
        status "Invalid choice, cannot run without access to these repositories..."
        status "Exiting......"
        exit
    done

    status ""
    status ""
    status "###############################################################################################################################"
    status "##### So, please enter the provider with which the agile deployment toolkit is currently kept                             #####"
    status "##### We currently support: 1)BITBUCKET 2)GITHUB 3)GITLAB                                                                 #####"
    status "###############################################################################################################################"
    status "Please select which repo provier your application sourcecode is with: (1|2|3)"
    read choice

    while ( [ "`/bin/echo "1 2" | /bin/grep ${choice}`" = "" ] )
    do
        status "Invalid choice, please try again..."
        read choice
    done

    if ( [ "`/bin/echo ${choice} | /bin/grep '1'`" != "" ] )
    then
        INFRASTRUCTURE_REPOSITORY_PROVIDER="bitbucket"
    fi

    if ( [ "`/bin/echo ${choice} | /bin/grep '2'`" != "" ] )
    then
        INFRASTRUCTURE_REPOSITORY_PROVIDER="github"
    fi

    status
    status
    status "##################################################################################################################"
    status "##### Please enter the username of the person who owns the Agile Infrastructure repos                        #####"
    status "##################################################################################################################"
    status "INFRASRUCTURE REPOSITORIES OWNER USERNAME:"
    read INFRASTRUCTURE_REPOSITORY_OWNER

    status ""
    status ""
    status "###############################################################################################################"
    status "##### Please enter **YOUR** credentials for the repo provider where the Agile Deployment Toolkit is stored#####"
    status "###############################################################################################################"
    status "YOUR ${INFRASTRUCTURE_REPOSITORY_PROVIDER} USERNAME:"
    read INFRASTRUCTURE_REPOSITORY_USERNAME
    status "YOUR ${INFRASTRUCTURE_REPOSITORY_PROVIDER} PASSWORD (leave blank for no password if the infrastructure repos are public):"
    /bin/stty -echo >&3
    read INFRASTRUCTURE_REPOSITORY_PASSWORD
    /bin/stty echo >&3
    if ( [ "${INFRASTRUCTURE_REPOSITORY_PASSWORD}" = "" ] )
    then
        INFRASTRUCTURE_REPOSITORY_PASSWORD="none"
    fi
    status "Checking and verifying access to the infrastructure repositories....."
fi

if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-autoscaler-scripts`" = "" ] )
then
    status "Cannot access repository: agile-infrastructure-autoscaler-scripts, please take action to rectify"
    exit
fi

if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-webserver-scripts`" = "" ] )
then
    status ""
    status "Cannot access repository: agile-infrastructure-webserver-scripts.git, please take action to rectify"
    exit
fi

if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} agile-infrastructure-database-scripts`" = "" ] )
then
    status ""
    status "Cannot access repository: agile-infrastructure-database-scripts.git, please take action to rectify"
    exit
fi


status "################################################################################################################"
status "####If you got to here, you have access to all the infrastructure repositories, congratulations           ######"
status "################################################################################################################"
