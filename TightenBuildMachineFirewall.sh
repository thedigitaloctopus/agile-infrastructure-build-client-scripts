/usr/bin/s3cmd get s3://adt/authorised-ips.dat

if ( [ -f ${BUILD_HOME}/authorised-ips.dat ] )
then

    /usr/sbin/ufw reset

    while read ip
    do

        /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}

    done < ${BUILD_HOME}/authorised-ips.dat
    
    /usr/sbin/ufw enable

fi
