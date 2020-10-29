#!/bin/sh

set -x


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

templates="`/bin/ls -l ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST} | /bin/grep ".tmpl$" | /usr/bin/awk '{print NR  "> " $s}' | /usr/bin/awk '{print $NF}'`"
templateid="1"
status "You can edit these templates directly if you wish to alter the configurations"
for template in ${templates}
do
    status "###############################################################################################################"
    status "Template ID ${templateid}: ${template}"
    templatebasename="`/bin/echo ${template} | /bin/sed 's/\.tmpl//g'`"
    templatefile="${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/${templatebasename}.tmpl"
    templatedescription="`/bin/cat ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/${templatebasename}.description`"
    status ""
    status "Template File: ${templatefile}"
    status ""
    status "Description: ${templatedescription}"
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

templatefile="${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/${CLOUDHOST}${selectedtemplate}.tmpl"

/bin/sed -i '/^$/d' ${templatefile}

/bin/sed -i '/BUILD_HOME=/d' ${templatefile}
/bin/echo "export BUILD_HOME=\"${BUILD_HOME}\"" >> ${templatefile}

/bin/sed -i '/BUILD_CLIENT_IP=/d' ${templatefile}
/bin/echo "export BUILD_CLIENT_IP=\"${BUILD_CLIENT_IP}\"" >> ${templatefile}

/bin/sed -i '/BUILD_IDENTIFIER=/d' ${templatefile}
/bin/echo "export BUILD_IDENTIFIER=\"${BUILD_IDENTIFIER}\"" >> ${templatefile}

#load the environment from the template file
export . ${templatefile}

#Make it live
/bin/cp ${templatefile} ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}

. ${BUILD_HOME}/providerscripts/cloudhost/ValidateProviderAuthorisation.sh
