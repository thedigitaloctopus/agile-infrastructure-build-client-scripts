#!/bin/sh
######################################################################################################
# Description: By creating a file: s3://authip-${BUILD_IDENTIFIER}/authorised-ips.dat in your S3 style datastore with a list
# of ipaddresses, you can allow only machines with your listed ip addresses to access your build machine.
# The file authorised-ips.dat should be formatted with ip addresses on successive lines, for example:
#
# 111.111.111.111
# 222.222.222.222
#
# Would allow machines with ip addresses 111.111.111.111 and 222.222.222.222 to connect to your build machine
# Author: Peter Winter
# Date: 17/01/2021
#######################################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################################################
#######################################################################################################
#set -x

if ( [ "`/usr/bin/crontab -l | /bin/grep Tighten`" = "" ] )
then
    /bin/echo "*/1 * * * * ${BUILD_HOME}/TightenBuildMachineFirewall.sh ${BUILD_IDENTIFIER} ${BUILD_HOME} ${SSH_PORT} ${CLOUDHOST}" >> /var/spool/cron/crontabs/root
    /usr/bin/crontab -u root /var/spool/cron/crontabs/root
fi

if ( [ ! -f /tmp/FIREWALL-EVENT ] && [ ! -f /tmp/PRIME_FIREWALL ] )
then
    exit
fi

if ( [ "${1}" != "" ] )
then
    BUILD_IDENTIFIER="${1}"
fi

if ( [ "${2}" != "" ] )
then
    BUILD_HOME="${2}"
fi

if ( [ "${3}" != "" ] )
then
   SSH_PORT="${3}"
fi

if ( [ "${4}" != "" ] )
then
   CLOUDHOST="${4}"
fi

/usr/bin/s3cmd --force get s3://authip-${BUILD_IDENTIFIER}/authorised-ips.dat /root

if ( [ "${LAPTOP_IP}" = "" ] )
then
    LAPTOP_IP="`/bin/ls ${BUILD_HOME}/runtimedata/LAPTOPIP:* | /usr/bin/awk -F':' '{print $NF}'`"
fi 

if ( [ "${LAPTOP_IP}" != "" ] )
then
    if ( [ "${LAPTOP_IP}" != "BYPASS" ] )
    then
        /bin/echo "${LAPTOP_IP}" >> /root/authorised-ips.dat
        /usr/bin/uniq /root/authorised-ips.dat > /root/authorised-ips.dat.$$
        /bin/mv /root/authorised-ips.dat.$$ /root/authorised-ips.dat
        if ( [ "`/usr/bin/s3cmd ls s3://authip-${BUILD_IDENTIFIER}`" = "" ] )
        then
            /usr/bin/s3cmd mb s3://authip-${BUILD_IDENTIFIER}
        fi
        /usr/bin/s3cmd put /root/authorised-ips.dat s3://authip-${BUILD_IDENTIFIER}/authorised-ips.dat
    fi
fi

if ( [ -f /root/authorised-ips.dat ] )
then

    if ( [ ! -f ${BUILD_HOME}/authorised-ips.dat ] )
    then
        /bin/touch ${BUILD_HOME}/authorised-ips.dat
    fi
    
    /usr/bin/diff /root/authorised-ips.dat ${BUILD_HOME}/authorised-ips.dat >> /tmp/removedips
    /bin/cat /tmp/removedips | /bin/grep ">" | /bin/grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' > /tmp/removedips.$$    /bin/mv /tmp/removedips.$$ /tmp/removedips
fi

if ( [ "`/usr/sbin/ufw status | /bin/grep ${LAPTOP_IP} | /bin/grep ALLOW`" = "" ] )
then
    /usr/sbin/ufw --force reset
    /usr/sbin/ufw default deny incoming
    /usr/sbin/ufw default allow outgoing
fi


if ( [ "${LAPTOP_IP}" != "BYPASS" ] && [ -f ${BUILD_HOME}/authorised-ips.dat ] )
then
    ips=""
    updated="0"

    while read ip 
    do
        removed="0"

        if ( [ "`/bin/cat /tmp/removedips | /bin/grep ${ip}`" = "" ] )
        then
            ips="${ips}":${ip}
        elif ( [ "`/bin/wc -l /tmp/removedips`" != "0" ] )
        then
            /bin/sed -i "/${ip}/d" /tmp/removedips
            /bin/sed -i "/${ip}/d" ${BUILD_HOME}/authorised-ips.dat
            /bin/sed -i "/${ip}/d" /root/authorised-ips.dat
            ip=""
            removed="1"
        fi
        if ( [ "`/usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ALLOW`" = "" ] )
        then
            /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}
        fi

        ipcovered="0"

        . ${BUILD_HOME}/buildscripts/CheckIPInFirewall.sh

        if ( [ "${removed}" = "1" ] || [ "${ipcovered}" = "0" ] )
        then
            updated="1"
            if ( [ "${removed}" = "1" ] )
            then
                rules="`/usr/sbin/ufw status numbered | /bin/grep ${ip} |  /usr/bin/cut -d "[" -f2 | /usr/bin/cut -d "]" -f1 | /bin/sed 's/ //g' | /usr/bin/tr '\n' ' ' | /usr/bin/rev`"
                for rule in ${rules}
                do
                    /bin/echo "y" | /usr/sbin/ufw delete ${rule}
                done
            fi
        fi
    done < ${BUILD_HOME}/authorised-ips.dat
    
    ips="`/bin/echo ${ips} | /bin/sed 's/^://g'`"

    if ( [ "${updated}" = "1" ] )
    then
        . ${BUILD_HOME}/buildscripts/AdjustBuildMachineNativeFirewall.sh
    fi
fi
 
/bin/echo "y" | /usr/sbin/ufw enable

ip=${LAPTOP_IP}
ips="${ips}":${LAPTOP_IP}
    
if ( [ "`/usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ALLOW`" = "" ] )
then
    /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}
    . ${BUILD_HOME}/buildscripts/AdjustBuildMachineNativeFirewall.sh
fi

if ( [ -f ${BUILD_HOME}/authorised-ips.dat ] && [ -f ${BUILD_HOME}/authorised-ips.dat.$$ ] && [ "`/usr/bin/diff authorised-ips.dat.$$ authorised-ips.dat`" != "" ] )
then
    /bin/mv ${BUILD_HOME}/authorised-ips.dat ${BUILD_HOME}/authorised-ips.dat.$$
fi

/bin/cp /root/authorised-ips.dat ${BUILD_HOME}
