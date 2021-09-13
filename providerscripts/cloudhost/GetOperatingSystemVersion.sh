#!/bin/sh
#############################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will get the version of the operating system that we are building for
#############################################################################################
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
############################################################################################
############################################################################################
#set -x

instance_size="${1}"
cloudhost="${2}"
buildos="${3}"
buildosversion="${4}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    if ( [ "${buildos}" = "ubuntu" ] )
    then
        buildosversion="`/bin/echo ${buildosversion} | /bin/sed 's/\./-/g'`"
        /bin/echo "ubuntu-${buildosversion}-x64"
elif ( [ "${buildos}" = "debian" ] )
    then
        /bin/echo "debian-${buildosversion}-x64"
    fi
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
    if ( [ "${buildos}" = "ubuntu" ] )
    then
        /usr/local/bin/cs listTemplates templatefilter=featured | jq ".template[] | select( .displaytext | contains(\"Ubuntu ${buildosversion} LTS 64-bit\")) | .id" | /bin/sed 's/\"//g' | /usr/bin/tail -n -1
        /usr/local/bin/cs listTemplates templatefilter=featured | jq ".template[] | select( .displaytext | contains(\"Ubuntu ${buildosversion} 64-bit\")) | .id" | /bin/sed 's/\"//g' | /usr/bin/tail -n -1
elif ( [ "${buildos}" = "debian" ] )
    then
        /usr/local/bin/cs listTemplates templatefilter=featured | jq ".template[] | select( .displaytext | contains(\"Debian ${buildosversion} 64-bit\")) | .id" | /bin/sed 's/\"//g' | /usr/bin/tail -n -1
        /usr/local/bin/cs listTemplates templatefilter=featured | jq ".template[] | select( .displaytext | contains(\"Debian ${buildosversion} (Buster) 64-bit\")) | .id" | /bin/sed 's/\"//g' | /usr/bin/tail -n -1
        /usr/local/bin/cs listTemplates templatefilter=featured | jq ".template[] | select( .displaytext | contains(\"Debian ${buildosversion} (Bullseye) 64-bit\")) | .id" | /bin/sed 's/\"//g' | /usr/bin/tail -n -1
    fi
fi

if ( [ "${cloudhost}" = "linode" ] )
then
    if ( [ "${buildos}" = "ubuntu" ] )
    then
        /bin/echo "Ubuntu ${buildosversion}"
elif ( [ "${buildos}" = "debian" ] )
    then
        /bin/echo "Debian ${buildosversion}"
    fi
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
    if ( [ "${buildos}" = "ubuntu" ] )
    then
        /bin/echo "Ubuntu ${buildosversion} x64"
elif ( [ "${buildos}" = "debian" ] )
    then
        /bin/echo "Debian ${buildosversion} x64"
    fi
fi

if ( [ "${cloudhost}" = "aws" ] )
then
    if ( [ "${OS_TYPE}" != "" ] )
    then
        /bin/echo "${OS_TYPE}"
elif ( [ "${buildos}" = "ubuntu" ] )
    then
        /bin/echo "################################################################################################################" >&3
        /bin/echo "Please enter the ami in the format ami-xxxxxxxxxxxxxxx that you wish to use for this ubuntu based machine" >&3
        /bin/echo "You can find ami identifiers here: https://cloud-images.ubuntu.com/locator/ec2" >&3
        /bin/echo "You are expecting an installation of ${buildosversion} of ubuntu" >&3
        /bin/echo "Make sure that it supports your intended PHP version (if any) and is in the correct AWS region" >&3
        /bin/echo "################################################################################################################" >&3
        /bin/echo "OK, please enter your prefered AMI identifier" >&3
        read ami_identifier
        /bin/cp /dev/null /dev/stdout
        /bin/echo "${ami_identifier}"
elif ( [ "${buildos}" = "debian" ] )
    then
        if ( [ "${buildosversion}" = "10" ] )
        then
            /usr/bin/aws ec2 describe-images --owners 136693071363 | /usr/bin/jq '.Images[] | .ImageId + " " + .Name' | /bin/grep debian-10 | /bin/grep "2019\|2020\|2021\|2022\|2023" | /bin/sed 's/"//g' >&3
            /bin/echo "Please enter the ami identifier for the OS you wish to use" >&3
            read ami_identifier        
            /bin/cp /dev/null /dev/stdout
            /bin/echo "${ami_identifier}"
        fi
    fi
fi



