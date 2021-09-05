#!/bin/sh
##############################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will copy our generated snapshots data to the datastore
###############################################################################
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
#################################################################################
#################################################################################
#set -x

if ( [ "${DATASTORE_CHOICE}" = "amazonS3" ] || [ "${DATASTORE_CHOICE}" = "digitalocean" ] || [ "${DATASTORE_CHOICE}" = "exoscale" ] || [ "${DATASTORE_CHOICE}" = "linode" ] || [ "${DATASTORE_CHOICE}" = "vultr" ] )
then
    snapshot_bucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`-snaps/*"
    if ( [ "`/usr/bin/s3cmd ls s3://${snapshot_bucket}`" != "" ] )
    then
        /usr/bin/s3cmd get s3://${snapshot_bucket}/snapshots.tar.gz
    fi

    if ( [ ! -d ${BUILD_HOME}/snapshots ] )
    then
        /bin/mkdir ${BUILD_HOME}/snapshots
    fi

    if ( [ -f ./snapshots.tar.gz ] )
    then
        /bin/tar xvfz ./snapshots.tar.gz -C ${BUILD_HOME}/snapshots
    fi

    /bin/tar cvfz ./snapshots.tar.gz ${BUILD_HOME}/snapshots/*

    if ( [ "`/usr/bin/s3cmd ls s3://${snapshot_bucket}`" = "" ] )
    then
        /usr/bin/s3cmd put snapshots.tar.gz s3://${snapshot_bucket}/
    fi

    if ( [ -f ./snapshots.tar.gz ] )
    then
        /bin/rm ./snapshots.tar.gz
    fi
fi
