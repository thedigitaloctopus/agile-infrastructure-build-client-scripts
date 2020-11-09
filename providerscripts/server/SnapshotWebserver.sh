#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/06/2016
# Description : This script will create a snapshot of a webserver
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
set -x

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
    webserver_id="`/usr/local/bin/doctl compute droplet list | /bin/grep webserver | /usr/bin/awk '{print $1}'`"
    webserver_name="`/usr/local/bin/doctl compute droplet list | /bin/grep webserver | /usr/bin/awk '{print $2}'`"
    status ""
    status "########################SNAPSHOTING YOUR WEBSERVER####################################"
    status ""
    /usr/local/bin/doctl compute droplet-action snapshot --snapshot-name "${webserver_name}" ${webserver_id}
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
    webserver_id="`/usr/local/bin/linode-cli --text linodes list | /bin/grep webserver | /usr/bin/awk '{print $1}'`"
    webserver_name="`/usr/local/bin/linode-cli --text linodes list | /bin/grep webserver | /usr/bin/awk '{print $2}'`"
    disk_id="`/usr/local/bin/linode-cli --text linodes disks-list ${webserver_id} | /bin/grep -v swap | /bin/grep -v id | /usr/bin/awk '{print $1}'`"
    status ""
    status "########################SNAPSHOTING YOUR WEBSERVER####################################"
    status ""
    /usr/local/bin/linode-cli images create --disk_id ${disk_id} --label ${webserver_name}
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN`"
    SUBID="`/usr/bin/vultr servers | /bin/grep 'webserver' | /usr/bin/awk '{print $1}'`"

    status ""
    status "########################SNAPSHOTING YOUR WEBSERVER IN THE BACKGROUND####################################"
    status ""

    /usr/bin/vultr snapshot create "${SUBID}" -d "webserver-${SERVER_USER}"
    /bin/touch ${HOME}/.ssh/SNAPSHOT:${SUBID}
fi
if ( [ "${CLOUDHOST}" = "aws" ] )
then
    
    status ""
    status "########################SNAPSHOTING YOUR WEBSERVER IN THE BACKGROUND####################################"
    status ""
    
    instance_id="`/usr/bin/aws ec2 describe-instances --filter "Name=tag:descriptiveName,Values=webserver*" "Name=instance-state-name,Values=running" | /usr/bin/jq ".Reservations[].Instances[].InstanceId" | /bin/sed 's/\"//g'`"
    /usr/bin/aws ec2 create-image --instance-id ${instance_id} --name "webserver-${SERVER_USER}"
fi

