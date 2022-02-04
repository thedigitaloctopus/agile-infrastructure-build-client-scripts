#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will destroy the specified server by ip address
###################################################################################
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
###################################################################################
###################################################################################
#set -x

status () {
    /bin/echo "$1" | /usr/bin/tee /dev/fd/3
}

server_ip="${1}"
cloudhost="${2}"
BUILD_HOME="`/bin/pwd`"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    server_id="`/usr/local/bin/doctl compute droplet list | /bin/grep ${server_ip} | /usr/bin/awk '{print $1}'`"
    /usr/local/bin/doctl -force compute droplet delete ${server_id} 
    status "Destroyed a server with ip address ${server_ip}"
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
    server_id="`/usr/local/bin/cs listVirtualMachines | jq --arg tmp_ip_address "${server_ip}" '(.virtualmachine[] | select(.nic[].ipaddress == $tmp_ip_address) | .id)' | /bin/sed 's/\"//g'`"
    /usr/local/bin/cs destroyVirtualMachine id="${server_id}"
    status "Destroyed a server with ip address ${server_ip}"
fi
if ( [ "${cloudhost}" = "linode" ] )
then
    if ( [ "${server_ip}" != "" ] )
    then
        server_to_delete=""
        server_to_delete="`${BUILD_HOME}/providerscripts/server/GetServerName.sh ${server_ip} 'linode'`"
        server_id="`/usr/local/bin/linode-cli linodes list --text --label ${server_to_delete} | /bin/grep -v "id" | /usr/bin/awk '{print $1}'`"
        /usr/local/bin/linode-cli linodes shutdown ${server_id}
        /usr/local/bin/linode-cli linodes delete ${server_id}
        status "Destroyed a server with ip address ${server_ip}"
    fi
fi


if ( [ "${cloudhost}" = "vultr" ] )
then
    BUILD_HOME="`/usr/bin/pwd | /bin/sed 's/agile-infrastructure-build-client-scripts.*/agile-infrastructure-build-client-scripts/g'`"    
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
    /bin/sleep 1
    #Clonk
    #server_id="`/usr/bin/vultr server list | /bin/grep ${server_ip} | /usr/bin/awk '{print $1}'`"
    #Official
    server_id="`/usr/bin/vultr instance list | /bin/grep ${server_ip} | /usr/bin/awk '{print $1}'`"
    /bin/sleep 1
    #Clonk
    #/usr/bin/vultr server delete ${server_id} --force=true
    #Official   
    /usr/bin/vultr instance delete ${server_id}

    status "Destroyed a server with ip address ${server_ip}"
fi

if ( [ "${cloudhost}" = "aws" ] )
then
    instance_id="`/usr/bin/aws ec2 describe-instances | /usr/bin/jq '.Reservations[].Instances[] | .InstanceId + " " + .PublicIpAddress' | /bin/sed 's/\"//g' | /bin/grep ${server_ip} | /usr/bin/awk '{print $1}'`"
  #  /usr/bin/aws ec2 stop-instances --instance-ids ${instance_id}
    /usr/bin/aws ec2 terminate-instances --instance-ids ${instance_id}
fi

