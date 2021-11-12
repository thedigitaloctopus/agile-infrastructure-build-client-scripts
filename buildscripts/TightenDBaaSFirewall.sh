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
