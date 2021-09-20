#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date  : 13/7/2016
# Description : Whenever you want to add a new application type, you can modify this file
# for your new application following the pattern that has been set by the existing applications.
#####################################################################################
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
####################################################################################
####################################################################################
#set -x
if ( [ "${APPLICATION_LANGUAGE}" = "PHP" ] )
then
    APPLICATION="NONE"
    BUILD_ARCHIVE_CHOICE="virgin"
    status "You have opted to install a virginal copy of an Application."
    status "IMPORTANT, PLEASE DO NOT TRY TO CONFIGURE YOUR NEW Application UNTIL THIS BUILD PROCESS HAS COMPLETED"

    while ( [ "`/bin/echo '0 1 2 3 4' | /bin/grep ${APPLICATION}`" = "" ] )
    do
        status "Please select your Application of choice. We currently support: 0) None (MYSQL or Postgres)"
        status "                                                                1) Joomla    (Please use MYSQL only)"
        status "                                                                2) Wordpress (Please use MYSQL only)"
        status "                                                                3) Moodle    (Please use MYSQL only)"
        status "                                                                4) Drupal    (Please use MYSQL or Postgres)"
        read APPLICATION
    done

    if ( [ "${PRODUCTION}" != "0" ] && [ "${DEVELOPMENT}" != "1" ] )
    then
        status "This is a virgin installation it has to be done in development mode."
        status "I mean it makes no sense to deploy a virgin CMS to production, right?"
        status "I am setting you to development mode"

        status "Press <enter> to acknowledge"
        read x

        PRODUCTION="0"
        DEVELOPMENT="1"

        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/PRODUCTION:1
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/DEVELOPMENT:0
    fi

    if ( [ "${APPLICATION}" = "0" ] )
    then
        APPLICATION_BASELINE_SOURCECODE_REPOSITORY="${BUILD_IDENTIFIER}"
        BASELINE_DB_REPOSITORY="VIRGIN"
    fi

    if ( [ "${APPLICATION}" = "1" ] )
    then
        status "Plese input the version number of joomla that you wish to install."
        status "You can find the latest version number at:"
        status "https://github.com/joomla/joomla-cms/releases. At the time of typing, the latest version is 3.8.5 so,"
        status " it would be expected that you would enter 3.8.5 here to install it"
        read JOOMLA_VERSION
        while ( [ "`/usr/bin/curl --head --silent --fail https://github.com/joomla/joomla-cms/releases/download/${JOOMLA_VERSION}/Joomla_${JOOMLA_VERSION}-Stable-Full_Package.tar.gz 2> /dev/null`" = "" ] &&  [ "`/usr/bin/curl --head --silent --fail https://github.com/joomla/joomla-cms/releases/download/${JOOMLA_VERSION}/Joomla_${JOOMLA_VERSION}-Alpha-Full_Package.tar.gz 2> /dev/null`" = "" ] && [ "`/usr/bin/curl --head --silent --fail https://github.com/joomla/joomla-cms/releases/download/${JOOMLA_VERSION}/Joomla_${JOOMLA_VERSION}-Beta-Full_Package.tar.gz 2> /dev/null`" = "" ]  && [ "`/usr/bin/curl --head --silent --fail https://github.com/joomla/joomla-cms/releases/download/${JOOMLA_VERSION}/Joomla_${JOOMLA_VERSION}-Release_Candidate-Full_Package.tar.gz 2> /dev/null`" = "" ] )
        do
            status "That seems to be an invalid version number for joomla. Please try again..."
            read JOOMLA_VERSION
        done

        APPLICATION_BASELINE_SOURCECODE_REPOSITORY="JOOMLA:${JOOMLA_VERSION}"
        BASELINE_DB_REPOSITORY="VIRGIN"
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/APPLICATION:joomla
        APPLICATION="joomla"
        DIRECTORIES_TO_MOUNT="images"
elif ( [ "${APPLICATION}" = "2" ] )
    then
        APPLICATION_BASELINE_SOURCECODE_REPOSITORY="WORDPRESS"
        BASELINE_DB_REPOSITORY="VIRGIN"
        APPLICATION="wordpress"
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/APPLICATION:wordpress
        DIRECTORIES_TO_MOUNT="wp-content.uploads"
elif ( [ "${APPLICATION}" = "3" ] )
    then
        APPLICATION_BASELINE_SOURCECODE_REPOSITORY="MOODLE:${MOODLE_VERSION}"
        BASELINE_DB_REPOSITORY="VIRGIN"
        APPLICATION="moodle"
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/APPLICATION:moodle
        DIRECTORIES_TO_MOUNT="moodledata.filedir"
elif ( [ "${APPLICATION}" = "4" ] )
    then
        status "Plese input the version number of drupal that you wish to install."
        status "You can find the latest version number at:"
        status "https://www.drupal.org/download"
        read DRUPAL_VERSION

        while ( [ "`/usr/bin/curl -s --head https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz | head -n 1 | /bin/grep 'HTTP/2 200'`" = "" ] )
        do
            status "Hey, it seems like that is not a valid version number for drupal. Check out www.drupal.org for the latest download version"
            status "Enter it here and we will try again. At the time of writing, the latest version is 8.2.4"
            read DRUPAL_VERSION
        done
        APPLICATION_BASELINE_SOURCECODE_REPOSITORY="DRUPAL:${DRUPAL_VERSION}"
        BASELINE_DB_REPOSITORY="VIRGIN"
        APPLICATION="drupal"
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/APPLICATION:drupal
        DIRECTORIES_TO_MOUNT="sites.default.files.pictures:sites.default.files.styles:sites.default.files.inline-images"
    fi
fi
