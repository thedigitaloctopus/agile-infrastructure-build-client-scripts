#!/bin/sh



if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
    /usr/bin/exo compute security-group rule add adt --network ${1}/32 --port ${2}
fi
