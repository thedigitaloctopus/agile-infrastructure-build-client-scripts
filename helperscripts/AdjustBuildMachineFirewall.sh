#!/bin/sh
########################################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : You can use this script to authorise new laptop ip addresses to access your build machine
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
#set -x
if ( [ "${1}" = "" ] || [ "${2}" = "" ] || [ "${3}" = "" ] )
then
    /bin/echo "Sorry usage: ${0} <build-identifier> <ip> <mode - add|remove>"
    exit
else
    BUILD_IDENTIFIER="${1}"
    ip="${2}"
    mode="${3}"
    if ( [ "${mode}" != "add" ] && [ "${mode}" != "remove" ] )
    then
        /bin/echo "Sorry, that's an invalid mode"
        exit
    fi
fi

if ( [ "`/usr/bin/s3cmd ls s3://authip-${BUILD_IDENTIFIER}`" = "" ] )
then
    /usr/bin/s3cmd mb s3://authip-${BUILD_IDENTIFIER}
fi

/usr/bin/s3cmd --force get s3://authip-${BUILD_IDENTIFIER}/authorised-ips.dat

if ( [ "${mode}" = "add" ] )
then
    /bin/echo ${ip} >> ./authorised-ips.dat
else
    /bin/sed -i "/${ip}/d" ./authorised-ips.dat
fi

/usr/bin/sort -u -o ./authorised-ips.dat ./authorised-ips.dat | /bin/sed -i '/^$/d' ./authorised-ips.dat

/usr/bin/s3cmd put ./authorised-ips.dat  s3://authip-${BUILD_IDENTIFIER}
/bin/cp ./authorised-ips.dat /root/authorised-ips.dat
/bin/rm ./authorised-ips.dat
