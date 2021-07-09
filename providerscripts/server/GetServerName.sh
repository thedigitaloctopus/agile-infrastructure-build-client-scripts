#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will get the name of a server of the specified ip address
####################################################################################
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

server_ip="${1}"
cloudhost="${2}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    /usr/local/bin/doctl compute droplet list | /bin/grep ${server_ip} | /usr/bin/awk '{print $2}'
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
    /usr/local/bin/cs listVirtualMachines | jq --arg tmp_ip_address "${server_ip}" '(.virtualmachine[] | select(.nic[].ipaddress == $tmp_ip_address) | .displayname)' | /bin/sed 's/"//g'
  #  /usr/local/bin/cs listVirtualMachines | /usr/bin/jq '.virtualmachine[] | .nic[].ipaddress + " " + .displayname' | /bin/grep ".*${server_ip}" | /bin/sed 's/"//g' | /usr/bin/awk '{print $NF}'
fi

if ( [ "${cloudhost}" = "linode" ] )
then
    /usr/local/bin/linode-cli --text linodes list | /bin/grep ${server_ip} | /bin/grep -v 'id' | /usr/bin/awk '{print $2}'
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
    /bin/sleep 1
    /usr/bin/vultr server list | /bin/grep ${server_ip} | /usr/bin/awk '{print $4}' | /bin/sed 's/NAME//g' | /bin/sed '/^$/d'
fi

if ( [ "${cloudhost}" = "aws" ] )
then
        /usr/bin/aws ec2 describe-instances | /usr/bin/jq '.Reservations[].Instances[] | .PublicIpAddress + " " + .Tags[].Key + " " + .Tags[].Value' | /bin/sed 's/\"//g' | /bin/grep "${server_ip}" | /usr/bin/awk '{print $NF}'
fi
