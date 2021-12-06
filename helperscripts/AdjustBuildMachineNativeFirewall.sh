#!/bin/sh


if ( [ "${1}" = "" ] || [ "${2}" = "" ] || [ "${3}" = "" ] )
then
    /bin/echo "Sorry usage: ${0} <build-identifier> <ip> <mode - add|remove>"
    exit
else
    BUILD_IDENTIFIER="${1}"
    ip="${2}"
    mode="${3}"
fi

if ( [ "`/usr/bin/s3cmd ls s3://authip-${BUILD_IDENTIFIER}`" = "" ] )
then
    /usr/bin/s3cmd mb s3://authip-${BUILD_IDENTIFIER}
fi

/usr/bin/s3cmd --force get s3://authip-${BUILD_IDENTIFIER}/authorised-ips.dat

if ( [ "${mode}" = "add" ] )
then
    /bin/echo ${ip} >> ./authorised-ips.dat
else
    /bin/sed -i "/${ip}/d" ./authorised-ips.dat
fi

/usr/bin/sort -u -o ./authorised-ips.dat ./authorised-ips.dat | /bin/sed -i '/^$/d' ./authorised-ips.dat

/usr/bin/s3cmd put ./authorised-ips.dat  s3://authip-${BUILD_IDENTIFIER}

/bin/rm ./authorised-ips.dat
