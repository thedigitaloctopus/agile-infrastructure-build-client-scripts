#!/bin/sh


if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
    firewall_id="`/usr/local/bin/doctl -o json compute firewall list | jq '.[] | select (.name == "adt-build-machine" ).id' | /bin/sed 's/"//g'`"

    if ( [ "${firewall_id}" = "" ] )
    then
        /usr/local/bin/doctl compute firewall create --name "adt-build-machine" --outbound-rules "protocol:tcp,ports:all,address:0.0.0.0/0 protocol:udp,ports:all,address:0.0.0.0/0 protocol:icmp,address:0.0.0.0/0"
    else
        /bin/echo "y" | /usr/local/bin/doctl compute firewall delete ${firewall_id}
        /usr/local/bin/doctl compute firewall create --name "adt-build-machine" --outbound-rules "protocol:tcp,ports:all,address:0.0.0.0/0 protocol:udp,ports:all,address:0.0.0.0/0 protocol:icmp,address:0.0.0.0/0"
    fi

    firewall_id="`/usr/local/bin/doctl -o json compute firewall list | jq '.[] | select (.name == "adt-build-machine" ).id' | /bin/sed 's/"//g'`"

    /usr/local/bin/doctl compute firewall add-rules ${firewall_id} --inbound-rules "protocol:tcp,ports:22,address:0.0.0.0/0" 
    if ( [ "${ip}" != "NOIP" ] )
    then
        if ( [ "${ips}" != "" ] )
        then
            ips="`/bin/echo ${ips} | /bin/sed 's/:/ /g'`"
        fi
        if ( [ "${ips}" = "" ] )
        then
            /usr/local/bin/doctl compute firewall add-rules ${firewall_id} --inbound-rules "protocol:tcp,ports:${SSH_PORT},address:${ip}/32"
        else
            rules=""
            for ipaddress in ${ips}
            do
                 rules=$rules"protocol:tcp,ports:${SSH_PORT},address:${ipaddress}/32 "
                 rules=$rules"protocol:tcp,ports:${DB_PORT},address:${ipaddress}/32 "
            done
            rules=$rules"protocol:icmp,address:0.0.0.0/0"
            rules="`/bin/echo ${rules} | /bin/sed 's/ $//g'`"
            /usr/local/bin/doctl compute firewall add-rules ${firewall_id} --inbound-rules "${rules}"
        fi
    else
        /usr/local/bin/doctl compute firewall add-rules ${firewall_id} --inbound-rules "protocol:tcp,ports:${SSH_PORT},address:0.0.0.0/0 protocol:icmp,address:0.0.0.0/0"
    fi

     bmip="`/usr/bin/wget http://ipinfo.io/ip -qO -`"
     bmid="`/usr/local/bin/doctl compute droplet list | /bin/grep "${bmip}" | /usr/bin/awk '{print $1}'`"

     /usr/local/bin/doctl compute firewall add-droplets ${firewall_id} --droplet-ids ${bmid}
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
    
    if ( [ "`/usr/bin/exo -O json compute security-group list adt-build-machine | /usr/bin/jq '.[] | select (.name == "adt-build-machine")'`" = "" ] )
    then
        /usr/bin/exo compute security-group create adt-build-machine
    fi
    
    if ( [ "${ip}" != "NOIP" ] )
    then
        /usr/bin/exo compute security-group rule add adt-build-machine --network ${ip}/32 --port ${SSH_PORT} 2>/dev/null
        /usr/bin/exo compute security-group rule add adt-build-machine --protocol icmp --network 0.0.0.0/0 --icmp-code 0 --icmp-type 8 2>/dev/null
    else
        /usr/bin/exo compute security-group rule add adt-build-machine --network 0.0.0.0/0 --port ${SSH_PORT} 2>/dev/null
        /usr/bin/exo compute security-group rule add adt-build-machine --protocol icmp --network 0.0.0.0/0 --icmp-code 0 --icmp-type 8 2>/dev/null
    fi
    
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
    firewall_id="`/usr/local/bin/linode-cli --json firewalls list | jq '.[] | select (.label == "adt-build-machine" ).id'`"

    if ( [ "${firewall_id}" = "" ] )
    then
        /usr/local/bin/linode-cli firewalls create --label "adt-build-machine" --rules.inbound_policy DROP   --rules.outbound_policy ACCEPT
    else
       /usr/local/bin/linode-cli firewalls delete ${firewall_id}
       /usr/local/bin/linode-cli firewalls create --label "adt-build-machine" --rules.inbound_policy DROP   --rules.outbound_policy ACCEPT
    fi
        
    firewall_id="`/usr/local/bin/linode-cli --json firewalls list | jq '.[] | select (.label == "adt-build-machine" ).id'`"
      
    if ( [ "${ip}" != "NOIP" ] )
    then
        if ( [ "${ips}" != "" ] )
        then
            ips="`/bin/echo ${ips} | /bin/sed 's/:/ /g'`"
        fi
        if ( [ "${ips}" = "" ] )
        then
            /usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"${ip}/32\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"${SSH_PORT}\"}]" ${firewall_id}
        else
            rules=""
            for ipaddress in ${ips}
            do
                 rules=$rules"{\"addresses\":{\"ipv4\":[\"${ipaddress}/32\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"${SSH_PORT}\"},"
            done
            rules="`/bin/echo ${rules} | /bin/sed 's/,$//g'`"
            /usr/local/bin/linode-cli firewalls rules-update --inbound  "[${rules}]" ${firewall_id}
            #/usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":${iplist}},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"${SSH_PORT}\"}]" ${firewall_id}
        fi
    else
        /usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"${SSH_PORT}\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${firewall_id}       
    fi

     bmip="`/usr/bin/wget http://ipinfo.io/ip -qO -`"
     bmid="`/usr/local/bin/linode-cli --json linodes list | jq --arg tmp_ip "${bmip}" '.[] | select (.ipv4 | tostring | contains ($tmp_ip))'.id | /bin/sed 's/\"//g'`"
     
     /usr/local/bin/linode-cli firewalls device-create --id ${bmid} --type linode ${firewall_id} 
     
fi
    
