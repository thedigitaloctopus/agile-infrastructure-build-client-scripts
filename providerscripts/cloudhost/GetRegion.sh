#!/bin/sh
##########################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script gets the particular region that the deployment is being made to
##########################################################################################
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
##########################################################################################
##########################################################################################
#set -x

region="`/bin/echo ${1} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
cloudhost=${2}

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    /bin/echo ${1}
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
    regions="`/usr/local/bin/cs listZones | /usr/bin/jq '.zone[].name' | /bin/sed 's/"//g'`"

    if ( [ "`/bin/echo ${regions} | /bin/grep ${region}`" = "" ] )
    then
        /bin/echo "Sorry, that's not a valid region, please try again"
        read region
    fi

    /usr/local/bin/cs listZones | /usr/bin/jq '.zone[].id' > runtimedata/listofregionids
    /usr/local/bin/cs listZones | /usr/bin/jq '.zone[].name' > runtimedata/listofregionnames

    region_index="`/bin/cat -n runtimedata/listofregionnames | /bin/grep ${region} | /usr/bin/awk '{print $1}'`"
    region="`/bin/sed "${region_index}q;d" runtimedata/listofregionids`"
    /bin/echo ${region} | /bin/sed 's/"//g'
fi

if ( [ "${cloudhost}" = "linode" ] )
then
    /bin/echo ${1}
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
    export VULTR_API_KEY="`/bin/ls ${HOME}/.config/VULTRAPIKEY:* | /usr/bin/awk -F':' '{print $NF}'`"
    region="`/bin/echo ${region} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
    /bin/sleep 1
    regionid="`/usr/bin/vultr regions | /bin/grep ${region} | /usr/bin/awk '{print $1}'`"

    if ( [ "${regionid}" != "" ] )
    then
        /bin/echo ${regionid}
    fi
fi

if ( [ "${cloudhost}" = "aws" ] )
then
    /bin/echo ${1}
fi

