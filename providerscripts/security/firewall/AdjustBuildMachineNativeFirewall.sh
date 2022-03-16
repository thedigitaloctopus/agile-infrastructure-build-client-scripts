#!/bin/bash
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2021
# Description : This will apply any native firewalling to the build machine
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
                # rules=$rules"protocol:tcp,ports:${DB_PORT},address:${ipaddress}/32 "
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
        if ( [ "${ips}" != "" ] )
        then
            ips="`/bin/echo ${ips} | /bin/sed 's/:/ /g'`"
        fi
        if ( [ "${ips}" = "" ] )
        then
            /usr/bin/exo compute security-group rule add adt-build-machine --network ${ip}/32 --port ${SSH_PORT} 2>/dev/null
        else
            rules=""
            for ipaddress in ${ips}
            do
                /usr/bin/exo compute security-group rule add adt-build-machine --network ${ipaddress}/32 --port ${SSH_PORT} 2>/dev/null

            done
        fi
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

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
    firewall_id="`/usr/bin/vultr firewall group list | /usr/bin/tail -n +2 | /bin/grep -w 'adt-build-machine' | /usr/bin/awk '{print $1}'`"

    if ( [ "${firewall_id}" = "" ] )
    then
        firewall_id="`/usr/bin/vultr firewall group create | /usr/bin/tail -n +2 | /usr/bin/awk '{print $1}'`"  
    else
        /usr/bin/vultr firewall group delete ${firewall_id}
        firewall_id="`/usr/bin/vultr firewall group create | /usr/bin/tail -n +2 | /usr/bin/awk '{print $1}'`"  
    fi

    /usr/bin/vultr firewall group update ${firewall_id} "adt-build-machine"

    if ( [ "${ip}" != "NOIP" ] )
    then
        if ( [ "${ips}" != "" ] )
        then
            ips="`/bin/echo ${ips} | /bin/sed 's/:/ /g'`"
        fi

        if ( [ "${ips}" = "" ] )
        then
            /usr/bin/vultr firewall rule create --id ${firewall_id} --port ${SSH_PORT} --protocol tcp --size 32 --type v4 -s ${ip}
        else
            for ip in ${ips}
            do
                /usr/bin/vultr firewall rule create --id ${firewall_id} --port ${SSH_PORT} --protocol tcp --size 32 --type v4 -s ${ip}
            done
        fi
    else
        /usr/bin/vultr firewall rule create --id ${firewall_id} --port ${SSH_PORT} --protocol tcp --size 32 --type v4 -s 0.0.0.0/0
    fi

     bmip="`/usr/bin/wget http://ipinfo.io/ip -qO -`"
     bmid="`/usr/bin/vultr instance list | /bin/grep -w ${bmip} | /usr/bin/awk '{print $1}'`"

     /usr/bin/vultr instance update-firewall-group -f ${firewall_id} -i ${bmid}

fi

if ( [ "${CLOUDHOST}" = "aws" ] )
then
    interface="`/usr/bin/curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/`"
    subnet_id="`/usr/bin/curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/${interface}/subnet-id`"
    vpc_id="`/usr/bin/curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/${interface}/vpc-id)`"

    security_group_id="`/usr/bin/aws ec2 describe-security-groups | /usr/bin/jq '.SecurityGroups[] | .GroupName + " " + .GroupId' | /bin/grep adt-build-machine | /bin/sed 's/\"//g' | /usr/bin/awk '{print $NF}'`"

    if ( [ "${security_group_id}" = "" ] )
    then
        /usr/bin/aws ec2 create-security-group --description "This is the security group for your agile deployment toolkit build machine" --group-name "AgileDeploymentToolkitSecurityGroup" --vpc-id=${vpc_id}
        security_group_id="`/usr/bin/aws ec2 describe-security-groups | /usr/bin/jq '.SecurityGroups[] | .GroupName + " " + .GroupId' | /bin/grep  AgileDeploymentToolkitSecurityGroup | /bin/sed 's/\"//g' | /usr/bin/awk '{print $NF}'`"
    fi
    
    /usr/bin/aws ec2 revoke-security-group-ingress --group-id ${security_group_id}  --ip-permissions  "`/usr/bin/aws ec2 describe-security-groups --output json --group-ids ${security_group_id} --query "SecurityGroups[0].IpPermissions"`"   

    if ( [ "${ip}" != "NOIP" ] )
    then
        if ( [ "${ips}" != "" ] )
        then
            ips="`/bin/echo ${ips} | /bin/sed 's/:/ /g'`"
        fi

        if ( [ "${ips}" = "" ] )
        then
            /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=tcp,FromPort=${SSH_PORT},ToPort=${SSH_PORT},IpRanges="[{CidrIp=${ip}/32}]"
        else
            for ip in ${ips}
            do
                /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=tcp,FromPort=${SSH_PORT},ToPort=${SSH_PORT},IpRanges="[{CidrIp=${ip}/32}]"
            done
        fi
    else
        /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=tcp,FromPort=${SSH_PORT},ToPort=${SSH_PORT},IpRanges="[{0.0.0.0/0}]"
    fi
fi
    
