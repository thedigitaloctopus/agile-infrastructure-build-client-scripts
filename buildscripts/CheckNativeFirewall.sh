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
    :
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
    /bin/echo "y" | /usr/bin/exo compute security-group delete adt
    /usr/bin/exo compute security-group create adt
    /usr/bin/exo compute security-group rule add adt --network 0.0.0.0/0 --port ${SSH_PORT}
    /usr/bin/exo compute security-group rule add adt --network 0.0.0.0/0 --port ${DB_PORT}
    /usr/bin/exo compute security-group rule add adt --network 0.0.0.0/0 --port 443
    /usr/bin/exo compute security-group rule add adt --network 0.0.0.0/0 --port 80
    /usr/bin/exo compute security-group rule add adt --network ${BUILD_CLIENT_IP}/32 --port 22
    /usr/bin/exo compute security-group rule add adt --protocol icmp --network 0.0.0.0/0 --icmp-code 0 --icmp-type 8
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
    firewall_id="`/usr/local/bin/linode-cli --json firewalls list | jq '.[] | select (.label == "adt" ).id'`"
    if ( [ "${firewall_id}" != "" ] )
    then
        /usr/local/bin/linode-cli firewalls delete ${firewall_id}
    fi
   
    /usr/local/bin/linode-cli firewalls create --label "adt" --rules.inbound_policy DROP   --rules.outbound_policy DROP
    firewall_id="`/usr/local/bin/linode-cli --json firewalls list | jq '.[] | select (.label == "adt" ).id'`"

    /usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"port\":\"${SSH_PORT}\"}" ${firewall_id}
    /usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"port\":\"${DB_PORT}\"}" ${firewall_id}
    /usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"port\":\"443\"}" ${firewall_id}
    /usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"port\":\"80\"}" ${firewall_id}
    /usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"${BUILD_CLIENT_IP}/32\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"port\":\"22\"}" ${firewall_id}
    /usr/local/bin/linode-cli firewalls rules-update --inbound "[{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${firewall_id}

    autoscaler_id="`/usr/local/bin/linode-cli --json linodes list | jq '.[] | select (.label | contains ("autoscaler")).id'`"
    webserver_id="`/usr/local/bin/linode-cli --json linodes list | jq '.[] | select (.label | contains ("webserver")).id'`"
    database_id="`/usr/local/bin/linode-cli --json linodes list | jq '.[] | select (.label | contains ("database")).id'`"
    
    /usr/local/bin/linode-cli firewalls device-create --id ${autoscaler_id} --type linode ${firewall_id} 
    /usr/local/bin/linode-cli firewalls device-create --id ${webserver_id} --type linode ${firewall_id} 
    /usr/local/bin/linode-cli firewalls device-create --id ${database_id} --type linode ${firewall_id} 
    
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
    :
fi

if ( [ "${CLOUDHOST}" = "aws" ] )
then
    :
fi
