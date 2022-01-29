#!/bin/sh
###############################################################################################
# Description: Not all providers play the same so if you have any preprocessing messages you want
# to display before the build begins, you can add then into this file and it will get executed
# prior to the build commencing.
# Author: Peter Winter
# Date : 17/01/2017
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
#######################################################################################################
#set -x

#If you have any pre-processing messages to add, you can add them here. These messages will be displayed before the build
#truly gets going.

if ( [ "${CLOUDHOST}" = "aws" ] && [ "${DISABLE_HOURLY}" = "0" ] )
then
    status "############################################################################################################################################"
    status "Please be aware that you have hourly backups enabled which are counted as \"dataout\" by AWS. This can rack up quite some costs as such transfers"
    status "Are billable under AWS. It is recommended therefore that you switch off hourly backups and only rely on daily, weekly, monthly and bi-monthly"
    status "I recommend making very sure of your cost profile when using the AWS system because it can surprise bill you if you are not careful. I think its great"
    status "and all that, but, you know, we don't want to end up brassic"
    status "############################################################################################################################################"
fi

if ( [ "${BUILD_ARCHIVE_CHOICE}" = "virgin" ] || [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] )
then
    PRODUCTION="0"
    DEVELOPMENT="1"
fi

if ( [ "${DEVELOPMENT}" = "0" ] )
then
    status "############################################################################################################################################"
    status "If your DNS service provider uses any kind of DOS or DDOS detection, then, if you want system monitoring to work correctly, you will have to"
    status "Whitelist your Autoscaler's IP address with your DNS service provider"
    status "Press <enter> to acknowledge this"
    status "############################################################################################################################################"
    read response
fi


if ( [ "${DATABASE_INSTALLATION_TYPE}" = "Postgres" ] && [ "${APPLICATION}" = "wordpress" ] )
then
    status "################################################################"
    status "Apologies, but, Wordpress doesn't support the Postgres Database."
    status "I am defaulting to mariadb. Press <enter> to acknowledge"
    status "################################################################"
    read x
    DATABASE_INSTALLATION_TYPE="Maria"
fi

if ( [ "${DATABASE_INSTALLATION_TYPE}" = "Postgres" ] && [ "${APPLICATION}" = "joomla" ] )
then
    status "################################################################"
    status "Sorry, I don't know how to set anything other than the default port - 5432 for the postgres database when using joomla"
    status "Setting expected postgres port to 5432"
    status "################################################################"
    /bin/sed -i '/DB_PORT=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
    /bin/echo "export DB_PORT=\"5432\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
    DB_PORT=5432
fi


if ( [ "${DATABASE_INSTALLATION_TYPE}" = "Postgres" ] || [ "${DATABASE_DBaaS_INSTALLATION_TYPE}" = "Postgres" ] )
then
    response=""

    if ( [ "${DBaaS_DBNAME}" != "" ] )
    then
        /bin/bash -c "[[ '${DBaaS_DBNAME}' =~ [A-Z] ]] && /bin/touch ${BUILD_HOME}/LOWER && /bin/echo 'I know this is your worst nightmare, but, please read carefully. I have detected that you have some upper case letters in the databse name for your postgres database. By default postgres sets the database names to lower case and so chances are, this is what your postgres has done. Please review this to see if it is the case, but I thought I would give you a chance to change your database name to all lower case.' && /bin/echo && /bin/echo 'Your database name is currently set to: ${DBaaS_DBNAME}.' && /bin/echo 'enter (Y|y) and I will set the characters  of your database name all to lower case for you...' && /bin/echo 'Press <enter> to leave as it is '"
       
       if ( [ -f ${BUILD_HOME}/LOWER ] )
        then
            read response
        fi
       
        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
        then
            if ( [ -f ${BUILD_HOME}/LOWER ] )
            then
                /bin/rm ${BUILD_HOME}/LOWER
                DBaaS_DBNAME="`/bin/echo "${DBaaS_DBNAME}" | /usr/bin/tr '[:upper:]' '[:lower:]'`"
            fi
        fi
        
        if ( [ -f ${BUILD_HOME}/LOWER ] )
        then
            status "#################################################"
            status "Your database name is now set to: ${DBaaS_DBNAME}"
            status "Press <enter> to accept"
            status "#################################################"
            read x
        fi
    fi
fi

if ( [ "${APPLICATION}" = "moodle" ] && ( [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] || [ "${DATABASE_DBaaS_INSTALLATION_TYPE}" = "Maria" ] ) )
then
    status "###################################################################################################################################"
    status "Hi, it's me again... I am going to try and set some parameters for your database. Some providers, for example, AWS, don't"
    status "allow this to be done directly via scripts and so, with AWS, for example, I can't do this for you and you need to create "
    status "a parameter group and apply it to your database when you deploy iti through the AWS console. Other providers will vary."
    status ""
    status "The settings you need to have for moodle  in your parameter group (ref AWS documentation) are as follows:"
    status
    status "innodb_file_format=Barracuda , innodb_file_per_table=ON , innodb_large_prefix=1 , binlog_format = 'MIXED'"
    status
    status "###################################################################################################################################"
    read x
fi
