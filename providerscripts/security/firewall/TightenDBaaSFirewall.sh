#!/bin/bash
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2016
# Description: If you are deploying a DBaaS system, this will tighten the firewalling system
# so that the databases are only accessible by ip addresses that we are using. 
# This is applied towards the end of the build process
########################################################################################
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
#########################################################################################
#########################################################################################
#set -x

if ( [ "${CLOUDHOST}" = "digitalocean" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
then
   if ( [ "${ASIP}" != "" ] )
   then
       status "Tightening the firewall on your database cluster for your autoscaler"    
       /usr/local/bin/doctl databases firewalls append ${cluster_id} --rule ip_addr:${ASIP}  
   fi
   status "Tightening the firewall on your database cluster for your webserver"    
   /usr/local/bin/doctl databases firewalls append ${cluster_id} --rule ip_addr:${WSIP}  
   status "Tightening the firewall on your database cluster for your database"    
   /usr/local/bin/doctl databases firewalls append ${cluster_id} --rule ip_addr:${DBIP}  
    status "Tightening the firewall on your database cluster for your build client"    
   /usr/local/bin/doctl databases firewalls append ${cluster_id} --rule ip_addr:${BUILD_CLIENT_IP}  
   
fi


if ( [ "${CLOUDHOST}" = "exoscale" ] && [ "${DATABASE_INSTALLATION_TYPE}"="DBaaS" ] )
then
   if ( [ "${ASIP}" != "" ] )
   then
       ips="${ASIP},${WSIP},${DBIP},${BUILD_CLIENT_IP}"
   else
       ips="${WSIP},${DBIP},${BUILD_CLIENT_IP}"
   fi

    if ( [ "${DATABASE_ENGINE}" = "pg" ] )
    then
        status "Tightening the firewall on your postgres database for your webserver with following IPs: ${ips}"    
        /usr/bin/exo dbaas update --zone ${DATABASE_REGION} ${DBaaS_DBNAME} --pg-ip-filter=${ips}
    elif ( [ "${DATABASE_ENGINE}" = "mysql" ] )
    then
        status "Tightening the firewall on your mysql database for your webserver with following IPs: ${ips}"    
        /usr/bin/exo dbaas update --zone ${DATABASE_REGION} ${DBaaS_DBNAME} --mysql-ip-filter=${ips}
    fi
fi

if ( [ "${CLOUDHOST}" = "linode" ] && [ "${DATABASE_INSTALLATION_TYPE}"="DBaaS" ] )
then
   if ( [ "${ASIP}" != "" ] )
   then
       ips="\"${ASIP}/32\",\"${WSIP}/32\",\"${DBIP}/32\",\"${BUILD_CLIENT_IP}/32\""
   else
       ips="\"${WSIP}/32\",\"${DBIP}/32\",\"${BUILD_CLIENT_IP}/32\""
   fi
   
   status "Tightening the firewall on your mysql database for your webserver with following IPs: ${ips}"  
   
   /bin/echo "TOKEN:${TOKEN} ips:${ips} DATABASE_ID:${DATABASE_ID}" > /tmp/file

   /usr/bin/curl -H "Content-Type: application/json" -H "Authorization: Bearer ${TOKEN}" -X PUT -d "{ \"allow_list\": [ ${ips} ] }" https://api.linode.com/v4beta/databases/mysql/instances/${DATABASE_ID}
 
   # Couldn't get this to work so having to use curl
    #  /usr/local/bin/linode-cli databases mysql-update --label "${DBaaS_DBNAME}" --allow-list"${ips}"

fi



