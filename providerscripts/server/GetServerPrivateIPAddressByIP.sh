#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will get the private ip address of a server based on its
# public ip address
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
####################################################################################
####################################################################################

#set -x

ip="${1}"
cloudhost="${2}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    /usr/local/bin/doctl compute droplet list | /bin/grep ${ip} | /usr/bin/awk '{print $4}'
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
    /bin/rm /tmp/ipaddresses /tmp/servernames
    while ( [ "`/bin/cat /tmp/ipaddresses | /usr/bin/wc -l 2>/dev/null`" = "0" ]  || [ "`/bin/cat /tmp/servernames | /usr/bin/wc -l 2>/dev/null`" = "0" ] )
    do
        /usr/local/bin/cs listVirtualMachines | /usr/bin/jq ".virtualmachine[].nic[].ipaddress"  | /bin/grep -v 'null' | /bin/sed 's/\"//g' > /tmp/ipaddresses 2>/dev/null
        /usr/local/bin/cs listVirtualMachines | /usr/bin/jq ".virtualmachine[].displayname"  | /bin/grep -v 'null' | /bin/sed 's/\"//g' > /tmp/servernames 2>/dev/null
    done
    /usr/bin/paste -d" " /tmp/servernames /tmp/ipaddresses | /bin/grep ${ip} | /usr/bin/awk '{print $2}'
fi

if ( [ "${cloudhost}" = "linode" ] )
then
    webserver_name="`./providerscripts/server/GetServerName.sh "${ip}" "linode"`"
    /usr/local/bin/linode-cli linodes list --text | /bin/grep ${ip} | /usr/bin/awk '{print $(NF)}'
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
    /bin/sleep 1
    ids="`/usr/bin/vultr servers | /usr/bin/awk '{print $1}' | /bin/sed 's/SUBID//g'`"
    for id in ${ids}
    do
        /bin/sleep 1
        if ( [ "`/usr/bin/vultr server show ${id} | /bin/grep "^IP:" | /usr/bin/awk '{print $2}'`" = "${ip}" ] )
        then
            /bin/sleep 1
            /usr/bin/vultr server show ${id} | /bin/grep "Internal IP:" | /usr/bin/awk '{print $3}'
            break
        fi
    done
fi

if ( [ "${cloudhost}" = "aws" ] )
then
    /usr/bin/aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" | /usr/bin/jq '.Reservations[].Instances[] | .PublicIpAddress + " " +.PrivateIpAddress' | /bin/sed 's/\"//g' | /bin/grep ${ip} | /usr/bin/awk '{print $2}' 
fi

