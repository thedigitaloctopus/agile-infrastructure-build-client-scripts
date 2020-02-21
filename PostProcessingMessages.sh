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

if ( [ "${APPLICATION}" = "drupal" ] && [ "${BASELINE_DB_REPOSITORY}" = "VIRGIN" ] )
then
    status
    status "########################################################################################################################################"
    status "You are installing a virgin copy of drupal. ****ESSENTIAL ACTION**** >> Please navigate to https://${WEBSITE_URL}/core/install.php"
    status "########################################################################################################################################"
    status "OK, I'll be kind and show you one time your drupal application credentials."
    status "Please make a note of them but remember to keep them safe and secret"
    status "============="
    status "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${DBIP} "${SUDO} /bin/cat /home/${SERVER_USER}/config/credentials/shit"`"
    status "============="
    status "#########################################################################################################################################"
    status "ONCE YOU HAVE INSTALLED THE APPLICATION THROUGH YOUR WEB BROWSER"
    status "Please press the <enter> key here to acknowledge this message and that you have made a note of the credentials and the build will be complete."
    status "########################################################################################################################################"
    read answer
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
    status "OK, I'll be kind and show you one time your moodle credentials. You will need it during the installation process for moodle"
    status "Please make a note of them but remember to keep them safe and secret"
    status "============="
    status "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${DBIP} "${SUDO} /bin/cat /home/${SERVER_USER}/config/credentials/shit"`"
    status "============="
    status "By default, the administrator credentials of your moodle installation are: username: admin password: test1234  ****ESSENTIAL ACTION**** Change these"
    status
    status "If you ever see an error message, 'Coding error detected, it must be fixed by a programmer' the way to do this is to clear your browser cache"
    status
    status "Please press the <enter> key to acknowledge this message and that you have made a note of the credentials and the build will be complete."
    status "###########################################################################################################################################"
    read answer
fi
