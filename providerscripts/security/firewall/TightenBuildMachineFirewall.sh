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
set -x

if ( [ "`/usr/bin/crontab -l | /bin/grep Tighten`" = "" ] )
then
    /bin/echo "*/1 * * * * ${BUILD_HOME}/providerscripts/security/firewall/TightenBuildMachineFirewall.sh ${BUILD_IDENTIFIER} ${BUILD_HOME} ${SSH_PORT} ${DATASTORE_PROVIDER} ${CLOUDHOST}" >> /var/spool/cron/crontabs/root
    /usr/bin/crontab -u root /var/spool/cron/crontabs/root
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
    DATASTORE_CHOICE="${4}"
fi

if ( [ "${5}" != "" ] )
then
    CLOUDHOST="${5}"
fi

${BUILD_HOME}/providerscripts/datastore/GetFromDatastore.sh ${DATASTORE_CHOICE} authip-${BUILD_IDENTIFIER}/FIREWALL-EVENT /tmp
#/usr/bin/s3cmd --force get s3://authip-${BUILD_IDENTIFIER}/FIREWALL-EVENT /tmp

if ( [ -f /tmp/FIREWALL-EVENT ] || [ -f /tmp/PRIME_FIREWALL ] )
then
    /bin/rm /tmp/*FIREWALL*

    ${BUILD_HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${DATASTORE_CHOICE} authip-${BUILD_IDENTIFIER}/FIREWALL-EVENT
    ${BUILD_HOME}/providerscripts/datastore/GetFromDatastore.sh ${DATASTORE_CHOICE} authip-${BUILD_IDENTIFIER}/authorised-ips.dat /root

   # /usr/bin/s3cmd --force del s3://authip-${BUILD_IDENTIFIER}/FIREWALL-EVENT 2>/dev/null
   # /usr/bin/s3cmd --force get s3://authip-${BUILD_IDENTIFIER}/authorised-ips.dat /root

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
           
          #if ( [ "`/usr/bin/s3cmd ls s3://authip-${BUILD_IDENTIFIER}`" = "" ] )

           if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_CHOICE} authip-${BUILD_IDENTIFIER}`" = "" ] )
           then
               ${BUILD_HOME}/providerscripts/datastore/MountDatastore.sh ${DATASTORE_CHOICE} authip-${BUILD_IDENTIFIER}
              # /usr/bin/s3cmd mb s3://authip-${BUILD_IDENTIFIER}
           fi
          # /usr/bin/s3cmd put /root/authorised-ips.dat s3://authip-${BUILD_IDENTIFIER}/authorised-ips.dat
           ${BUILD_HOME}/providerscripts/datastore/PutToDatastore.sh ${DATASTORE_CHOICE} /root/authorised-ips.dat authip-${BUILD_IDENTIFIER}/authorised-ips.dat

       fi
   fi

   ips="`/bin/cat /root/authorised-ips.dat | /bin/tr '\n' ' '`"

   for ip in ${ips}
   do
       /usr/sbin/ufw allow from ${ip}
   done

   . ${BUILD_HOME}/providerscripts/security/firewall/AdjustBuildMachineNativeFirewall.sh

   if ( [ -f ${BUILD_HOME}/authorised-ips.dat ] && [ -f ${BUILD_HOME}/authorised-ips.dat.$$ ] && [ "`/usr/bin/diff authorised-ips.dat.$$ authorised-ips.dat`" != "" ] )
   then
       /bin/mv ${BUILD_HOME}/authorised-ips.dat ${BUILD_HOME}/authorised-ips.dat.$$
   fi

   /bin/cp /root/authorised-ips.dat ${BUILD_HOME}
fi
