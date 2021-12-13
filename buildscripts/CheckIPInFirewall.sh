#!/bin/sh


if ( [ "${CLOUDHOST}" = "linode" ] )
then
    ipcovered="0"
    if ( [ "`/usr/local/bin/linode-cli --json firewalls list | /bin/grep "${ip}/32"`" != "" ] )
    then
        ipcovered="1"
    fi


fi
