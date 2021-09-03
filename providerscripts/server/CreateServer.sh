#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will spin up a new server of the size, region and os
# specified  on the hosting provider, cloudhost, of choice.
###################################################################################
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
####################################################################################
####################################################################################
#set -x

os_choice="${1}"
region="${2}"
server_size="${3}"
server_name="${4}"
key_id="${5}"
cloudhost="${6}"
snapshot_id="${8}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    if ( [ "${snapshot_id}" != "" ] )
    then
        os_choice="${snapshot_id}"
    else
        os_choice="`/bin/echo "${os_choice}" | /bin/sed "s/'//g"`"
    fi
    /usr/local/bin/doctl compute droplet create "${server_name}" --size "${server_size}" --image "${os_choice}"  --region "${region}" --ssh-keys "${key_id}" --enable-private-networking
fi

template_id="${1}"
zone_id="${2}"
service_offering_id="${3}"
server_name="${4}"
key_pair="${5}"
cloudhost="${6}"
snapshot_id="${7}"

if ( [ "${cloudhost}" = "exoscale" ] )
then
    template_id="`/bin/echo "${template_id}" | /bin/sed "s/'//g"`"
    
    if ( [ "${snapshot_id}" != "" ] )
    then
        template_id="${snapshot_id}"
    fi

    case ${service_offering_id} in
        b6cd1ff5-3a2f-4e9d-a4d1-8988c1191fe8 ) disksize="10"
            break ;;
        b6e9d1e8-89fc-4db3-aaa4-9b4c5b1d0844 ) disksize="50"
            break ;;
        cf99499-7f59-4138-9427-a09db13af2bc ) disksize="100"
            break ;;
        350dc5ea-fe6d-42ba-b6c0-efb8b75617ad ) disksize="200"
            break ;;
        a216b0d1-370f-4e21-a0eb-3dfc6302b564 ) disksize="400"
            break ;;
    esac
        
   zone_name="`/usr/local/bin/cs listZones | jq --arg tmp_zone_id "${zone_id}" '(.zone[] | select(.id == $tmp_zone_id ) | .name)' | /bin/sed 's/"//g'`"
   private_network_id="`/usr/local/bin/cs listNetworks | jq --arg tmp_zone_id "${zone_id}" --arg tmp_zonename "${zone_name}" '(.network[] | select(.zonename == $tmp_zonename and .name == "adt" and .zoneid == $tmp_zone_id ) | .id)' | /bin/sed 's/"//g'`"
    
    if ( [ "${private_network_id}" = "" ] )
    then
        network_offering_id="`/usr/local/bin/cs listNetworkOfferings | jq '(.networkoffering[] | select(.name == "PrivNet" and .state == "Enabled" and .guestiptype == "Isolated" )  | .id)' | /bin/sed 's/"//g'`"
        private_network_id="`/usr/local/bin/cs createNetwork displaytext="AgileDeploymentToolkit" name="adt" networkofferingid="${network_offering_id}" zoneid="${zone_id}" startip="10.0.0.10" endip="10.0.0.40" netmask="255.255.255.0" | jq '.network.id' | /bin/sed 's/"//g'`"
    fi

    vmid="`/usr/local/bin/cs deployVirtualMachine templateid="${template_id}" zoneid="${zone_id}" serviceofferingid="${service_offering_id}" name="${server_name}" keyPair="${key_pair}" rootdisksize="${disksize}" | jq '.virtualmachine.id' | /bin/sed 's/"//g'`"
    /usr/local/bin/cs addNicToVirtualMachine networkid="${private_network_id}" virtualmachineid="${vmid}"

fi

distribution="${1}"
location="${2}"
server_size="${3}"
server_name="`/bin/echo ${4} | /usr/bin/cut -c -32`"
key="${5}"
cloudhost="${6}"
username="${7}"
password="${8}"
snapshot_id="${10}"

if ( [ "${cloudhost}" = "linode" ] )
then
    
    if ( [ "${password}" = "" ] )
    then
        password="156432wdfpdaiI"
    fi

    if ( [ "${snapshot_id}" != "" ] )
    then
            /usr/local/bin/linode-cli linodes create --root_pass ${password} --region ${location} --image "private/${snapshot_id}" --type ${server_size} --group "Agile Deployment Toolkit" --label "${server_name}"
            server_id="`/usr/local/bin/linode-cli linodes list --text --label ${server_name} | /bin/grep -v 'id' | /usr/bin/awk '{print $1}'`"
            /usr/local/bin/linode-cli linodes ip-add ${server_id} --type ipv4 --public false
    else
        if ( [ "`/bin/echo ${distribution} | /bin/grep 'Ubuntu 18.04'`" != "" ] )
        then
            /usr/local/bin/linode-cli linodes create --root_pass ${password} --region ${location} --image linode/ubuntu18.04 --type ${server_size} --group "Agile Deployment Toolkit" --label "${server_name}"
            server_id="`/usr/local/bin/linode-cli linodes list --text --label ${server_name} | /bin/grep -v 'id' | /usr/bin/awk '{print $1}'`"
            /usr/local/bin/linode-cli linodes ip-add ${server_id} --type ipv4 --public false
        elif ( [ "`/bin/echo ${distribution} | /bin/grep 'Ubuntu 20.04'`" != "" ] )
        then
            /usr/local/bin/linode-cli linodes create --root_pass ${password} --region ${location} --image linode/ubuntu20.04 --type ${server_size} --group "Agile Deployment Toolkit" --label "${server_name}"
            server_id="`/usr/local/bin/linode-cli linodes list --text --label ${server_name} | /bin/grep -v 'id' | /usr/bin/awk '{print $1}'`"
            /usr/local/bin/linode-cli linodes ip-add ${server_id} --type ipv4 --public false
        elif ( [ "`/bin/echo ${distribution} | /bin/grep 'Debian 9'`" != "" ] )
        then
            /usr/local/bin/linode-cli linodes create --root_pass ${password} --region ${location} --image linode/debian9 --type ${server_size} --group "Agile Deployment Toolkit" --label "${server_name}"
            server_id="`/usr/local/bin/linode-cli linodes list --text --label ${server_name} | /bin/grep -v 'id' | /usr/bin/awk '{print $1}'`"
            /usr/local/bin/linode-cli linodes ip-add ${server_id} --type ipv4 --public false
        elif ( [ "`/bin/echo ${distribution} | /bin/grep 'Debian 10'`" != "" ] )
        then
            /usr/local/bin/linode-cli linodes create --root_pass ${password} --region ${location} --image linode/debian10 --type ${server_size} --group "Agile Deployment Toolkit" --label "${server_name}"
            server_id="`/usr/local/bin/linode-cli linodes list --text --label ${server_name} | /bin/grep -v 'id' | /usr/bin/awk '{print $1}'`"
            /usr/local/bin/linode-cli linodes ip-add ${server_id} --type ipv4 --public false
        fi
    fi
fi

os_choice="${1}"
region="${2}"
server_plan="${3}"
server_name="${4}"
key_id="${5}"
cloudhost="${6}"
snapshot_id="${9}"

if (  [ "${cloudhost}" = "vultr" ] )
then
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
    /bin/sleep 1
    os_choice="`/bin/echo "${os_choice}" | /bin/sed "s/'//g"`"
    os_choice="`/usr/bin/vultr os | /bin/grep "${os_choice}" | /usr/bin/awk '{print $1}'`"
    if ( [ "${snapshot_id}" != "" ] )
    then
        /usr/bin/vultr server create --name="${server_name}" --region="${region}" --plan="${server_plan}" --os="164" --private-networking=true --ipv6=false -k ${key_id} --snapshot="${snapshot_id}"
    else
        /usr/bin/vultr server create --name="${server_name}"  --region=${region} --plan=${server_plan} --os=${os_choice} --private-networking=true --ipv6=false -k ${key_id}
    fi
fi

os_choice="`/bin/echo ${1} | tr -d \'`"
region="${2}"
server_size="${3}"
server_name="${4}"
key_id="${5}"
cloudhost="${6}"
subnet_id="${7}"
snapshot_id="${8}"

if ( [ "${cloudhost}" = "aws" ] )
then
    vpc_id="`/usr/bin/aws ec2 describe-subnets | /usr/bin/jq '.Subnets[] | .SubnetId + " " + .VpcId' | /bin/sed 's/\"//g' | /bin/grep ${subnet_id}  | /usr/bin/awk '{print $2}'`"
    security_group_id="`/usr/bin/aws ec2 describe-security-groups | /usr/bin/jq '.SecurityGroups[] | .GroupName + " " + .GroupId' | /bin/grep AgileDeploymentToolkitSecurityGroup | /bin/sed 's/\"//g' | /usr/bin/awk '{print $NF}'`"

    if ( [ "${security_group_id}" = "" ] )
    then
        /usr/bin/aws ec2 create-security-group --description "This is the security group for your agile deployment toolkit" --group-name "AgileDeploymentToolkitSecurityGroup" --vpc-id=${vpc_id}
        security_group_id="`/usr/bin/aws ec2 describe-security-groups | /usr/bin/jq '.SecurityGroups[] | .GroupName + " " + .GroupId' | /bin/grep AgileDeploymentToolkitSecurityGroup | /bin/sed 's/\"//g' | /usr/bin/awk '{print $NF}'`"
    fi

    /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=tcp,FromPort=0,ToPort=65535,IpRanges='[{CidrIp=0.0.0.0/0}]'
    /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=icmp,FromPort=-1,ToPort=-1,IpRanges='[{CidrIp=0.0.0.0/0}]'


    if ( [ "${snapshot_id}" = "" ] )
    then
        /usr/bin/aws ec2 run-instances --image-id ${os_choice} --count 1 --instance-type ${server_size} --key-name ${key_id} --tag-specifications "ResourceType=instance,Tags=[{Key=descriptiveName,Value=${server_name}}]" --subnet-id ${subnet_id} --security-group-ids ${security_group_id}
    else
        /usr/bin/aws ec2 run-instances --count 1 --instance-type ${server_size} --key-name ${key_id} --tag-specifications "ResourceType=instance,Tags=[{Key=descriptiveName,Value=${server_name}}]" --subnet-id ${subnet_id} --security-group-ids ${security_group_id} --image-id ${snapshot_id}
    fi
fi


