#!/bin/sh
###################################################################################
# Description : This script lets the deployer choose a template to deploy from.
# There are various default templates and those with the skill can craft their own.
# Author: Peter Winter
# Date  : 13/07/2020
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
####################################################################################
####################################################################################

if ( [ "${SELECTED_TEMPLATE}" = "" ] )
then
    status ""
    status "I have the following templates available for ${CLOUDHOST}"
    status ""
    numberoftemplates="`/bin/ls -l ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/*.tmpl | /usr/bin/wc -l`"
    if ( [ "${numberoftemplates}" = "0" ] )
    then
        status "There are no templates available, cannot build using this method, please use the ${BUILD_HOME}/AgileDeploymentToolkit.sh method to build for this cloudhost"
        status "Terminating this attempt...."
        exit
    fi
    status "######################################################################"
    status "There are ${numberoftemplates} available template(s) for ${CLOUDHOST}"
    status "######################################################################"
    status "" 
    status "You can use one of these default templates or you can make your own and place it in the ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST} directory"
    status "with the nomenclature, ${CLOUDHOST}[templatenumber].tmpl"
    status "" 
    status "#############AVAILABLE TEMPLATES#####################"

    /bin/ls -l ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST} | /bin/grep ".tmpl$" | /usr/bin/awk '{print NR  "> " $s}' | /usr/bin/awk '{print $NF}' > /tmp/templates

    /usr/bin/sort -V -o /tmp/sortedtemplates /tmp/templates

    templateid="1"
    status "You can edit these templates directly if you wish to alter the configurations"
    for template in `/bin/cat /tmp/sortedtemplates`
    do
        status "###############################################################################################################"
        status "Template ID ${templateid}: ${template}"
        status "-----------------------------------------"
        templatebasename="`/bin/echo ${template} | /bin/sed 's/\.tmpl//g'`"
        templatefile="${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/${templatebasename}.tmpl"
        templatedescription="`/bin/cat ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/${templatebasename}.description`"
        status ""
        status "Template File: ${templatefile}"
        status ""
        status "Description: ${templatedescription}"
        status ""
        status "Press the <enter> key to see the next template or enter the template ID to select the template"
        read response

        while ( [ "${response}" != "${templateid}" ]  && [ "${response}" != "" ] )
        do
            status "Sorry, that's not a valid input, try again..."
            read response
        done

        chosen="0"

        if ( [ "${response}" = "${templateid}" ] )
        then
           chosen="1"
           selectedtemplate=${templateid}
           break
        fi

        templateid="`/usr/bin/expr ${templateid} + 1`"
    done 

    if ( [ "${chosen}" = "0" ] )
    then
        status "#############AVAILABLE TEMPLATES#####################"
        status "Please enter a template number between 1 and ${numberoftemplates} to select the template that you want to use for the build process"
        read response
        wrong="1"
        selectedtemplate="0"
        while ( [ "${wrong}" = "1" ] )
        do
            if ( [ -n "${response}" ] && [ "${response}" -eq "${response}" ] 2>/dev/null )
            then
                if ( [ "${response}" -lt "1" ] || [ "${response}" -gt "${numberoftemplates}" ] )
                then
                    wrong="1"
                else
                    wrong="0"
                    selectedtemplate="${response}"
                fi
            fi
            if ( [ "${wrong}" = "1" ] )
            then
                status "Sorry, that's not a valid template number. Please enter a number between 1 and ${numberoftemplates}"
                read response
            fi
        done
    fi
    status "You have selected template: ${selectedtemplate}"
    status "Press <enter> to continue"
    read x
else
    selectedtemplate="${SELECTED_TEMPLATE}"
fi

templatefile="${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/${CLOUDHOST}${selectedtemplate}.tmpl"

/bin/sed -i '/^$/d' ${templatefile}

/bin/sed -i '/BUILD_HOME=/d' ${templatefile}
/bin/echo "export BUILD_HOME=\"${BUILD_HOME}\"" >> ${templatefile}

/bin/sed -i '/BUILD_CLIENT_IP=/d' ${templatefile}
/bin/echo "export BUILD_CLIENT_IP=\"${BUILD_CLIENT_IP}\"" >> ${templatefile}

/bin/sed -i '/BUILD_IDENTIFIER=/d' ${templatefile}
/bin/echo "export BUILD_IDENTIFIER=\"${BUILD_IDENTIFIER}\"" >> ${templatefile}

#load the environment from the template file
. ${templatefile}
. ${BUILD_HOME}/templatedconfigurations/ValidateDefaultUser.sh

#Take care of special case when a space is input in the website display name
export WEBSITE_DISPLAY_NAME="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed "s/'//g" | /bin/sed 's/ /_/g'`"


#If the application repository token is set, override any password that has been set
if ( [ "${APPLICATION_REPOSITORY_TOKEN}" != "" ] )
then
    export APPLICATION_REPOSITORY_PASSWORD="${APPLICATION_REPOSITORY_TOKEN}"
fi

#Make it live
/bin/cp ${templatefile} ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}

. ${BUILD_HOME}/providerscripts/cloudhost/ValidateProviderAuthorisation.sh
