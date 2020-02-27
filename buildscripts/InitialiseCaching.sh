#!/bin/sh
###########################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script allows the user to indicate whether they will be using a caching cluster
###########################################################################################
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
############################################################################################
############################################################################################
#set -x

if ( [ "${PREVIOUS_BUILD_CONFIG}" = "0" ] )
then
    status "####################################"
    status "Would you be using a caching system?"
    status "####################################"
    status "Please enter (Y|y) if you will be using caching"
    read response

    while ( [ "${response}" = "" ] || [ "`/bin/echo "y Y n N" | /bin/grep ${response}`" = "" ] )
    do
        status "Invalid response...."
        status "Would Will you be using caching?"
        status "Please enter (Y|y) indicate that you are using caching"
        read response
    done

    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        status "###########################################"
        status "Will you be using 1) Memcache or 2) Redis?"
        status "###########################################"
        status "Please enter 1 or 2 to indicate which type of caching you will be using"
        read userresponse

        while ( [ "${userresponse}" = "" ] || [ "`/bin/echo 1 2 | /bin/grep ${userresponse}`" = "" ] )
        do
            status "Invalid input, please try again"
            read userresponse
        done

        if ( [ "${userresponse}" = "1" ] )
        then
            status "What port is your memcache cluster running on or accepting connections on?"
            read memcache_port

            status "What is the hostname or ip address of the machine where memcache is running?"
            read memcache_host

            status "Please tell us the id of any security groups associated with your memcache cluster"
            read memcache_security_group

            IN_MEMORY_CACHING="memcache"
            IN_MEMORY_CACHING_PORT="${memcache_port}"
            IN_MEMORY_CACHING_HOST="${memcache_host}"
            IN_MEMORY_SECURITY_GROUP="${memcache_security_group}"
        elif ( [ "${userresponse}" = "2" ] )
        then
            status "What port is your redis cluster running on or accepting connections on?"
            read redis_port

            status "What is the hostname or ip address of the machine where redis is running?"
            read redis_host
            #
            status "Please tell us the id of any security groups associated with your memcache cluster"
            read redis_security_group

            IN_MEMORY_CACHING="redis"
            IN_MEMORY_CACHING_PORT="${redis_port}"
            IN_MEMORY_CACHING_HOST="${redis_host}"
            IN_MEMORY_SECURITY_GROUP="${redis_security_group}"
        fi
    fi
fi
