if ( [ ! -f ./helperscripts/GenerateHardcoreUserDataScript.sh ] )
then
    /bin/echo "This script needs to be run as ./helperscripts/GenerateHardcoreUserDataScript.sh"
    exit
fi

BUILD_HOME="`/bin/pwd`"

baseoverridescript="${BUILD_HOME}/templatedconfigurations/templateoverrides/OverrideScript.sh"

/bin/echo "Override scripts that you have generated are:"
/bin/echo "#########################################################"
/bin/ls ${BUILD_HOME}/overridescripts/*.tmpl | /usr/bin/awk -F'/' '{print $NF}'
/bin/echo "#########################################################"

/bin/echo "Please enter the exact name of one of them to use it for your user data"
read overridescript

while ( [ ! -f ${BUILD_HOME}/overridescripts/${overridescript} ] )
do
    /bin/echo "I can't seem to find that script, please enter its name again or <ctrl-c> to exit"
    read overridescript
done

/bin/echo "Please enter a discriptive name for your userdata script"
read userdatascript

configurationsettings="${BUILD_HOME}/overridescripts/${overridescript}"
configurationsettings_stack="${BUILD_HOME}/overridescripts/${overridescript}.stack"

/bin/sed -i '/^export/d' ${configurationsettings_stack}

if ( [ ! -d ${BUILD_HOME}/userdatascripts ] )
then
    /bin/mkdir ${BUILD_HOME}/userdatascripts
fi

/bin/cp ${baseoverridescript} ${BUILD_HOME}/userdatascripts/${userdatascript}
/bin/sed 's/\"/\\"/g' ${configurationsettings} > ${configurationsettings}.live
if ( [ "${1}" != "stack" ] )
then
    /bin/sed -i 's/#XXXECHOZZZ/\/bin\/echo \"/g' ${BUILD_HOME}/userdatascripts/${userdatascript}
    /bin/sed -e '/#XXXYYYZZZ/ {' -e "r ${configurationsettings}.live" -e 'd' -e '}' -i ${BUILD_HOME}/userdatascripts/${userdatascript}
    /bin/sed -i 's/#XXXROOTENVZZZ/  \" \>\> \/root\/Environment.env/g' ${BUILD_HOME}/userdatascripts/${userdatascript}
    /bin/sed -e '/#XXXYYYZZZ/ {' -e "r ${configurationsettings}.live" -e 'd' -e '}' -i ${BUILD_HOME}/userdatascripts/${userdatascript}
else
    /bin/sed -e '/#XXXSTACKYYY/ {' -e "r ${configurationsettings_stack}" -e 'd' -e '}' -i ${BUILD_HOME}/userdatascripts/${userdatascript}
fi

/bin/echo "cd agile-infrastructure-build-client-scripts

/bin/sh HardcoreADTWrapper.sh" >> ${BUILD_HOME}/userdatascripts/${userdatascript}

if ( [ "${1}" != "stack" ] )
then
    /bin/echo "Your generated build script is at: ${BUILD_HOME}/userdatascripts/${userdatascript}"
else
    /bin/echo "Your generated linode specific stack script is at: ${BUILD_HOME}/userdatascripts/${userdatascript}"
fi
