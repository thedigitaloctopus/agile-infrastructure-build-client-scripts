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

/bin/echo "############################################################################################################"
/bin/echo "WARNING: THERE IS NO SANITY CHECKING IF YOU USE THIS SCRIPT WHICH MEANS THAT IF YOU ENTER ANYTHING INCORRECT"
/bin/echo "YOU WON'T FIND OUT ABOUT IT UNTIL YOU CONFIGURE A BUILD USING THE OUTPUT FROM THIS SCRIPT AND THE BUILD FAILS"
/bin/echo "AT THE END, THIS SCRIPT WILL OUTPUT ITS CONFIGURATION AND YOU CAN TAKE A COPY OF THE OUTPUT AND STORE IT ON YOUR LAPTOP OR DESKTOP"
/bin/echo "FOR USE IN CURRENT AND FUTURE DEPLOYMENTS"
/bin/echo "BE AWARE THAT THE OUTPUT GENERATED WILL CONTAIN SENSITIVE INFORMATION WHICH YOU NEED TO KEEP SECURE"
/bin/echo "############################################################################################################"
/bin/echo "Press <enter> to continue"
read x
 
BUILD_HOME="`/bin/pwd`"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr 5)AWS. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
    CLOUDHOST="digitalocean"
elif ( [ "${response}" = "2" ] )
then
    CLOUDHOST="exoscale"
elif ( [ "${response}" = "3" ] )
then
    CLOUDHOST="linode"
elif ( [ "${response}" = "4" ] )
then
    CLOUDHOST="vultr"
elif ( [ "${response}" = "5" ] )
then
    CLOUDHOST="aws"
else
    /bin/echo "Unrecognised  cloudhost. Exiting ...."
    exit
fi

/bin/echo "Please tell us which template you wish to override"
no_templates="`/usr/bin/wc -l ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/templatemenu.md | /usr/bin/awk '{print $1}'`"
/bin/cat ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/templatemenu.md
/bin/echo "Please input a number between 1 and ${no_templates} to select a template to override"
read choice
if ( [ "${choice}" -gt "0" ] && [ "${choice}" -le "${no_templates}" ] )
then 
   template="${choice}"
else
    /bin/echo "Invalid input...exiting"
    exit
fi
overridescript="${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/${CLOUDHOST}${template}.tmpl"

newoverridescript="/tmp/${CLOUDHOST}${template}"

/bin/cp ${overridescript} ${newoverridescript}

variables="`/bin/grep 'export ' ${newoverridescript} | /usr/bin/awk -F'=' '{print $1}' | /bin/sed 's/export//g'`"

essential="1"
/bin/echo "Do you want to review every single variable it is possible to set or do you only want to review the essential variables (recommended)"
/bin/echo "Enter 'Y' or 'y' to review every variable. Press <enter> to only review the essential ones"
read response
if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
then
   essential="0"
fi

for livevariable in ${variables}
do
    value="`/bin/grep "${livevariable}=" ${overridescript} | /usr/bin/awk -F'"' '{print $2}'`"

    if ( ( [ "${essential}" = "0" ] ) || ( [ "`/bin/grep 'MANDATORY' ${overridescript} | /bin/grep "export ${livevariable}="`" != "" ] || [ "${value}" != "" ] ) )
    then
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
            /bin/sed -i "s/${livevariable}=.*/${livevariable}=\"$setting\"/g" ${newoverridescriptt}
        fi
    fi
done

/bin/echo "/bin/sh ${BUILD_HOME}/HardcoreADTWrapper.sh" >> ${newoverridescript}

if ( [ ! -d ${BUILD_HOME}/overridescripts ] )
then
    /bin/mkdir ${BUILD_HOME}/overridescripts
fi

if ( [ -f ${BUILD_HOME}/overridescripts/${newoverridescript} ] )
then
    /bin/mv ${BUILD_HOME}/overridescripts/${newoverridescript} ${BUILD_HOME}/overridescripts/${newoverridescript}.$$
fi

/bin/mv ${newoverridescript} ${BUILD_HOME}/overridescripts


