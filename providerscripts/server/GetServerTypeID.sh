#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will return the type (size) of the machine to be spun up
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
######################################################################################
######################################################################################
#set -x

server_size="${1}"
server_type="${2}"
cloudhost="${3}"
buildos="${4}"
buildosversion="${5}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    /bin/echo ${server_size}
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
    selection="${server_size}"

    if ( [ "${buildos}" = "ubuntu" ] )
    then
        case ${selection} in
            10G )  serviceofferingid="b6cd1ff5-3a2f-4e9d-a4d1-8988c1191fe8"
                break ;;
            50G )  serviceofferingid="b6e9d1e8-89fc-4db3-aaa4-9b4c5b1d0844"
                break ;;
            100G ) serviceofferingid="c6f99499-7f59-4138-9427-a09db13af2bc"
                break ;;
            200G ) serviceofferingid="350dc5ea-fe6d-42ba-b6c0-efb8b75617ad"
                break ;;
            400G ) serviceofferingid="a216b0d1-370f-4e21-a0eb-3dfc6302b564"
                break ;;
            * ) serviceofferingid="b6cd1ff5-3a2f-4e9d-a4d1-8988c1191fe8"
                break ;;
        esac
elif ( [ "${buildos}" = "debian" ] )
    then
        case ${selection} in
            10G )  serviceofferingid="b6cd1ff5-3a2f-4e9d-a4d1-8988c1191fe8"
                break ;;
            50G )  serviceofferingid="b6e9d1e8-89fc-4db3-aaa4-9b4c5b1d0844"
                break ;;
            100G ) serviceofferingid="c6f99499-7f59-4138-9427-a09db13af2bc"
                break ;;
            200G ) serviceofferingid="350dc5ea-fe6d-42ba-b6c0-efb8b75617ad"
                break ;;
            400G ) serviceofferingid="a216b0d1-370f-4e21-a0eb-3dfc6302b564"
                break ;;
            * ) serviceofferingid="b6cd1ff5-3a2f-4e9d-a4d1-8988c1191fe8"
                break ;;
        esac
    fi
    /bin/echo ${serviceofferingid}
fi


if ( [ "${cloudhost}" = "linode" ] )
then
    /bin/echo ${server_size}
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
    /bin/sleep 1
    #Clonk
    #/usr/bin/vultr plans | grep "${server_size}" | /bin/grep SSD | /usr/bin/awk '{print $1}' | /usr/bin/sort | /usr/bin/tail -1
    #Official
    /usr/bin/vultr plans list | /bin/grep "${server_size}" | /usr/bin/awk '{print $1}'
fi

if ( [ "${cloudhost}" = "aws" ] )
then
    /bin/echo ${server_size}
fi

