#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/06/2016
# Description : This script will create a snapshot of the autoscaler
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

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
    autoscaler_id="`/usr/local/bin/doctl compute droplet list | /bin/grep autoscaler | /usr/bin/awk '{print $1}'`"
    autoscaler_name="`/usr/local/bin/doctl compute droplet list | /bin/grep autoscaler | /usr/bin/awk '{print $2}'`"
    status ""
    status "########################SNAPSHOTING YOUR AUTOSCALER####################################"
    status ""
    /usr/local/bin/doctl compute droplet-action snapshot --snapshot-name "${autoscaler_name}" ${autoscaler_id}
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then

    if ( [ "${REGION_ID}" = "1128bd56-b4d9-4ac6-a7b9-c715b187ce11" ] ) 
    then 
        region_id="ch-gva-2" 
    fi 
    if ( [ "${REGION_ID}" = "91e5e9e4-c9ed-4b76-bee4-427004b3baf9" ] ) 
    then 
        region_id="ch-dk-2" 
    fi 
    if ( [ "${REGION_ID}" = "4da1b188-dcd6-4ff5-b7fd-bde984055548" ] ) 
    then 
        region_id="at-vie-1" 
    fi 
    if ( [ "${REGION_ID}" = "35eb7739-d19e-45f7-a581-4687c54d6d02" ] ) 
    then 
        region_id="de-fra-1" 
    fi 
    if ( [ "${REGION_ID}" = "70e5f8b1-0b2c-4457-a5e0-88bcf1f3db68" ] ) 
    then 
        region_id="bg-sof-1" 
    fi 
    if ( [ "${REGION_ID}" = "85664334-0fd5-47bd-94a1-b4f40b1d2eb7" ] ) 
    then 
        region_id="de-muc-1" 
    fi 
    
    status ""
    status "########################SNAPSHOTING YOUR AUTOSCALER IN THE BACKGROUND####################################"
    status ""

    autoscaler_id="`/usr/local/bin/cs listVirtualMachines | /usr/bin/jq --arg tmp_display_name "${autoscaler_name}" '(.virtualmachine[] | select(.displayname | contains($tmp_display_name)) | .id)' | /bin/sed 's/"//g'`"
    /usr/bin/exo compute instance snapshot create -z ${region_id} ${autoscaler_id}
    snapshot_id="`/usr/bin/exo -O json  compute instance snapshot list  | /usr/bin/jq --arg tmp_instance_name "${autoscaler_name}" '(.[] | select (.instance | contains($tmp_instance_name)) | .id)' | /bin/sed 's/"//g'`"
    /usr/bin/exo compute instance-template register --boot-mode legacy --disable-password --from-snapshot ${snapshot_id} --zone ${region_id} --username ${DEFAULT_USER} ${autoscaler_name} 
    
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
    autoscaler_id="`/usr/local/bin/linode-cli --text linodes list | /bin/grep autoscaler | /usr/bin/awk '{print $1}'`"
    autoscaler_name="`/usr/local/bin/linode-cli --text linodes list | /bin/grep autoscaler | /usr/bin/awk '{print $2}'`"
    disk_id="`/usr/local/bin/linode-cli --text linodes disks-list ${autoscaler_id} | /bin/grep -v swap | /bin/grep -v id | /usr/bin/awk '{print $1}'`"
    status ""
    status "########################SNAPSHOTING YOUR AUTOSCALER####################################"
    status ""
    /usr/local/bin/linode-cli images create --disk_id ${disk_id} --label ${autoscaler_name}
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN`"
    
   # Clonk
   # SUBID="`/usr/bin/vultr servers | /bin/grep 'autoscaler' | /usr/bin/awk '{print $1}'`"
   #
   # status ""
   # status "########################SNAPSHOTING YOUR AUTOSCALER IN THE BACKGROUND####################################"
   # status ""

   # /usr/bin/vultr snapshot create "${SUBID}" -d "autoscaler-${SERVER_USER}"
   # /bin/touch ${HOME}/.ssh/SNAPSHOT:${SUBID}
    
    #Official 
    SUBID="`/usr/bin/vultr instance list | /bin/grep autoscaler | /usr/bin/awk '{print $1}'`"
    status ""
    status "########################SNAPSHOTING YOUR AUTOSCALER IN THE BACKGROUND####################################"
    status ""
    /usr/bin/vultr snapshot create -i ${SUBID} -d "autoscaler-${SERVER_USER}"
    /bin/touch ${HOME}/.ssh/SNAPSHOT:${SUBID}
fi
if ( [ "${CLOUDHOST}" = "aws" ] )
then
    
    status ""
    status "########################SNAPSHOTING YOUR AUTOSCALER IN THE BACKGROUND####################################"
    status ""
    
    instance_id="`/usr/bin/aws ec2 describe-instances --filter "Name=tag:descriptiveName,Values=*autoscaler*" "Name=instance-state-name,Values=running" | /usr/bin/jq ".Reservations[].Instances[].InstanceId" | /bin/sed 's/\"//g'`"
    /usr/bin/aws ec2 create-image --instance-id ${instance_id} --name "autoscaler-${SERVER_USER}"
fi

