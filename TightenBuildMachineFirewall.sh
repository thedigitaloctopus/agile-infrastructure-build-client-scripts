set -x

/usr/bin/s3cmd --force get s3://adt/authorised-ips.dat

if ( [ -f ${BUILD_HOME}/authorised-ips.dat ] )
then

    /usr/sbin/ufw --force reset
    /usr/sbin/ufw default deny incoming
    /usr/sbin/ufw default allow outgoing
    while read ip
    do
        /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}
    done < ${BUILD_HOME}/authorised-ips.dat
    
    /bin/echo "y" | /usr/sbin/ufw enable
fi
