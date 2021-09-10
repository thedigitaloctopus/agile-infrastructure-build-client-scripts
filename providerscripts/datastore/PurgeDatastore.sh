#!/bin/sh
##############################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will copy our generated config file for a particular
# provider over to our new machine
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
    config_bucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`-config/*"
    if ( [ "`/usr/bin/s3cmd ls s3://${config_bucket}`" != "" ] )
    then
        status "Purging bucket ${config_bucket}... feel free to purge it manually through the GUI if you want to"
        /usr/bin/s3cmd --recursive --force del s3://${config_bucket}
    fi

    location="`/usr/bin/s3cmd info s3://${config_bucket} | /bin/grep "Location" | /usr/bin/awk '{print $NF}'`"

    if ( [ "${location}" != "" ] && [ "`/bin/echo ${S3_HOST_BASE} | /bin/grep ${location}`" = "" ] )
    then
        status "#########################################################################################################################################################"
        status "WARNING, THE CONFIGURATION BUCKET IS IN A DIFFERENT REGION (${location}) TO THE LOCATION YOU HAVE SET ( ${S3_HOST_BASE} ), THIS WILL LIKELY CAUSE PROBLEMS"
        status "#########################################################################################################################################################"
        status "Press <enter> to accept this, although you are advised to remove the bucket from the other region"
        read x
    fi

fi
