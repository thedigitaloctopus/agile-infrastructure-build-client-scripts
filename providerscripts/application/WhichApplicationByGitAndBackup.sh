#!/bin/sh
##################################################################################
# Description: This script will work our what type of application you are running
# based on a git repository backup
# Author: Peter Winter
# Date: 05/01/2017
##################################################################################
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
###################################################################################
###################################################################################
set -x

status () {
    /bin/echo "$1" | /usr/bin/tee /dev/fd/3
}


database_engine="`/bin/cat ${INTERROGATION_HOME}/${backuprepository}/dbe.dat`"
if ( [ "${database_engine}" != "" ] && [ "${database_engine}" != "${DATABASE_INSTALLATION_TYPE}" ] )
then 
    if ( [ "${database_engine}" = "MySQL" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "Maria" ] )
    then
        database_engine="Maria"
    fi
    export DATABASE_INSTALLATION_TYPE="${database_engine}"
fi

#################JOOMLA################
if ( [ -d ${INTERROGATION_HOME}/${backuprepository}/administrator ] && [ -d ${INTERROGATION_HOME}/${backuprepository}/modules ] && [ -d ${INTERROGATION_HOME}/${backuprepository}/plugins ] )
then
    /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/APPLICATION:joomla
    APPLICATION="joomla"
    interrogated="1"
    DIRECTORIES_TO_MOUNT="images"
    status "Discovered you are deploying joomla"
    status "Press the <enter> key to accept as true"
    read x
    #################JOOMLA################
    #################WORDPRESS################
elif ( [ -f ${INTERROGATION_HOME}/${backuprepository}/wp-login.php ] )
then
    /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/APPLICATION:wordpress
    APPLICATION="wordpress"
    interrogated="1"
    DIRECTORIES_TO_MOUNT="wp-content.uploads"
    status "Discovered you are deploying wordpress"
    status "Press the <enter> key to accept as true"
    read x
    #################WORDPRESS################
    #################MOODLE################
elif ( [ -d ${INTERROGATION_HOME}/${backuprepository}/moodle ] )
then
    /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/APPLICATION:moodle
    APPLICATION="moodle"
    interrogated="1"
    DIRECTORIES_TO_MOUNT="moodledata.filedir"
    status "Discovered you are deploying moodle"
    status "Press the <enter> key to accept as true"
    read x
    #################MOODLE################
    #################DRUPAL################
elif ( [ -f ${INTERROGATION_HOME}/${backuprepository}/core/misc/drupal.js ] )
then
    /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/APPLICATION:drupal
    APPLICATION="drupal"
    interrogated="1"
    DIRECTORIES_TO_MOUNT="sites.default.files.pictures:sites.default.files.styles:sites.default.files.inline-images"
    status "Discovered you are deploying drupal"
    status "Press the <enter> key to accept as true"
    read x
    #################DRUPAL################
fi
