#!/bin/sh
################################################################################################################################################
# Description: Not all applications play the same, so if you have some particular post processing messages and so on that you need to display
# then you can add them here and they will be displayed to the user at the end of the build process
# Author: Peter Winter
# Date: 17/01/2017
################################################################################################################################################
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

#On an application by application basis, output post processing messages. Notice the ssh command on some of these to go off
#to the servers to get the credentials for the database and so on. The appilcations sometimes need the credentials before
#the install will complete. Usually, you give them by using the applications gui.

OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

if ( [ "${APPLICATION}" = "joomla" ] && [ "${BASELINE_DB_REPOSITORY}" = "VIRGIN" ] )
then
    username="${BUILD_IDENTIFIER}-webmaster"
    password="${SERVER_USER}"
    
    status ""
    status "################################################################"
    status "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    status "YOUR DEFAULT JOOMLA ADMINISTRATOR USERNAME AND PASSWORD ARE SET TO:"
    status "USERNAME: ${username}"
    status "PASSWORD: ${password}"
    status "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    status "################################################################"
    status ""
fi

if ( [ "${APPLICATION}" = "drupal" ] && [ "${BASELINE_DB_REPOSITORY}" = "VIRGIN" ] )
then
    status
    status "########################################################################################################################################"
    status "You are installing a virgin copy of drupal. ****ESSENTIAL ACTION**** >> Please navigate to https://${WEBSITE_URL}/core/install.php"
    status "########################################################################################################################################"
    
    
    while ( [ "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${WSIP} "${SUDO} /home/${SERVER_USER}/providerscripts/application/processing/drupal/CheckInstalled.sh"`" != "INSTALLED" ] )
    do
        status "######################################################################################"
        status "Waiting for you to install drupal by going to: https://${WEBSITE_URL}/core/install.php"
        status "######################################################################################"
        /bin/sleep 10
    done
    
    status ""
    status "########################################################################################################################################"
    status "It is expected that you will see an error message at the end of the drupal install procedure, this is because of a cache pollution issue"
    status "that happens (at least in my case) during a DRUPAL installation"
    status "The error you might see is: The website encountered an unexpected error. Please try again later."
    status "And it is described here: https://www.drupal.org/project/drupal/issues/3103529"
    status "If you complete the install up until you see the error message, wait 15 second (at least) and try again, you should have access to your new drupal site"
    status "I will try and clear the cache every 15 seconds"
    status "#########################################################################################################################################"

    while ( [ "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${WSIP} "${SUDO} /home/${SERVER_USER}/providerscripts/application/processing/drupal/CheckUser.sh"`" != "USER ADDED" ] )
    do
        status ""
        status "####################################################################"
        status "Checking for the application install having been completed at: https://${WEBSITE_URL}/core/install.php"
        status "Before attempting cache purge in the database cache to resolve cache pollution problem"
        status ""
        /bin/sleep 15
    done
    
    while ( [ "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${WSIP} "${SUDO} /home/${SERVER_USER}/providerscripts/application/processing/drupal/TruncateCache.sh"`" != "TRUNCATED" ] )
    do
        status ""
        status "####################################################################"
        status "Have not been able to truncate cache, trying again...."
        status "####################################################################"
        /bin/sleep 15
    done

    status ""
    status "#############################################################################################################"
    status "Successfully truncated the drupal cache. If drupal was showing an error message, it should now be resolved..."
    status "If an error message is still showing, try waiting a couple of minutes and see if it resolves"
    status "##############################################################################################################"
    status ""
    
    status "###############################################################################################################################"
    status "OK, I'll be kind and show you one time your drupal database credentials."
    status "Please make a note of them but remember to keep them safe and secret"
    status "============================"
    status "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${DBIP} "${SUDO} /bin/cat /home/${SERVER_USER}/config/credentials/shit"`"
    status "============================"
    
    /bin/sleep 10
    
    /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${WSIP} "/home/${SERVER_USER}/providerscripts/application/processing/PerformPostProcessingByApplication.sh ${SERVER_USER}" >&3
fi

if ( [ "${APPLICATION}" = "wordpress" ] && [ "${BASELINE_DB_REPOSITORY}" = "VIRGIN" ] )
then
    status
    status "###########################################################################################################################################"
    status "You are installing a virgin copy of wordpress."
    status "This will install the database for you and you will then have access to your wordpress CMS instance"
    status "OK, I'll be kind and show you one time your wordpress credentials. You will need it during the installation process for wordpress"
    status "Please make a note of them but remember to keep them safe and secret"
    status "============="
    status "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${DBIP} "${SUDO} /bin/cat /home/${SERVER_USER}/config/credentials/shit"`"
    status "============="
    status "Please press the <enter> key to acknowledge this message and that you have made a note of the credentials and the build will be complete."
    status "###########################################################################################################################################"
    read answer
fi

if ( [ "${APPLICATION}" = "moodle" ] && [ "${BASELINE_DB_REPOSITORY}" = "VIRGIN" ] )
then
    status
    status "###########################################################################################################################################"
    status "You are installing a virgin copy of moodle."
    status "This will install the database for you and you will then have access to your moodle CMS instance"
    status "OK, I'll be kind and show you one time your moodle application credentials. You will need it during the installation process for moodle"
    status "Please make a note of them but remember to keep them safe and secret"
    status "============="
    status "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${DBIP} "${SUDO} /bin/cat /home/${SERVER_USER}/config/credentials/shit"`"
    status "============="
    
    username="${BUILD_IDENTIFIER}-webmaster"
    password="${SERVER_USER}"
    
    status ""
    status "################################################################"
    status "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    status "YOUR DEFAULT ADMINISTRATOR MOODLE USERNAME AND PASSWORD ARE SET TO:"
    status "USERNAME: ${username}"
    status "PASSWORD: ${password}"
    status "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    status "################################################################"
    status ""
    status "Please press the <enter> key to acknowledge this message and that you have made a note of the credentials and the build will be complete."
    status "###########################################################################################################################################"
    read answer
fi
