#!/bin/sh

if ( [ "${PREVIOUS_BUILD_CONFIG}" = "0" ] )
then

    status "######################################################"
    status "Would you like to install the Guardian Gateway system?"
    status "######################################################"
    status "Please enter (Y|y) to install the Guardian Gateway system"
    read response
    
    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        GUARDIAN_GATEWAY="1"
    else
        GUARDIAN_GATEWAY="0"
    fi
    
fi
