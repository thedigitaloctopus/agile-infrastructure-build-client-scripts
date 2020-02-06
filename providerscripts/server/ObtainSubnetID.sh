#!/bin/sh
############################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : For providers with subnets, this will obtain the subnet ID
############################################################################################
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
##########################################################################################
##########################################################################################
#set -x

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
    :
fi
if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
    :
fi
if ( [ "${CLOUDHOST}" = "linode" ] )
then
    :
fi
if ( [ "${CLOUDHOST}" = "vultr" ] )
then
    :
fi
if ( [ "${CLOUDHOST}" = "aws" ] )
then
    status ""
    status ""
    status "############################################################################################################"
    status "AWS makes use of subnets. As such we need to select a subnet to use. Please answer the following questions:"
    status "Note: The subnet needs to be in the same VPC as the security group that you set for your EC2 instances"
    status "############################################################################################################"
    status ""

    export SUBNET_ID="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} | /bin/grep "SUBNET_ID" | /usr/bin/awk -F'=' '{print $NF}' | /usr/bin/tr -d '"'`"
    if ( [ "${SUBNET_ID}" != "" ] )
    then
        status "Found a Subnet ID which is set to : ${SUBNET_ID}"
        status "Is this correct (Y|N)?"
        read answer
        if ( [ "${answer}" = "N" ] || [ "${answer}" = "n" ] )
        then
            status "Please enter a subnet ID to use. Your available regions and subnets are:"
            status "REGIONS    SUBNETS"
            /usr/bin/aws ec2 describe-subnets | /usr/bin/jq '.Subnets[] | .AvailabilityZone + " " + .SubnetId' >&3
            read subnet_id
            export SUBNET_ID=${subnet_id}
        fi
    else
        status "Please enter a subnet ID to use. Your available regions and subnets are:"
        status "REGIONS    SUBNETS"
        /usr/bin/aws ec2 describe-subnets | /usr/bin/jq '.Subnets[] | .AvailabilityZone + " " + .SubnetId' >&3
        read subnet_id        
        export SUBNET_ID=${subnet_id}
    fi

    /bin/sed -i '/SUBNET_ID=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
    /bin/echo "export SUBNET_ID=\"${SUBNET_ID}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
fi
