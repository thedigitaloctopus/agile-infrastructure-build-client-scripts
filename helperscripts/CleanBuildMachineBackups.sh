#!/bin/sh
########################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This will delete backup archives of your build machine from your datastore at your command
########################################################################################################
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

if ( [ ! -f  ./CleanupBuildMachineBackups.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

export BUILD_HOME="`/usr/bin/pwd | /bin/sed 's/\/helper.*//g'`"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr 5)AWS. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
    CLOUDHOST="digitalocean"
elif ( [ "${response}" = "2" ] )
then
    CLOUDHOST="exoscale"
elif ( [ "${response}" = "3" ] )
then
    CLOUDHOST="linode"
elif ( [ "${response}" = "4" ] )
then
    CLOUDHOST="vultr"
elif ( [ "${response}" = "5" ] )
then
    CLOUDHOST="aws"
else
    /bin/echo "Unrecognised  cloudhost. Exiting ...."
    exit
fi

/bin/echo "What is the build identifier you want to connect to?"
/bin/echo "You have these builds to choose from: "
/bin/ls ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} | /bin/grep -v 'credentials'
/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

backups="`/usr/bin/s3cmd ls | /bin/grep "backup-${BUILD_IDENTIFIER}" | /usr/bin/awk -F'/' '{print $NF}'`"

if ( [ "${backups}" = "" ] )
then
    /bin/echo "No backups found"
    exit
fi

for backup in ${backups}
do
    /bin/echo "Do you want to delete backup named: ${backup}"
    /bin/echo "This is irreversible if you do"
    /bin/echo "Please enter Y or y to delete it"
    read response

    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        /usr/bin/s3cmd del --recursive --force s3://${backup}
        /usr/bin/s3cmd rb s3://${backup}
    fi
done
