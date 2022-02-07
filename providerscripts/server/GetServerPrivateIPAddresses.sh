#!/bin/sh
#########################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description :  This script gets the private ip address of a machine given its unique name
#########################################################################################
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
########################################################################################
########################################################################################
#set -x

server_type="${1}"
cloudhost="${2}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    /usr/local/bin/doctl compute droplet list | /bin/grep ".*${server_type}" | /usr/bin/awk '{print $4}'
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
    display_name="`/bin/echo ${server_type} | /bin/sed 's/\*//g'`"

    ips="`/usr/local/bin/cs listVirtualMachines | /usr/bin/jq --arg tmp_display_name "${display_name}" '(.virtualmachine[] | select(.displayname | contains($tmp_display_name)) | .publicip)' | /bin/sed 's/"//g'`"

    for ip in ${ips}
    do
        vmid="`/usr/local/bin/cs listVirtualMachines | /usr/bin/jq --arg tmp_ip_address "${ip}" '(.virtualmachine[].nic[] | select(.ipaddress == $tmp_ip_address) | .id)' | /bin/sed 's/"//g'`"
        vmid2="`/usr/local/bin/cs listNics | jq --arg tmp_virtual_machine_id "${vmid}" '(.nic[] | select(.id == $tmp_virtual_machine_id) | .virtualmachineid)' | /bin/sed 's/"//g'`"
        private_ipaddress="`/usr/local/bin/cs listNics | jq --arg tmp_virtual_machine_id "${vmid2}" '(.nic[] | select(.isdefault == false and .virtualmachineid == $tmp_virtual_machine_id) | .ipaddress)' | /bin/sed 's/"//g'`"
        /bin/echo ${private_ipaddress}
    done
fi

if ( [ "${cloudhost}" = "linode" ] )
then
    /usr/local/bin/linode-cli linodes list --text | /bin/grep ".*${server_type}" | /bin/grep -o "192.168[^[:space:]]*"
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
    BUILD_HOME="`/usr/bin/pwd | /bin/sed 's/agile-infrastructure-build-client-scripts.*/agile-infrastructure-build-client-scripts/g'`"    
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
    /bin/sleep 1
    server_type="`/bin/echo ${server_type} | /usr/bin/cut -c -25`"
    #Clonk
    #ids="`/usr/bin/vultr server list | /bin/grep ".*${server_type}" | /usr/bin/awk '{print $1}' | /bin/sed 's/SUBID//g' | /bin/sed '/^$/d'`"
    #for id in ${ids}
    #do
    #    /bin/sleep 1
    #    /usr/bin/vultr server list-ipv4 ${id} | /bin/grep '^10\.' | /usr/bin/awk '{print $1}'
    #done
    #Official
    ids="`/usr/bin/vultr instance list | /bin/grep ".*${server_type}" | /usr/bin/awk '{print $1}'`"
    for id in ${ids}
    do
        /usr/bin/vultr instance get ${id} | /bin/grep "INTERNAL IP" | /usr/bin/awk '{print $NF}'
    done
fi

if ( [ "${cloudhost}" = "aws" ] )
then
    /usr/bin/aws ec2 describe-instances --filter "Name=tag:descriptiveName,Values=*${server_type}*" "Name=instance-state-name,Values=running" | /usr/bin/jq '.Reservations[].Instances[].PrivateIpAddress' | /bin/sed 's/\"//g'
fi
