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
        GATEWAY_GUARDIAN="1"
    else
        GATEWAY_GUARDIAN="0"
    fi
    
fi