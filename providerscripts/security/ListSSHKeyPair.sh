#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will list the ssh key pairs
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
###################################################################################
###################################################################################
#set -x

key_name="${1}"
cloudhost="${2}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    :
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
    /usr/local/bin/cs listSSHKeyPair | /usr/bin/jq '.sshkeypair[].name' | /bin/grep "${key_name}"
fi

if ( [ "${cloudhost}" = "linode" ] )
then
    /usr/local/bin/linode-cli --text sshkeys list | /bin/grep "${key_name}"
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
    /bin/sleep 1
    #Clonk
    #/usr/bin/vultr sshkey list | /bin/grep "${key_name}" | /usr/bin/awk '{print $NF}'
    #Official
    /usr/bin/vultr ssh-key list | /bin/grep "${key_name}" | /usr/bin/awk '{print $NF}'
fi

if ( [ "${cloudhost}" = "aws" ] )
then
    :
fi

