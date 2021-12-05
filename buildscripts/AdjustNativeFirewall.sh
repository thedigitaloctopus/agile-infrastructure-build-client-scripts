#!/bin/sh



if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
    /bin/echo "y" | /usr/bin/exo compute security-group delete adt-build-machine
    /usr/bin/exo compute security-group create adt-build-machine
    if ( [ "${ip}" != "NOIP" ] )
    then
        /usr/bin/exo compute security-group rule add adt-build-machine --network ${ip}/32 --port ${SSH_PORT}
    else
        /usr/bin/exo compute security-group rule add adt-build-machine --network 0.0.0.0/0 --port ${SSH_PORT}
    fi
fi
