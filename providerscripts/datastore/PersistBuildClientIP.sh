#!/bin/sh

/usr/bin/s3cmd mb s3://adt-${BUILD_IDENTIFIER} 2>/dev/null
/usr/bin/s3cmd --recursive --force del s3://adt-${BUILD_IDENTIFIER}/*
/usr/bin/s3cmd put s3://adt-${BUILD_IDENTIFIER}/${BUILD_CLIENT_IP}
