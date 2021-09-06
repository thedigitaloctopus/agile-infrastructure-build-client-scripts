#!/bin/sh

/usr/bin/s3cmd mb s3://adt-${BUILD_IDENTIFIER} 2>/dev/null
/usr/bin/s3cmd --recursive --force del s3://adt-${BUILD_IDENTIFIER}/*
/bin/touch /tmp/${BUILD_CLIENT_IP}
/usr/bin/s3cmd put /tmp/${BUILD_CLIENT_IP} s3://adt-${BUILD_IDENTIFIER}
