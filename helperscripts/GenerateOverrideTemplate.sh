#!/bin/sh

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
    overridescript="../templatedconfigurations/templateoverrides/linode/OverrideScript.sh"
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
