#!/bin/sh
########################################################################################################
# Description: By creating a file: s3://backup-${BUILD_IDENTIFIER}/authorised-ips.dat this will backup your
# build machine on a daily basis. This means if disaster strikes and your buildmachine fails for some reason
# you still have a backup of your configuration that you can recover from. OBVIOUSLY keep these backups very
# secure because anyone gaining access to them could potentially have access to your whole server suite. 
# Note: to decrypt your backup:
########################################################################################################
# Get the backup you want from s3 using s3cmd 
# openssl enc -d -pbkdf2  -md md5 -pass pass:${BACKUP_PASSWORD} -in ./backup-${BACKUP_DATE}-${backupno}.tar.gz  | /bin/tar -xv
########################################################################################################
# Author: Peter Winter
# Date: 17/01/2021
#######################################################################################################
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

set -x

if ( [ "`/usr/bin/crontab -l | /bin/grep BackupBuildMachine`" = "" ] )
then
    /bin/echo "@daily ${BUILD_HOME}/BackupBuildMachine.sh ${BUILD_IDENTIFIER} ${BUILD_HOME} 'fromcron' ${BACKUP_PASSWORD}" >> /var/spool/cron/crontabs/root
    /usr/bin/crontab -u root /var/spool/cron/crontabs/root
fi

BACKUP_DATE="`/usr/bin/date '+%B%d%Y'`"
UNIQUE="`/usr/bin/date +%s | /usr/bin/sha256sum | /usr/bin/base64 | /usr/bin/head -c 4 ; echo`"

if ( [ "${1}" != "" ] )
then
    BUILD_IDENTIFIER="${1}"
fi

if ( [ "${2}" != "" ] )
then
    BUILD_HOME="${2}"
fi

if ( [ "${4}" != "" ] )
then
    BACKUP_PASSWORD="${4}"
fi

if ( [ "${BACKUP_PASSWORD}" != "" ] && [ "${3}" = "fromcron" ] )
then
    bucket_name="backup-${BUILD_IDENTIFIER}"

    /usr/bin/s3cmd mb s3://${bucket_name}

    backupno="`/usr/bin/s3cmd ls s3://${bucket_name} | /usr/bin/wc -l`"

    if ( [ "${backupno}" = "" ] )
    then
        backupno="1"
    fi

    /bin/tar -cO ${BUILD_HOME} | openssl enc -pbkdf2  -md md5 -pass pass:${BACKUP_PASSWORD} > /tmp/backup-${BACKUP_DATE}-${backupno}.tar.gz

    /usr/bin/s3cmd put /tmp/backup-${BACKUP_DATE}-${backupno}.tar.gz s3://${bucket_name}

    /bin/rm /tmp/backup-${BACKUP_DATE}-${backupno}.tar.gz
fi

