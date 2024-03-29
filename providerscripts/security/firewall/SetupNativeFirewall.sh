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

        autoscaler_ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh autoscaler ${CLOUDHOST}`"
        webserver_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh webserver ${CLOUDHOST}`"
        database_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh database ${CLOUDHOST}`"
        
        autoscaler_private_ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh autoscaler ${CLOUDHOST}`"
        webserver_private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh webserver ${CLOUDHOST}`"
        database_private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh database ${CLOUDHOST}`"

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
        
        rules="`/bin/echo ${rules} | /bin/sed 's/"//g'`"
        
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

        autoscaler_ids="`/usr/local/bin/doctl compute droplet list | /bin/grep autoscaler | /usr/bin/awk -F'    ' '{print $1}' | /bin/sed 's/ //g' | /usr/bin/tr '\n' ' '`"
        autoscaler_ids="`/bin/echo ${autoscaler_ids} | /bin/sed 's/^ //g' | /bin/sed 's/ $//g' | /bin/sed 's/  / /g'`"
        webserver_id="`/usr/local/bin/doctl compute droplet list | /bin/grep webserver | /usr/bin/awk -F'    ' '{print $1}' | /bin/sed 's/ //g'`"
        database_id="`/usr/local/bin/doctl compute droplet list | /bin/grep database | /usr/bin/awk -F'    ' '{print $1}' | /bin/sed 's/ //g'`"

        droplet_ids="${autoscaler_ids} ${webserver_id} ${database_id}"
        droplet_ids="`/bin/echo ${droplet_ids} | /bin/sed 's/^ //g' | /bin/sed 's/ $//g' | /bin/sed 's/  / /g' | /bin/sed 's/ /,/g'`"
        
         /usr/local/bin/doctl compute firewall add-droplets ${firewall_id} --droplet-ids ${droplet_ids}

    elif ( [ "${PRE_BUILD}" = "1" ] )
    then
       firewall_id="`/usr/local/bin/doctl -o json compute firewall list | jq '.[] | select (.name == "adt" ).id' | /bin/sed 's/"//g'`"
        
        if ( [ "${firewall_id}" != "" ] )
        then
            /bin/echo "y" | /usr/local/bin/doctl compute firewall delete ${firewall_id}
        fi
        
        webserver_firewall_id="`/usr/local/bin/doctl -o json compute firewall list | jq '.[] | select (.name == "adt-webserver-machines" ).id' | /bin/sed 's/"//g'`"
        
        if ( [ "${webserver_firewall_id}" != "" ] )
        then
            /bin/echo "y" | /usr/local/bin/doctl compute firewall delete ${webserver_firewall_id}
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
        autoscaler_ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh autoscaler ${CLOUDHOST}`"
        webserver_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh webserver ${CLOUDHOST}`"
        database_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh database ${CLOUDHOST}`"
        
        autoscaler_private_ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh autoscaler ${CLOUDHOST}`"
        webserver_private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh webserver ${CLOUDHOST}`"
        database_private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh database ${CLOUDHOST}`"

        for ip in ${autoscaler_ips}
        do
            /usr/bin/exo compute security-group rule add adt --network ${ip}/32 --port ${SSH_PORT}
            /usr/bin/exo compute security-group rule add adt --network ${ip}/32 --port ${DB_PORT}
        done
        
        for ip in ${autoscaler_private_ips}
        do
            /usr/bin/exo compute security-group rule add adt --network ${ip}/32 --port ${SSH_PORT}
            /usr/bin/exo compute security-group rule add adt --network ${ip}/32 --port ${DB_PORT}
        done
        
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
   
        autoscaler_ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh autoscaler ${CLOUDHOST}`"
        webserver_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh webserver ${CLOUDHOST}`"
        database_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh database ${CLOUDHOST}`"
        
        autoscaler_private_ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh autoscaler ${CLOUDHOST}`"
        webserver_private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh webserver ${CLOUDHOST}`"
        database_private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh database ${CLOUDHOST}`"
    
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
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN`"

    if ( [ "${PRE_BUILD}" = "0" ] )
    then
    
       firewall_id="`/usr/bin/vultr firewall group list | /usr/bin/tail -n +2 | /bin/grep -w 'adt$' | /usr/bin/awk '{print $1}'`"
       
       if ( [ "${firewall_id}" != "" ] )
        then
            /usr/bin/vultr firewall group delete ${firewall_id}
        fi
   
        firewall_id="`/usr/bin/vultr firewall group create | /usr/bin/tail -n +2 | /usr/bin/awk '{print $1}'`"  

        /usr/bin/vultr firewall group update ${firewall_id} "adt"
        
        if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
        then
        # I couldn't get this command to work, it was giving an error message so it is commented out and the command below used instead which is not ideal
        #  /usr/bin/vultr firewall rule create --id ${firewall_id} --protocol tcp --port 443 --size 32 --type v4 --source cloudflare
           /usr/bin/vultr firewall rule create --id ${firewall_id} --port 443 --protocol tcp --size 32 --type v4 -s 0.0.0.0/0
           /usr/bin/vultr firewall rule create --id ${firewall_id} --protocol icmp --size 32 --type v4 -s 0.0.0.0/0
        else 
           /usr/bin/vultr firewall rule create --id ${firewall_id} --port 443 --protocol tcp --size 32 --type v4 -s 0.0.0.0/0
           /usr/bin/vultr firewall rule create --id ${firewall_id} --protocol icmp --size 32 --type v4 -s 0.0.0.0/0
        fi

        autoscaler_ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh autoscaler ${CLOUDHOST}`"
        webserver_ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh webserver ${CLOUDHOST}`"
        database_ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh database ${CLOUDHOST}`"
        machine_ips="${autoscaler_ips} ${webserver_ips} ${database_ips}"
       
       for machine_ip in ${machine_ips}
       do              
           /usr/bin/vultr firewall rule create --id ${firewall_id} --port ${SSH_PORT} --protocol tcp --size 32 --type v4 -s ${machine_ip}
           /usr/bin/vultr firewall rule create --id ${firewall_id} --port ${DB_PORT} --protocol tcp --size 32 --type v4 -s ${machine_ip}
           /usr/bin/vultr firewall rule create --id ${firewall_id} --port ${SSH_PORT} --protocol tcp --size 32 --type v4 -s ${BUILD_CLIENT_IP}
       done
       
       for autoscaler_ip in ${autoscaler_ips}
       do
           /usr/bin/vultr firewall rule create --id ${firewall_id} --port 22 --protocol tcp --size 32 --type v4 -s ${autoscaler_ip}
       done
       
        autoscaler_private_ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh autoscaler ${CLOUDHOST}`"
        webserver_private_ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh webserver ${CLOUDHOST}`"
        database_private_ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh database ${CLOUDHOST}`"
        machine_private_ips="${autoscaler_private_ips} ${webserver_private_ips} ${database_private_ips}"
       
       for machine_private_ip in ${machine_private_ips}
       do              
           /usr/bin/vultr firewall rule create --id ${firewall_id} --port ${SSH_PORT} --protocol tcp --size 32 --type v4 -s ${machine_private_ip}
           /usr/bin/vultr firewall rule create --id ${firewall_id} --port ${DB_PORT} --protocol tcp --size 32 --type v4 -s ${machine_private_ip}
           /usr/bin/vultr firewall rule create --id ${firewall_id} --port ${SSH_PORT} --protocol tcp --size 32 --type v4 -s ${BUILD_CLIENT_IP}
       done
       
       for autoscaler_private_ip in ${autoscaler_private_ips}
       do
           /usr/bin/vultr firewall rule create --id ${firewall_id} --port 22 --protocol tcp --size 32 --type v4 -s ${autoscaler_private_ip}
       done
        
        autoscaler_ids="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh autoscaler ${CLOUDHOST}`"
        webserver_ids="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh webserver ${CLOUDHOST}`"
        database_ids="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh database ${CLOUDHOST}`"
        machine_ids="${autoscaler_ids} ${webserver_ids} ${database_ids}"

        for machine_id in ${machine_ids}
        do
            /usr/bin/vultr instance update-firewall-group -f ${firewall_id} -i ${machine_id}
        done

    elif ( [ "${PRE_BUILD}" = "1" ] )
    then
        firewall_id="`/usr/bin/vultr firewall group list | /usr/bin/tail -n +2 | /bin/grep -w 'adt$' | /usr/bin/awk '{print $1}'`"
        
        while ( [ "${firewall_id}" != "" ] )
        do
            /usr/bin/vultr firewall group delete ${firewall_id}
            /bin/sleep 10
            firewall_id="`/usr/bin/vultr firewall group list | /usr/bin/tail -n +2 | /bin/grep -w 'adt$' | /usr/bin/awk '{print $1}'`"
        done     
    fi    
fi

if ( [ "${CLOUDHOST}" = "aws" ] )
then
    if ( [ "${PRE_BUILD}" = "1" ] )
    then
        security_group_id="`/usr/bin/aws ec2 describe-security-groups | /usr/bin/jq '.SecurityGroups[] | .GroupName + " " + .GroupId' | /bin/grep AgileDeploymentToolkitSecurityGroup | /bin/sed 's/\"//g' | /usr/bin/awk '{print $NF}'`"

        if ( [ "${security_group_id}" != "" ] )
        then
            /usr/bin/aws ec2 revoke-security-group-ingress --group-id ${security_group_id}  --ip-permissions  "`/usr/bin/aws ec2 describe-security-groups --output json --group-ids ${security_group_id} --query "SecurityGroups[0].IpPermissions"`"    
        fi
        
    elif ( [ "${PRE_BUILD}" = "0" ] )
    then
        security_group_id="`/usr/bin/aws ec2 describe-security-groups | /usr/bin/jq '.SecurityGroups[] | .GroupName + " " + .GroupId' | /bin/grep AgileDeploymentToolkitSecurityGroup | /bin/sed 's/\"//g' | /usr/bin/awk '{print $NF}'`"

        if ( [ "${security_group_id}" != "" ] )
        then
            /usr/bin/aws ec2 revoke-security-group-ingress --group-id ${security_group_id}  --ip-permissions  "`/usr/bin/aws ec2 describe-security-groups --output json --group-ids ${security_group_id} --query "SecurityGroups[0].IpPermissions"`"    
        fi
        
        . ${BUILD_HOME}/providerscripts/security/firewall/GetProxyDNSIPs.sh
                       
        if ( [ "${alldnsproxyips}" = "" ] )
        then
           /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges='[{CidrIp=0.0.0.0/0}]'
        else 
           for ip in ${alldnsproxyips} 
           do
               /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges="[{CidrIp=${ip}}]"
           done
        fi

        /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=icmp,FromPort=-1,ToPort=-1,IpRanges='[{CidrIp=0.0.0.0/0}]'

        autoscaler_ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh autoscaler ${CLOUDHOST}`"
        webserver_ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh webserver ${CLOUDHOST}`"
        database_ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh database ${CLOUDHOST}`"
        machine_ips="${autoscaler_ips} ${webserver_ips} ${database_ips}"
       
       for machine_ip in ${machine_ips}
       do    
            /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --protocol tcp  --port ${SSH_PORT} --cidr ${machine_ip}/32
            /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --protocol tcp  --port ${DB_PORT} --cidr ${machine_ip}/32
       done
       
       for autoscaler_ip in ${autoscaler_ips}
       do
            /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --protocol tcp  --port 22 --cidr ${autoscaler_ip}/32
       done
       
       autoscaler_private_ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh autoscaler ${CLOUDHOST}`"
       webserver_private_ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh webserver ${CLOUDHOST}`"
       database_private_ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh database ${CLOUDHOST}`"
       machine_private_ips="${autoscaler_private_ips} ${webserver_private_ips} ${database_private_ips}"
       
       for machine_private_ip in ${machine_private_ips}
       do              
            /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --protocol tcp  --port ${SSH_PORT} --cidr ${machine_private_ip}/32
            /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --protocol tcp  --port ${DB_PORT} --cidr ${machine_private_ip}/32
       done
       
       for autoscaler_private_ip in ${autoscaler_private_ips}
       do
            /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --protocol tcp  --port 22 --cidr ${autoscaler_private_ip}/32
       done

       /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=tcp,FromPort=${SSH_PORT},ToPort=${SSH_PORT},IpRanges="[{CidrIp=${BUILD_CLIENT_IP}/32}]"

       if ( [ "${ENABLE_EFS}" = "1" ] )
       then
           /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --protocol tcp --source-group ${security_group_id} --port 2049 --cidr 0.0.0.0/0
       fi
      
       /usr/bin/aws ec2 revoke-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=tcp,FromPort=0,ToPort=65535,IpRanges=[{CidrIp=0.0.0.0/0}]
       /usr/bin/aws ec2 revoke-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=tcp,FromPort=${SSH_PORT},ToPort=${SSH_PORT},IpRanges=[{CidrIp=0.0.0.0/0}]
       /usr/bin/aws ec2 revoke-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=tcp,FromPort=${DB_PORT},ToPort=${DB_PORT},IpRanges=[{CidrIp=0.0.0.0/0}]
       /usr/bin/aws ec2 revoke-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=tcp,FromPort=2049,ToPort=2049,IpRanges=[{CidrIp=0.0.0.0/0}]

   fi
fi
