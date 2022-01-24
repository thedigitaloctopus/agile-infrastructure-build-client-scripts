#!/bin/sh
########################################################################################################
# Author: Peter Winter
# Date  : 13/01/2022
# Description : You can grant laptop ip addresses access to your build machine using this script.
# The firewall of your build machine will allow SSH connections from the ip address that you provide
########################################################################################################
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
#######################################################################################################
#set -x

if ( [ ! -f  ./AllowLaptopIP.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr 5)AWS. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
    CLOUDHOST="digitalocean"
    token_to_match="*autoscaler*"
elif ( [ "${response}" = "2" ] )
then
    CLOUDHOST="exoscale"
    token_to_match="autoscaler"
elif ( [ "${response}" = "3" ] )
then
    CLOUDHOST="linode"
    token_to_match="*autoscaler*"
elif ( [ "${response}" = "4" ] )
then
    CLOUDHOST="vultr"
    token_to_match="*autoscaler*"
elif ( [ "${response}" = "5" ] )
then
    CLOUDHOST="aws"
    token_to_match="*autoscaler*"
else
    /bin/echo "Unrecognised  cloudhost. Exiting ...."
    exit
fi

export BUILD_HOME="`/bin/pwd | /bin/sed 's/\/helper.*//g'`"

/bin/echo "What is the build identifier you want to allow access for?"
/bin/echo "You have these builds to choose from: "
/bin/ls ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} | /bin/grep -v 'credentials'
/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

/bin/echo "Please enter the IP address you are modifying access for. You can find the ip address of your laptop using: www.whatsmyip.com"
read ip

/bin/echo "Do you want to add or remove access for this ip address?"
/bin/echo "1) Add  2) Remove"
read mode

while ( [ "`/bin/echo "1 2" | /bin/grep ${mode}`" = "" ] )
do
    /bin/echo "I don't recognise that input..."
    /bin/echo "Please enter 1 or 2"
    read mode
done

/usr/bin/s3cmd --force get s3://authip-${BUILD_IDENTIFIER}/authorised-ips.dat

if ( [ ! ./authorised-ips.dat ] )
then
    /bin/echo "Failed to get a list of authorised ips, you might have to look into a manual update"
    exit
fi

if ( [ "${mode}" = "1" ] )
then
    /bin/echo ${ip} >> ./authorised-ips.dat
else
    /bin/sed -i "/${ip}/d" ./authorised-ips.dat
fi

/bin/cat ./authorised-ips.dat | /usr/bin/sort | /usr/bin/uniq >> ./authorised-ips.dat.$$

/bin/mv ./authorised-ips.dat.$$ ./authorised-ips.dat

/usr/bin/s3cmd put ./authorised-ips.dat s3://authip-${BUILD_IDENTIFIER}

/bin/touch  ./FIREWALL-EVENT

/usr/bin/s3cmd put ./FIREWALL-EVENT s3://authip-${BUILD_IDENTIFIER}

/bin/rm ./authorised-ips.dat ./FIREWALL-EVENT
