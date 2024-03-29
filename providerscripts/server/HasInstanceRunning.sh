#!/bin/sh
########################################################################################
# Author : Peter Winter
# Date:    13/07/2016
# Description : This script will determine if a machine with a given name is running or not
########################################################################################
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

instance_type="${1}"
cloudhost="${2}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    /usr/local/bin/doctl compute droplet list | /bin/grep ${instance_type}
fi
if ( [ "${cloudhost}" = "exoscale" ] )
then
    /usr/local/bin/cs listVirtualMachines | /usr/bin/jq ".virtualmachine[].displayname"  | /bin/grep -v 'null' | /bin/sed 's/\"//g' | /bin/grep "${instance_type}\b" 2>/dev/null
fi
if ( [ "${cloudhost}" = "linode" ] )
then
    /usr/local/bin/linode-cli linodes list --text | /bin/grep "${instance_type}"
fi
if ( [ "${cloudhost}" = "vultr" ] )
then
    BUILD_HOME="`/usr/bin/pwd | /bin/sed 's/agile-infrastructure-build-client-scripts.*/agile-infrastructure-build-client-scripts/g'`"    
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
    /bin/sleep 1
    #Clonk
    #/usr/bin/vultr server list | /bin/grep "${instance_type}"
    #Official
    /usr/bin/vultr instance list | /bin/grep "${instance_type}"
fi

if ( [ "${cloudhost}" = "aws" ] )
then
    /usr/bin/aws ec2 describe-instances --filters "Name=tag:descriptiveName,Values=*${instance_type}*" "Name=instance-state-name,Values=running" | /usr/bin/jq '.Reservations[].Instances[] | .InstanceId'
fi


