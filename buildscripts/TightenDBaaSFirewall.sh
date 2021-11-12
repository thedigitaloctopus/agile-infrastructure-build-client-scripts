#!/bin/sh

if ( [ "${CLOUDHOST}" = "digitalocean" ] && [ "${DATABASE_INSTALLATION_TYPE}"="DBaaS" ] )
then
   status "Tightening the firewall on your database cluster for your webserver"    
   /usr/local/bin/doctl databases firewalls append ${cluster_id} --rule ip_addr:${WSIP}  
fi
