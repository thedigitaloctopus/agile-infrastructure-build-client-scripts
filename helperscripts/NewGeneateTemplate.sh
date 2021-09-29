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

if ( [ ! -f  ./helperscripts/GenerateOverrideTemplate.sh ] )
then
    /bin/echo "Sorry, this script has to be run as ./helperscripts/GenerateOverrideTemplate.sh"
    exit
fi

BUILD_HOME="`/bin/pwd`"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr 5)AWS. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
    CLOUDHOST="digitalocean"
    overridescript="${BUILD_HOME}/templatedconfigurations/templateoverrides/digitalocean/OverrideScript.sh"
elif ( [ "${response}" = "2" ] )
then
    CLOUDHOST="exoscale"
    /bin/echo "Please tell us which template you wish to override"
    no_templates="`/usr/bin/wc -l ${BUILD_HOME}/templatedconfigurations/templates/exoscale/templatemenu.md | /usr/bin/awk '{print $1}'`"
    /bin/cat ${BUILD_HOME}/templatedconfigurations/templates/exoscale/templatemenu.md
    /bin/echo "Please input a number between 1 and ${no_templates} to select a template to override"
    read choice
    if ( [ "${choice}" -gt "0" ] && [ "${choice}" -le "${no_templates}" ] )
    then 
       template="${choice}"
    else
        /bin/echo "Invalid input...exiting"
        exit
    fi
    overridescript="${BUILD_HOME}/templatedconfigurations/templates/exoscale/exoscale${template}.tmpl"
elif ( [ "${response}" = "3" ] )
then
    CLOUDHOST="linode"
    overridescript="${BUILD_HOME}/templatedconfigurations/templateoverrides/linode/OverrideScript.sh"
elif ( [ "${response}" = "4" ] )
then
    CLOUDHOST="vultr"
    overridescript="${BUILD_HOME}/templatedconfigurations/templateoverrides/vultr/OverrideScript.sh"
elif ( [ "${response}" = "5" ] )
then
    CLOUDHOST="aws"
    overridescript="${BUILD_HOME}/templatedconfigurations/templateoverrides/aws/OverrideScript.sh"
else
    /bin/echo "Unrecognised  cloudhost. Exiting ...."
    exit
fi

/bin/cp ${overridescript} ${overridescript}.$$

variables="`/bin/grep 'export ' ${overridescript}.$$ | /usr/bin/awk -F'=' '{print $1}' | /bin/sed 's/export//g'`"

for livevariable in ${variables}
do
    #livevariable="`/bin/grep -v export ${variable} | /bin/sed '/^$/d'`"
    #echo "XXX${livevariable}XXX"
    #read x
    /bin/echo ""
    /bin/echo "############################################################################################"
    /bin/echo "Explanation from the specification regarding this variable:"
    /bin/echo "############################################################################################"
    /bin/sed "/### ${livevariable}/,/----/!d;/----/q" ${BUILD_HOME}/templatedconfigurations/specification.md
    /bin/echo "Found a variable ${livevariable} what do you want to set it to?"
    value="`/bin/grep "${livevariable}=" ${overridescript} | /usr/bin/awk -F'"' '{print $2}'`"
    /bin/echo "Its current value is \"${value}\" press <enter> to retain, anything else to override"
    read setting
    /bin/echo "OK, thanks..."
    if ( [ "${setting}" != "" ] )
    then
        /bin/sed -i "/${livevariable}=/d" ${overridescript}.$$
        /bin/sed -i "/BASE OVERRIDES/a export ${livevariable}=\"${setting}\"" ${overridescript}.$$
    fi
done


/bin/echo "I am about to display your modified template override init script which you can use on your ${CLOUDHOST} compute instance"
/bin/echo "You should take a copy of this using copy and paste, it will not be shown again"
/bin/echo "Press <enter> when you are ready for it to be displayed"
/bin/echo "################################################################################################################################"
read x
/bin/cat ${overridescript}.$$
/bin/rm ${overridescript}.$$
