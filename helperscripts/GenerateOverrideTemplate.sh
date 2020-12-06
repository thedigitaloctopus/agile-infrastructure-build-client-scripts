#!/bin/sh
#######################################################################################################
# Author : Peter Winter
# Date   : 06/12/2020
# Description : With this script you can generate your template overrides init script interactively 
# rather than having to edit the template overrides file directly. Once this script has run, you can
# copy the scipt output into the userdata part of your build compute instance for your provider and it
# will spin up all the infrastructure for your build. 
#######################################################################################################
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

if ( [ ! -f  ./GenerateOverrideTemplate.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

export BUILD_HOME="`/bin/cat ../buildconfiguration/buildhome`"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr 5)AWS. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
    CLOUDHOST="digitalocean"
    overridescript="../templatedconfigurations/templateoverrides/digitalocean/OverrideScript.sh"
elif ( [ "${response}" = "2" ] )
then
    CLOUDHOST="exoscale"
    overridescript="../templatedconfigurations/templateoverrides/exoscale/OverrideScript.sh"
elif ( [ "${response}" = "3" ] )
then
    CLOUDHOST="linode"
    /bin/echo "Sorry, this script doesn't work for linode, you will have to edit your overrides script manually"
    /bin/echo "You can find your overrides script at: ../templatedconfigurations/templateoverrides/exoscale/OverrideScript.sh"
    exit
elif ( [ "${response}" = "4" ] )
then
    CLOUDHOST="vultr"
    overridescript="../templatedconfigurations/templateoverrides/vultr/OverrideScript.sh"
elif ( [ "${response}" = "5" ] )
then
    CLOUDHOST="aws"
    overridescript="../templatedconfigurations/templateoverrides/aws/OverrideScript.sh"
else
    /bin/echo "Unrecognised  cloudhost. Exiting ...."
    exit
fi

/bin/cp ${overridescript} ${overridescript}.$$

variables="`/bin/cat ${overridescript}.$$ | /bin/grep '^export ' | /usr/bin/awk -F'=' '{print $1}'`"

for variable in ${variables}
do
    livevariable="`/bin/echo ${variable} | /bin/grep -v export  | /bin/sed '/^$/d'`"
    if ( [ "${livevariable}" != "" ] )
    then
        /bin/echo "Found a variable ${livevariable} what do you want to set it to?"
        read setting
        /bin/echo "OK, thanks..."
        /bin/sed -i "/${livevariable}=/d" ${overridescript}.$$
        /bin/sed -i "/BASE OVERRIDES/a export ${livevariable}=\"${setting}\"" ${overridescript}.$$
    fi
done

/bin/echo "Please tell us and set any additional variables you want to set, type 'none' or 'NONE' when done"

while ( [ 1 ] )
do
    /bin/echo "Please tell us the name of the variable you want to add, for example, DNS_USERNAME, type 'none' if all set"
    read variablename
    
    if ( [ "${variablename}" = "none" ] || [ "${variablename}" = "NONE" ] )
    then
        break
    fi
    
    /bin/echo "Please tell us the value of the variable you want to add, for example, testemail@test.com"
    read variablevalue

    /bin/sed -i "/${variablename}=/d" ${overridescript}.$$
    /bin/sed -i "/ADDITIONAL OVERRIDES/a export ${variablename}=\"${variablevalue}\"" ${overridescript}.$$
done

/bin/echo "I am about to display your modified template override init script which you can use on your ${CLOUDHOST} compute instance"
/bin/echo "You should take a copy of this using copy and paste, it will not be shown again"
/bin/echo "Press <enter> when you are ready for it to be displayed"
/bin/echo"################################################################################################################################"
read x
/bin/cat ${overridescript}.$$
/bin/rm ${overridescript}.$$
