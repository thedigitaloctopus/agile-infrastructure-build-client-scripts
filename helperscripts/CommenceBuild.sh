if ( [ "${1}" = "" ] )
then
    /bin/echo "Please enter the port to connect to on your build machine"
    read BUILDMACHINE_SSH_PORT
else
    BUILDMACHINE_SSH_PORT="${1}"
fi
if ( [ "${2}" = "" ] )
then
    /bin/echo "Please enter the username to connect to on your build machine"
    read BUILD_MACHINE_USER
else
    BUILD_MACHINE_USER="${2}"

fi
if ( [ "${3}" = "" ] )
then
    /bin/echo "Please enter the full path to the override script you wish to use"
    read OVERRIDE_SCRIPT
else
    OVERRIDE_SCRIPT="${3}"
fi

if ( [ "${4}" = "" ] )
then
    /bin/echo "Please enter the full path to the override script you wish to use"
    read BUILD_MACHINE_IP_ADDRESS
else
    BUILD_MACHINE_IP_ADDRESS="${3}"
fi

while ( [ "`/usr/bin/ssh -p ${BUILDMACHINE_SSH_PORT} ${BUILD_MACHINE_USER}@${BUILD_MACHINE_IP_ADDRESS} "/bin/ls /home/${BUILD_MACHINE_USER}/agile-infrastructure-build-client-scripts`" = "" ] )
do
    /bin/echo "Waiting for server to come online"
    /bin/sleep 5
done

/usr/bin/scp -P ${BUILDMACHINE_SSH_PORT} ${OVERRIDE_SCRIPT} /home/${BUILD_MACHINE_USER}/agile-infrastructure-build-client-scripts/overridescripts ${BUILD_MACHINE_USER}@${BUILD_MACHINE_IP_ADDRESS}

if ( [ "$?" = "0" ] )
then
    /bin/echo "Build process successfully commenced"
else
    /bin/echo "I don't think the build process commenced successfully"
fi
