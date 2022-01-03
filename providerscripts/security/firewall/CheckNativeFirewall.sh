#!/bin/bash
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2021
# Description : This will apply any native firewalling if necessary
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


if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
    if ( [ "${PRE_BUILD}" = "0" ] )
    then
        firewall_id="`/usr/local/bin/doctl -o json compute firewall list | jq '.[] | select (.name == "adt" ).id' | /bin/sed 's/"//g'`"

        
        if ( [ "${firewall_id}" != "" ] )
        then
            /bin/echo "y" | /usr/local/bin/doctl compute firewall delete ${firewall_id}
        fi

        /usr/local/bin/doctl compute firewall create --name "adt" --outbound-rules "protocol:tcp,ports:all,address:0.0.0.0/0 protocol:udp,ports:all,address:0.0.0.0/0 protocol:icmp,address:0.0.0.0/0"


        firewall_id="`/usr/local/bin/doctl -o json compute firewall list | jq '.[] | select (.name == "adt" ).id' | /bin/sed 's/"//g'`"

        server_type="autoscaler"
        autoscaler_ips="`/usr/local/bin/doctl compute droplet list | /bin/grep ${server_type} | /usr/bin/awk -F'    ' '{print $3}' | /bin/sed 's/ //g'`"
        autoscaler_private_ips="`/usr/local/bin/doctl compute droplet list | /bin/grep ${server_type} | /usr/bin/awk -F'    ' '{print $4}' | /bin/sed 's/ //g'`"
        server_type="webserver"
        webserver_ip="`/usr/local/bin/doctl compute droplet list | /bin/grep ${server_type} | /usr/bin/awk -F'    ' '{print $3}' | /bin/sed 's/ //g'`"
        webserver_private_ip="`/usr/local/bin/doctl compute droplet list | /bin/grep ${server_type} | /usr/bin/awk -F'    ' '{print $4}' | /bin/sed 's/ //g'`"
        server_type="database"
        database_ip="`/usr/local/bin/doctl compute droplet list | /bin/grep ${server_type} | /usr/bin/awk -F'    ' '{print $3}' | /bin/sed 's/ //g'`"
        database_private_ip="`/usr/local/bin/doctl compute droplet list | /bin/grep ${server_type} | /usr/bin/awk -F'    ' '{print $4}' | /bin/sed 's/ //g'`"

        ips=""

        for autoscaler_ip in ${autoscaler_ips}
        do
            if ( [ "${autoscaler_ip}" != "" ] )
            then
                ips=${ips}"\"${autoscaler_ip}/32\" "
            fi
        done

        for autoscaler_private_ip in ${autoscaler_private_ips}
        do
            if ( [ "${autoscaler_private_ip}" != "" ] )
            then
                ips=${ips}"\"${autoscaler_private_ip}/32\" "
            fi
        done
        
        if ( [ "${webserver_ip}" != "" ] )
        then
            ips=${ips}"\"${webserver_ip}/32\" "
        fi
        
        if ( [ "${webserver_private_ip}" != "" ] )
        then
            ips=${ips}"\"${webserver_private_ip}/32\" "
        fi
        
        if ( [ "${database_ip}" != "" ] )
        then
            ips=${ips}"\"${database_ip}/32\" "
        fi
        
        if ( [ "${database_private_ip}" != "" ] )
        then
            ips=${ips}"\"${database_private_ip}/32\" "
        fi

        if ( [ "${BUILD_CLIENT_IP}" != "" ] )
        then
            ips=${ips}"\"${BUILD_CLIENT_IP}/32\""
        fi

        rules=""

        for ip in ${ips}
        do
            rules=${rules}" protocol:tcp,ports:${SSH_PORT},address:${ip}" 
            rules=${rules}" protocol:tcp,ports:${DB_PORT},address:${ip}" 
        done


        . ${BUILD_HOME}/providerscripts/security/firewall/GetProxyDNSIPs.sh
                        
        
        if ( [ "${alldnsproxyips}" = "" ] )
        then
             for ip in ${alldnsproxyips}
             do
                rules=${rules}" protocol:tcp,ports:443,address:${ip}" 
             done
        fi

        rules=${rules}" protocol:icmp,address:0.0.0.0/0"

        /usr/local/bin/doctl compute firewall add-rules ${firewall_id} --inbound-rules "${rules}"

        autoscaler_id="`/usr/local/bin/doctl compute droplet list | /bin/grep autoscaler | /usr/bin/awk -F'    ' '{print $1}' | /bin/sed 's/ //g'`"
        webserver_id="`/usr/local/bin/doctl compute droplet list | /bin/grep webserver | /usr/bin/awk -F'    ' '{print $1}' | /bin/sed 's/ //g'`"
        database_id="`/usr/local/bin/doctl compute droplet list | /bin/grep database | /usr/bin/awk -F'    ' '{print $1}' | /bin/sed 's/ //g'`"

        /usr/local/bin/doctl compute firewall add-droplets ${firewall_id} --droplet-ids ${autoscaler_id}
        /usr/local/bin/doctl compute firewall add-droplets ${firewall_id} --droplet-ids ${webserver_id}
        /usr/local/bin/doctl compute firewall add-droplets ${firewall_id} --droplet-ids ${database_id}
    
    elif ( [ "${PRE_BUILD}" = "1" ] )
    then
       firewall_id="`/usr/local/bin/doctl -o json compute firewall list | jq '.[] | select (.name == "adt" ).id' | /bin/sed 's/"//g'`"
        
        if ( [ "${firewall_id}" != "" ] )
        then
            /bin/echo "y" | /usr/local/bin/doctl compute firewall delete ${firewall_id}
        fi
    fi    
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
    if ( [ "${PRE_BUILD}" = "1" ] )
    then
        /bin/echo "y" | /usr/bin/exo compute security-group delete adt
        /usr/bin/exo compute security-group create adt
        /usr/bin/exo compute security-group rule add adt --network ${BUILD_CLIENT_IP}/32 --port 22
        /usr/bin/exo compute security-group rule add adt --network ${BUILD_CLIENT_IP}/32 --port ${SSH_PORT}
        /usr/bin/exo compute security-group rule add adt --protocol icmp --network 0.0.0.0/0 --icmp-code 0 --icmp-type 8
    elif ( [ "${PRE_BUILD}" = "0" ] )
    then
        server_type="autoscaler"
        autoscaler_ip="`/usr/local/bin/cs listVirtualMachines | /usr/bin/jq --arg tmp_server_type "${server_type}" '(.virtualmachine[] | select(.displayname | contains($tmp_server_type)) | .publicip)' | /bin/sed 's/"//g'`"
        vmid="`/usr/local/bin/cs listVirtualMachines | /usr/bin/jq --arg tmp_ip_address "${autoscaler_ip}" '(.virtualmachine[].nic[] | select(.ipaddress == $tmp_ip_address) | .id)' | /bin/sed 's/"//g'`"
        vmid2="`/usr/local/bin/cs listNics | jq --arg tmp_virtual_machine_id "${vmid}" '(.nic[] | select(.id == $tmp_virtual_machine_id) | .virtualmachineid)' | /bin/sed 's/"//g'`"
        autoscaler_private_ip="`/usr/local/bin/cs listNics | jq --arg tmp_virtual_machine_id "${vmid2}" '(.nic[] | select(.isdefault == false and .virtualmachineid == $tmp_virtual_machine_id) | .ipaddress)' | /bin/sed 's/"//g'`"

        server_type="webserver"
        webserver_ip="`/usr/local/bin/cs listVirtualMachines | /usr/bin/jq --arg tmp_server_type "${server_type}" '(.virtualmachine[] | select(.displayname | contains($tmp_server_type)) | .publicip)' | /bin/sed 's/"//g'`"
        vmid="`/usr/local/bin/cs listVirtualMachines | /usr/bin/jq --arg tmp_ip_address "${webserver_ip}" '(.virtualmachine[].nic[] | select(.ipaddress == $tmp_ip_address) | .id)' | /bin/sed 's/"//g'`"
        vmid2="`/usr/local/bin/cs listNics | jq --arg tmp_virtual_machine_id "${vmid}" '(.nic[] | select(.id == $tmp_virtual_machine_id) | .virtualmachineid)' | /bin/sed 's/"//g'`"
        webserver_private_ip="`/usr/local/bin/cs listNics | jq --arg tmp_virtual_machine_id "${vmid2}" '(.nic[] | select(.isdefault == false and .virtualmachineid == $tmp_virtual_machine_id) | .ipaddress)' | /bin/sed 's/"//g'`"

        server_type="database"
        database_ip="`/usr/local/bin/cs listVirtualMachines | /usr/bin/jq --arg tmp_server_type "${server_type}" '(.virtualmachine[] | select(.displayname | contains($tmp_server_type)) | .publicip)' | /bin/sed 's/"//g'`"
        vmid="`/usr/local/bin/cs listVirtualMachines | /usr/bin/jq --arg tmp_ip_address "${database_ip}" '(.virtualmachine[].nic[] | select(.ipaddress == $tmp_ip_address) | .id)' | /bin/sed 's/"//g'`"
        vmid2="`/usr/local/bin/cs listNics | jq --arg tmp_virtual_machine_id "${vmid}" '(.nic[] | select(.id == $tmp_virtual_machine_id) | .virtualmachineid)' | /bin/sed 's/"//g'`"
        database_private_ip="`/usr/local/bin/cs listNics | jq --arg tmp_virtual_machine_id "${vmid2}" '(.nic[] | select(.isdefault == false and .virtualmachineid == $tmp_virtual_machine_id) | .ipaddress)' | /bin/sed 's/"//g'`"


        if ( [ "${autoscaler_ip}" != "" ] )
        then
            /usr/bin/exo compute security-group rule add adt --network ${autoscaler_ip}/32 --port ${SSH_PORT}
            /usr/bin/exo compute security-group rule add adt --network ${autoscaler_private_ip}/32 --port ${SSH_PORT}
            /usr/bin/exo compute security-group rule add adt --network ${autoscaler_ip}/32 --port ${DB_PORT}
            /usr/bin/exo compute security-group rule add adt --network ${autoscaler_private_ip}/32 --port ${DB_PORT}
        fi
        
        if ( [ "${webserver_ip}" != "" ] )
        then
            /usr/bin/exo compute security-group rule add adt --network ${webserver_ip}/32 --port ${SSH_PORT}
            /usr/bin/exo compute security-group rule add adt --network ${webserver_private_ip}/32 --port ${SSH_PORT}
            /usr/bin/exo compute security-group rule add adt --network ${webserver_ip}/32 --port ${DB_PORT}
            /usr/bin/exo compute security-group rule add adt --network ${webserver_private_ip}/32 --port ${DB_PORT}
        fi
        
        if ( [ "${database_ip}" != "" ] )
        then
            /usr/bin/exo compute security-group rule add adt --network ${database_ip}/32 --port ${SSH_PORT}
            /usr/bin/exo compute security-group rule add adt --network ${database_private_ip}/32 --port ${SSH_PORT}
            /usr/bin/exo compute security-group rule add adt --network ${database_ip}/32 --port ${DB_PORT}
            /usr/bin/exo compute security-group rule add adt --network ${database_private_ip}/32 --port ${DB_PORT}
        fi

       # /usr/bin/exo compute security-group rule add adt --network 0.0.0.0/0 --port 443
      #  /usr/bin/exo compute security-group rule add adt --network 0.0.0.0/0 --port 80
        /usr/bin/exo compute security-group rule add adt --network ${BUILD_CLIENT_IP}/32 --port 22
        /usr/bin/exo compute security-group rule add adt --protocol icmp --network 0.0.0.0/0 --icmp-code 0 --icmp-type 8
        
        . ${BUILD_HOME}/providerscripts/security/firewall/GetProxyDNSIPs.sh

        if ( [ "${alldnsproxyips}" != "" ] )
        then
            alldnsproxyips="`/bin/echo ${alldnsproxyips} | /bin/sed 's/,/ /g'`"
            for ip in ${alldnsproxyips}
            do
                /usr/bin/exo compute security-group rule add adt --network ${ip} --port 443
                /usr/bin/exo compute security-group rule add adt --network ${ip} --port 80
            done
        else
            /usr/bin/exo compute security-group rule add adt --network 0.0.0.0/0 --port 443
            /usr/bin/exo compute security-group rule add adt --network 0.0.0.0/0 --port 80        
        fi
    fi
fi


if ( [ "${CLOUDHOST}" = "linode" ] )
then
    if ( [ "${PRE_BUILD}" = "0" ] )
    then
        firewall_id="`/usr/local/bin/linode-cli --json firewalls list | jq '.[] | select (.label == "adt" ).id'`"
        
        if ( [ "${firewall_id}" != "" ] )
        then
            /usr/local/bin/linode-cli firewalls delete ${firewall_id}
        fi
   
        /usr/local/bin/linode-cli firewalls create --label "adt" --rules.inbound_policy DROP   --rules.outbound_policy ACCEPT
        firewall_id="`/usr/local/bin/linode-cli --json firewalls list | jq '.[] | select (.label == "adt" ).id'`"


        server_type="autoscaler"
        autoscaler_ips="`/usr/local/bin/linode-cli linodes list --text | /bin/grep ${server_type} | /bin/grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | /bin/grep -v "192.168"`"
        autoscaler_private_ips="`/usr/local/bin/linode-cli linodes list --text | /bin/grep ${server_type} | /bin/grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | /bin/grep "192.168"`"
        server_type="webserver"
        webserver_ip="`/usr/local/bin/linode-cli linodes list --text | /bin/grep ${server_type} | /bin/grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | /bin/grep -v "192.168"`"
        webserver_private_ip="`/usr/local/bin/linode-cli linodes list --text | /bin/grep ${server_type} | /bin/grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | /bin/grep "192.168"`"
        server_type="database"
        database_ip="`/usr/local/bin/linode-cli linodes list --text | /bin/grep ${server_type} | /bin/grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | /bin/grep -v "192.168"`"
        database_private_ip="`/usr/local/bin/linode-cli linodes list --text | /bin/grep ${server_type} | /bin/grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | /bin/grep "192.168"`"
    
        ips=""

        for autoscaler_ip in ${autoscaler_ips}
        do
            if ( [ "${autoscaler_ip}" != "" ] )
            then
                ips=${ips}"\"${autoscaler_ip}/32\","
            fi
        done

        for autoscaler_private_ip in ${autoscaler_private_ips}
        do
            if ( [ "${autoscaler_private_ip}" != "" ] )
            then
                ips=${ips}"\"${autoscaler_private_ip}/32\","
            fi
        done
        
        if ( [ "${webserver_ip}" != "" ] )
        then
            ips=${ips}"\"${webserver_ip}/32\","
        fi
        
        if ( [ "${webserver_private_ip}" != "" ] )
        then
            ips=${ips}"\"${webserver_private_ip}/32\","
        fi
        
        if ( [ "${database_ip}" != "" ] )
        then
            ips=${ips}"\"${database_ip}/32\","
        fi
        
        if ( [ "${database_private_ip}" != "" ] )
        then
            ips=${ips}"\"${database_private_ip}/32\","
        fi

        if ( [ "${BUILD_CLIENT_IP}" != "" ] )
        then
            ips=${ips}"\"${BUILD_CLIENT_IP}/32\""
        fi

        . ${BUILD_HOME}/providerscripts/security/firewall/GetProxyDNSIPs.sh
                        
        ips="`/bin/echo ${ips} | /bin/sed 's/,$//g'`"
        
        if ( [ "${alldnsproxyips}" = "" ] )
        then
            /usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[${ips}]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"${SSH_PORT},${DB_PORT},22\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"443,80\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${firewall_id}
        else 
             /usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[${ips}]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"${SSH_PORT},${DB_PORT},22\"},{\"addresses\":{\"ipv4\":[${alldnsproxyips}]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"443,80\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${firewall_id}
        fi
        
        #/usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"${SSH_PORT},${DB_PORT},443,80,22\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${firewall_id}
    
        autoscaler_id="`/usr/local/bin/linode-cli --json linodes list | jq '.[] | select (.label | contains ("autoscaler")).id'`"
        webserver_id="`/usr/local/bin/linode-cli --json linodes list | jq '.[] | select (.label | contains ("webserver")).id'`"
        database_id="`/usr/local/bin/linode-cli --json linodes list | jq '.[] | select (.label | contains ("database")).id'`"
    
        /usr/local/bin/linode-cli firewalls device-create --id ${autoscaler_id} --type linode ${firewall_id} 2>/dev/null
        /usr/local/bin/linode-cli firewalls device-create --id ${webserver_id} --type linode ${firewall_id} 
        /usr/local/bin/linode-cli firewalls device-create --id ${database_id} --type linode ${firewall_id} 
    elif ( [ "${PRE_BUILD}" = "1" ] )
    then
       firewall_id="`/usr/local/bin/linode-cli --json firewalls list | jq '.[] | select (.label == "adt" ).id'`"
        
       if ( [ "${firewall_id}" != "" ] )
       then
           /usr/local/bin/linode-cli firewalls delete ${firewall_id}
       fi
    fi    
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
    :
fi

if ( [ "${CLOUDHOST}" = "aws" ] )
then
    :
fi
