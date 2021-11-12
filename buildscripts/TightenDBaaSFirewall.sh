#!/bin/sh

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
   status "Tightening the firewall on your database cluster for your webserver"    
   /usr/local/bin/doctl databases firewalls append ${cluster_id} --rule ip_addr:${BUILD_CLIENT_IP}  
fi
