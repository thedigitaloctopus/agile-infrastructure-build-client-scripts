#!/bin/sh



if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
    if ( [ "${ip}" != "NOIP" ] )
    then
        /usr/bin/exo compute security-group rule add adt --network ${ip}/32 --port ${SSH_PORT}
    else
        /usr/bin/exo compute security-group rule add adt --network 0.0.0.0/0 --port ${SSH_PORT}
    fi
fi
