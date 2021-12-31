#!/bin/sh
########################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : You can use this script to remove buckets from your datastore
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


buckets="`/usr/bin/s3cmd ls | /usr/bin/awk '{print $NF}'`"


for bucket in ${buckets}
do
    /bin/echo "Have found bucket: ${bucket} do you want to delete it, (Y|N)"
    read response

    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        /usr/bin/s3cmd del --recursive --force ${bucket}
        /usr/bin/s3cmd rb ${bucket}
    fi
done
