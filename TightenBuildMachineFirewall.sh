#!/bin/sh

if ( [ "`/usr/bin/crontab -l | /bin/grep Tighten`" = "" ] )
then
    /bin/echo "*/1 * * * * export HOME="${BUILD_HOME}" && ${BUILD_HOME}/TightenBuildMachineFirewall.sh" >> /var/spool/cron/crontabs/root
    /usr/bin/crontab -u root /var/spool/cron/crontabs/root
fi

/bin/mv authorised-ips.dat authorised-ips.dat.$$

/usr/bin/s3cmd --force get s3://adt/authorised-ips.dat

if ( [ "`/usr/bin/diff authorised-ips.dat.$$ authorised-ips.dat`" = "" ] )
then
    /bin/mv authorised-ips.dat.$$ authorised-ips.dat
    exit
else
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
fi
