#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Get a file from a bucket in the datastore
######################################################################################
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
######################################################################################
######################################################################################
set -x

datastore_provider="$1"
datastore_to_get="`/bin/echo $2 | /usr/bin/cut -c-63`"

if ( [ "${datastore_provider}" = "amazonS3" ] || [ "${datastore_provider}" = "digitalocean" ] || [ "${datastore_provider}" = "exoscale" ] || [ "${datastore_provider}" = "linode" ] || [ "${datastore_provider}" = "vultr" ] )
then
    if ( [ "${3}" != "" ] )
    then
        /usr/bin/s3cmd --force --recursive get s3://${datastore_to_get} ${3}
    else
        /usr/bin/s3cmd --force --recursive get s3://${datastore_to_get}
    fi
fi

