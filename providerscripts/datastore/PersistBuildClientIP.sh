#!/bin/sh

/usr/bin/s3cmd mb s3://adt-${BUILD_IDENTIFIER} 2>/dev/null
/usr/bin/s3cmd ls s3://adt-${BUILD_IDENTIFIER}/  | /usr/bin/awk '{print $4}' | /usr/bin/xargs s3cmd del
/bin/touch /tmp/${BUILD_CLIENT_IP}
/usr/bin/s3cmd put /tmp/${BUILD_CLIENT_IP} s3://adt-${BUILD_IDENTIFIER}
