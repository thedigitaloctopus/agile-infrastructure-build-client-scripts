#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script lists all available regions for the provider
#####################################################################################
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
#####################################################################################
#####################################################################################
#set -x

cloudhost=${1}

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    /usr/local/bin/doctl compute region list | /usr/bin/awk '{print $1}' | /bin/sed -n '1!p'
fi
if ( [ "${cloudhost}" = "exoscale" ] )
then
    /usr/local/bin/cs listZones | /usr/bin/jq '.zone[].name' | /bin/sed 's/"//g'
fi
if ( [ "${cloudhost}" = "linode" ] )
then
    /usr/local/bin/linode-cli  --text regions list | /bin/grep -v "^id" | /usr/bin/awk '{print $1}'
fi
if ( [ "${cloudhost}" = "vultr" ] )
then
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
    /bin/sleep 1
    #clonk
    #/usr/bin/vultr regions | /usr/bin/awk '{print $NF}' | /bin/sed 's/CODE//g'
    #Official
    /usr/bin/vultr regions list | /usr/bin/awk '{print $1}' | /bin/grep '[a-z][a-z][a-z]'
fi
if ( [ "${cloudhost}" = "aws" ] )
then
    /usr/bin/aws ec2 describe-regions | /usr/bin/jq '.Regions[].RegionName' | /bin/sed 's/"//g'
fi

