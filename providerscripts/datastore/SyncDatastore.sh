#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Sync one bucket to another
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
#######################################################################################
#######################################################################################
#set -x

datastore_provider="$1"
original_object="$2"
new_object="$3"

if ( [ "${datastore_provider}" = "amazonS3" ] || [ "${datastore_provider}" = "digitalocean" ] || [ "${datastore_provider}" = "exoscale" ] ||  [ "${datastore_provider}" = "linode" ] || [ "${datastore_provider}" = "vultr" ]  )
then
    /usr/bin/s3cmd sync s3://${original_object} s3://${new_object}
fi