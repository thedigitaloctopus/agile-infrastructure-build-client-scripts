#!/bin/sh

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
    if ( [ "`/usr/local/bin/linode-cli --json firewalls list | jq '.[] | select (.label == "adt-build-machine" ).id'`" = "" ] )
    then
        /usr/local/bin/linode-cli firewalls create --label "adt-build-machine" --rules.inbound_policy DROP   --rules.outbound_policy DROP
    fi
    
    id="`/usr/local/bin/linode-cli --json firewalls list | jq '.[] | select (.label == "adt-build-machine" ).id'`"
    
    if ( [ "${ip}" != "NOIP" ] )
    then
        /usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"${ip}/32\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"port\":\"${SSH_PORT}\"}" ${id}
    else
        /usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"${SSH_PORT}\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${id}       
    fi
fi
    
