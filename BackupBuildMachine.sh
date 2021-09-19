#!/bin/sh
######################################################################################################
# Description: By creating a file: s3://backup-${BUILD_IDENTIFIER}/authorised-ips.dat this will backup your
# build machine on a daily basis. This means if disaster strikes and your buildmachine fails for some reason
# you still have a backup of your configuration that you can recover from. OBVIOUSLY keep these backups very
# secure because anyone gaining access to them could potentially have access to your whole server suite. 
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

if ( [ "`/usr/bin/crontab -l | /bin/grep BackupBuildMachine`" = "" ] )
then
    /bin/echo "@daily ${BUILD_HOME}/BackupBuildMachine.sh ${BUILD_HOME} ${BACKUP_PASSWORD}" >> /var/spool/cron/crontabs/root
    /usr/bin/crontab -u root /var/spool/cron/crontabs/root
fi

BACKUP_DATE="`/usr/bin/date '+%B%d%Y'`"
RND="`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-3};echo;`"

if ( [ "${1}" != "" ] )
then
    BUILD_HOME="${1}"
fi

if ( [ "${2}" != "" ] )
then
    BACKUP_PASSWORD="${2}"
fi

/usr/bin/s3cmd mb s3://backup-${BACKUP_DATE}-${RND} 1>/dev/null 2>/dev/null

backupno="`/usr/bin/s3cmd ls s3://backup-${BACKUP_DATE}-${RND} | /usr/bin/wc -l`"

/bin/tar -cvzf - ${BUILD_HOME}/* | /usr/bin/gpg -c --passphrase ${BACKUP_PASSWORD} > /tmp/backup-${BUILD_IDENTIFIER}-${backupno}.tar.gz

/usr/bin/s3cmd put /tmp/backup-${BUILD_IDENTIFIER}.tar.gz s3://backup-${BACKUP_DATE}-${RND}

/bin/rm /tmp/backup-${BUILD_IDENTIFIER}-${backupno}.tar.gz

