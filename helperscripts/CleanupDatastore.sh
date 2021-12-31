#!/bin/sh

buckets="`/usr/bin/s3cmd ls | /usr/bin/awk '{print $NF}'`"


for bucket in ${buckets}
do
    /bin/echo "Have found bucket: ${bucket} do you want to delete it, (Y|N)"
    read response

    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        /usr/bin/s3cmd del --recursive --force ${bucket}
        /usr/bin/s3cmd rb ${bucket}
    fi
done
