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
    if ( [ "${OSTYPE}" != "" ] )
    then
        /bin/echo "${OSTYPE}"
elif ( [ "${buildos}" = "ubuntu" ] )
    then
        if ( [ "${buildosversion}" = "18.04" ] )
        then
            /bin/echo "The default AMI for ubuntu 18.04 is in the EU-WEST-1 region, if you wish to use a different AMI in a different region, please provide the AMI identifier here" >&3
            /bin/echo "It will be of the format ami-xxxxxxxxxxxxxxx and you can find it through the AWS gui system" >&3
            /bin/echo "Do you wish to use the default AMI for ubuntu 18.04? (Y|N)" >&3
            read answer
            if ( [ "${answer}" = "Y" ] || [ "${answer}" = "y" ] )
            then
                /bin/cp /dev/null /dev/stdout
                /bin/echo "ami-0caa6a2dc87f66216"
            else
                /bin/echo "OK, please enter your prefered AMI identifier" >&3
                read ami-identifier
                /bin/cp /dev/null /dev/stdout
                /bin/echo "${ami-identifier}"
            fi
        fi

        if ( [ "${buildosversion}" = "19.04" ] )
        then
            /bin/echo "The default AMI for ubuntu 19.04 is in the EU-WEST-1 region, if you wish to use a different AMI in a different region, please provide the AMI identifier here" >&3
            /bin/echo "It will be of the format ami-xxxxxxxxxxxxxxx and you can find it through the AWS gui system" >&3
            /bin/echo "Do you wish to use the default AMI for ubuntu 19.04? (Y|N)" >&3
            read answer
            if ( [ "${answer}" = "Y" ] || [ "${answer}" = "y" ] )
            then
                /bin/cp /dev/null /dev/stdout
                /bin/echo "ami-0405da8f658d2cff5"
            else
                /bin/echo "OK, please enter your prefered AMI identifier" >&3
                read ami-identifier
                /bin/cp /dev/null /dev/stdout
                /bin/echo "${ami-identifier}"
            fi
        fi
elif ( [ "${buildos}" = "debian" ] )
    then
        if ( [ "${buildosversion}" = "9" ] )
        then
            /usr/bin/aws ec2 describe-images --owners 379101102735 | /usr/bin/jq '.Images[] | .ImageId + " " + .Name' | /bin/grep stretch | /bin/grep 2019 | /bin/grep x86_64 >&3
            /bin/echo "Please enter the ami identifier for the OS you wish to use" >&3
            read ami_identifier        
            /bin/cp /dev/null /dev/stdout
            /bin/echo "${ami_identifier}"
        fi
        if ( [ "${buildosversion}" = "10" ] )
        then
            #There is no debian 10 ami image yet, so just set it to be debian 9 until debian 10 becomes available when we will update here
            #/usr/bin/aws ec2 describe-images --owners 379101102735 | /usr/bin/jq '.Images[] | .ImageId + " " + .Name' | /bin/grep buster | /bin/grep 2019 | /bin/grep x86_64 >&3
            #/bin/echo "Please enter the ami identifier for the OS you wish to use" >&3

            #read ami_identifier
            #/bin/cp /dev/null /dev/stdout
            #/bin/echo "${ami_identifier}"
            /bin/echo "There are no debian 10 buster ami images available at the moment, you will need to rebuild selecting debian 9 stretch as your OS" >&3
            /bin/echo "<ctrl-c> to exit" >&3
            read x
        fi
    fi
fi



