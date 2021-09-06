#!/bin/sh
######################################################################################################################
# Description: This is the script will get the snapshot IDs that we can build from 
# Author: Peter Winter
# Date: 17/01/2017
######################################################################################################################
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
#######################################################################################################
######################################################################################################
#set -x

SNAPSHOT_ID="`/bin/echo ${autoscaler_name} | grep -aoE -e '[A-Z]{4}'`"

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
    WEBSERVER_SNAPSHOT_NAME="`/usr/local/bin/doctl compute snapshot list | /bin/grep webserver | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $2}'`"
    WEBSERVER_IMAGE_ID="`/usr/local/bin/doctl compute snapshot list | /bin/grep webserver | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $1}'`"
    AUTOSCALER_IMAGE_ID="`/usr/local/bin/doctl compute snapshot list | /bin/grep autoscaler | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $1}'`"
    DATABASE_IMAGE_ID="`/usr/local/bin/doctl compute snapshot list | /bin/grep database | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $1}'`"
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
    
    zone=${region_id}
    
    WEBSERVER_SNAPSHOT_NAME="`/usr/bin/exo -O json vm template list --mine --zone ${zone} | /usr/bin/jq --arg tmp_instance_name "${SNAPSHOT_ID}" '(.[] | select (.name | contains("webserver")  and  contains($tmp_instance_name)) | .name)' | /bin/sed 's/"//g'`"
    AUTOSCALER_IMAGE_ID="`/usr/bin/exo -O json vm template list --mine --zone ${zone} | /usr/bin/jq --arg tmp_instance_name "${SNAPSHOT_ID}" '(.[] | select (.name | contains("autoscaler")  and  contains($tmp_instance_name)) | .id)' | /bin/sed 's/"//g'`"
    WEBSERVER_IMAGE_ID="`/usr/bin/exo -O json vm template list --mine --zone ${zone} | /usr/bin/jq --arg tmp_instance_name "${SNAPSHOT_ID}" '(.[] | select (.name | contains("webserver")  and  contains($tmp_instance_name)) | .id)' | /bin/sed 's/"//g'`"
    DATABASE_IMAGE_ID="`/usr/bin/exo -O json vm template list --mine --zone ${zone} | /usr/bin/jq --arg tmp_instance_name "${SNAPSHOT_ID}" '(.[] | select (.name | contains("database")  and  contains($tmp_instance_name)) | .id)' | /bin/sed 's/"//g'`"
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
    WEBSERVER_IMAGE_ID="`/usr/local/bin/linode-cli --text images list  | /bin/grep webserver | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $1}'`"
    AUTOSCALER_IMAGE_ID="`/usr/local/bin/linode-cli --text images list  | /bin/grep autoscaler | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $1}'`"
    DATABASE_IMAGE_ID="`/usr/local/bin/linode-cli --text images list  | /bin/grep database | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $1}'`"
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
    WEBSERVER_IMAGE_ID="`/usr/bin/vultr snapshots | /bin/grep webserver | /bin/grep ${SNAPSHOT_ID}  | /usr/bin/awk '{print $1}'`"
    AUTOSCALER_IMAGE_ID="`/usr/bin/vultr snapshots | /bin/grep autoscaler | /bin/grep ${SNAPSHOT_ID}  | /usr/bin/awk '{print $1}'`"
    DATABASE_IMAGE_ID="`/usr/bin/vultr snapshots | /bin/grep database | /bin/grep ${SNAPSHOT_ID}  | /usr/bin/awk '{print $1}'`"
fi

if ( [ "${CLOUDHOST}" = "aws" ] )
then
    WEBSERVER_IMAGE_ID="`/usr/bin/aws ec2 describe-images --owners self --filters \"Name=name,Values=webserver-${SNAPSHOT_ID}*\"  | /usr/bin/jq \".Images[].ImageId\" | /bin/sed 's/\"//g'`"
    AUTOSCALER_IMAGE_ID="`/usr/bin/aws ec2 describe-images --owners self --filters \"Name=name,Values=autoscaler-${SNAPSHOT_ID}*\"  | /usr/bin/jq \".Images[].ImageId\" | /bin/sed 's/\"//g'`"
    DATABASE_IMAGE_ID="`/usr/bin/aws ec2 describe-images --owners self --filters \"Name=name,Values=database-${SNAPSHOT_ID}*\"  | /usr/bin/jq \".Images[].ImageId\" | /bin/sed 's/\"//g'`"
fi        
