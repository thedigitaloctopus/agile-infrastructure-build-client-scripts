#!/bin/sh
##############################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will get all the server ip addresses of the machines of a specified type
##############################################################################################
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
#############################################################################################
#############################################################################################
#set -x

server_type="$1"
cloudhost="$2"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    /usr/local/bin/doctl compute droplet list | /bin/grep ".*${server_type}" | /usr/bin/awk '{print $3}'
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
     display_name="`/bin/echo ${server_type} | /bin/sed 's/\*//g'`"
     ip="`/usr/local/bin/cs listVirtualMachines | /usr/bin/jq --arg tmp_display_name "${display_name}" '(.virtualmachine[] | select(.displayname | contains($tmp_display_name)) | .publicip)' | /bin/sed 's/"//g'`"
     /bin/echo ${ip}
 fi

if ( [ "${cloudhost}" = "linode" ] )
then
    /usr/local/bin/linode-cli linodes list --text | /bin/grep ".*${server_type}" | /bin/grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | /bin/grep -v "192.168"
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
    BUILD_HOME="`/usr/bin/pwd | /bin/sed 's/agile-infrastructure-build-client-scripts.*/agile-infrastructure-build-client-scripts/g'`"    
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
    /bin/sleep 1
    server_type="`/bin/echo ${server_type} | /usr/bin/cut -c -25`"
    #Clonk
    #ip="`/usr/bin/vultr server list | /bin/grep ".*${server_type}" | /usr/bin/awk '{print $3}' | /bin/sed 's/IP//g' | /bin/sed '/^$/d'`"
    #Official
    ip="`/usr/bin/vultr instance list | /bin/grep ".*${server_type}" | /usr/bin/awk '{print $2}'`"
    
    if ( [ "${ip}" = "0.0.0.0" ] )
    then
        /bin/echo ""
    else
        /bin/echo "${ip}"
    fi
fi

if ( [ "${cloudhost}" = "aws" ] )
then
    /usr/bin/aws ec2 describe-instances --filter "Name=tag:descriptiveName,Values=*${server_type}*" "Name=instance-state-name,Values=running" | /usr/bin/jq '.Reservations[].Instances[].PublicIpAddress' | /bin/sed 's/\"//g'
fi


