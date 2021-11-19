#!/bin/sh

if ( [ "${CLOUDHOST}" = "digitalocean" ] && [ "${DATABASE_INSTALLATION_TYPE}"="DBaaS" ] )
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
       ips="${ASIP},${WSIP},${DBIP},${BUILD_CLIENT_IP}""
   else
       ips="${WSIP},${DBIP},${BUILD_CLIENT_IP}""
   fi

    if ( [ "${DATABASE_ENGINE}" = "pg" ] )
    then
        /usr/bin/exo dbaas update -z ${DATABASE_REGION} ${DBaaS_DBNAME} --pg-ip-filter=${ips}
    elif ( [ "${DATABASE_ENGINE}" = "mysql" ] )
    then
        /usr/bin/exo dbaas update -z ${DATABASE_REGION} ${DBaaS_DBNAME} --mysql-ip-filter=${ips}
    fi
fi
