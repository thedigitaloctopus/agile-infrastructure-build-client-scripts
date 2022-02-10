#!/bin/bash
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2021
# Description : This is a script which enables you to shortcut the deployment of DBaaS systems
# when using the hardcore or expedited build. You do it by setting the DATABASE_DBaaS_INSTALLATION_TYPE
# variable in the way described for each provider. When set as described for your provider,
# when you make the deployment this script will try and spin up a DBaaS system and use that. 
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
#########################################################################################################
#DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:mysql:lon1:1:db-s-1vcpu-1gb:8:testdbcluster1:testdb1"
#DATABASE_DBaaS_INSTALLATION_TYPE="Postgres:DBAAS:pg:lon1:1:db-s-1vcpu-1gb:8:testdbcluster1:testdb1"
#########################################################################################################

if ( [ "${CLOUDHOST}" = "digitalocean" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
then
    if ( [ "`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/grep DBAAS`" != "" ] )
    then
        database_details="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/sed 's/^.*DBAAS://g'`"
        CLUSTER_ENGINE="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $1}'`"
        CLUSTER_REGION="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $2}'`"
        CLUSTER_NODES="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $3}'`"
        CLUSTER_SIZE="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $4}'`"
        CLUSTER_VERSION="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $5}'`"
        CLUSTER_NAME="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $6}'`"
        DATABASE_NAME="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $7}'`"
    fi
    
    status "Configuring database cluster ${CLUSTER_NAME}, please wait..."

    cluster_id="`/usr/local/bin/doctl databases list | /bin/grep ${CLUSTER_NAME} | /usr/bin/awk '{print $1}'`"
    
    if ( [ "${cluster_id}" = "" ] )
    then
        status "Creating the database cluster ${CLUSTER_NAME}"
        
        /usr/local/bin/doctl databases create ${CLUSTER_NAME} --engine ${CLUSTER_ENGINE} --region ${CLUSTER_REGION}  --num-nodes ${CLUSTER_NODES} --size ${CLUSTER_SIZE} --version ${CLUSTER_VERSION} 
        if ( [ "$?" != "0" ] )
        then
            status "I had trouble creating the database cluster will have to exit....."
            exit
        fi
    fi

    while ( [ "${cluster_id}" = "" ] )
    do
        status "Trying to obtain cluster id for the ${CLUSTER_NAME} cluster..."
        cluster_id="`/usr/local/bin/doctl databases list | /bin/grep ${CLUSTER_NAME} | /usr/bin/awk '{print $1}'`"
        /bin/sleep 30
    done
    
    status "Tightening the firewall on your database cluster"
    
    uuids="`/usr/local/bin/doctl databases firewalls list ${cluster_id} | /usr/bin/tail -n +2 | /usr/bin/awk '{print $1}'`"

    for uuid in ${uuids}  
    do
        /usr/local/bin/doctl databases firewalls remove ${uuid}
    done
    
 #   /usr/local/bin/doctl databases firewalls append ${cluster_id} --rule ip_addr:${BUILD_CLIENT_IP}    
   
    status "Creating a database neame ${DATABASE_NAME} in cluster: ${cluster_id}"
    
    /usr/local/bin/doctl databases db create ${cluster_id} ${DATABASE_NAME}

    while ( [ "`/usr/local/bin/doctl databases db list ${cluster_id} ${DATABASE_NAME} | /bin/grep ${DATABASE_NAME}`" = "" ] )
    do
        status "Probing for a database called ${DATABASE_NAME} in the cluster called ${CLUSTER_NAME} - Please Wait...."
        /bin/sleep 30
        /usr/local/bin/doctl databases db create ${cluster_id} ${DATABASE_NAME}
    done
    
    status "######################################################################################################################################################"
    status "You might want to check that a database cluster called ${CLUSTER_NAME} with a database ${DATABASE_NAME} is present using your Digital Ocean gui system"
    status "######################################################################################################################################################"
    status "Press <enter> when you are satisfied"
    read x

    if ( [ "${CLUSTER_ENGINE}" = "mysql" ] )
    then
        export DATABASE_DBaaS_INSTALLATION_TYPE="MySQL"
    elif ( [ "${CLUSTER_ENGINE}" = "postgres" ] )
    then
        export DATABASE_DBaaS_INSTALLATION_TYPE="Postgres"
    fi
    
    export DATABASE_INSTALLATION_TYPE="DBaaS"
    export DATABASE_DBaaS_INSTALLATION_TYPE="${DATABASE_DBaaS_INSTALLATION_TYPE}:${cluster_id}"
    export DBaaS_HOSTNAME="`/usr/local/bin/doctl databases connection ${cluster_id} | /usr/bin/awk '{print $3}' | /usr/bin/tail -1`"
    export DBaaS_USERNAME="`/usr/local/bin/doctl databases user list ${cluster_id} | /usr/bin/awk '{print $1}' | /usr/bin/tail -1`"
    export DBaaS_PASSWORD="`/usr/local/bin/doctl databases user list ${cluster_id} | /usr/bin/awk '{print $3}' | /usr/bin/tail -1`"
    export DBaaS_DBNAME="${DATABASE_NAME}"
    export DB_PORT="25060"
    
    status "The Values I have retrieved for your database setup are:"
    status "##########################################################"
    status "HOSTNAME:${DBaaS_HOSTNAME}"
    status "USERNAME:${DBaaS_USERNAME}"
    status "PASSWORD:${DBaaS_PASSWORD}"
    status "PORT:${DB_PORT}"
    status "##########################################################"
    status "If these settings look OK to you, press <enter>"
    read x
fi


#########################################################################################################
#DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:mysql:ch-gva-2:hobbyist-1:testdb1"
#DATABASE_DBaaS_INSTALLATION_TYPE="Postgres:DBAAS:pg:ch-gva-2:hobbyist-1:testdb1"
#########################################################################################################
if ( [ "${CLOUDHOST}" = "exoscale" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
then
    if ( [ "`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/grep DBAAS`" != "" ] )
    then
        database_details="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/sed 's/^.*DBAAS://g'`"
        DATABASE_ENGINE="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $1}'`"
        DATABASE_REGION="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $2}'`"
        DATABASE_SIZE="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $3}'`"
        DATABASE_NAME="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $4}'`"
    fi
    
    status "Creating  database ${DATABASE_NAME}, with engine: ${DATABASE_ENGINE}, in region: ${DATABASE_REGION} and at size: ${DATABASE_SIZE} please wait..."

    /usr/bin/exo -O json dbaas create ${DATABASE_ENGINE} ${DATABASE_SIZE} ${DATABASE_NAME} -z ${DATABASE_REGION}
    database_name="`/usr/bin/exo -O json dbaas list | /usr/bin/jq '(.[] | .name)' | /bin/sed 's/\"//g' | /bin/grep ${DATABASE_NAME}`"


    while ( [ "${database_name}" = "" ] )
    do
        status "Creating the database named ${DATABASE_NAME}"

        /usr/bin/exo -O json lab database create ${DATABASE_ENGINE} ${DATABASE_SIZE} ${DATABASE_NAME} -z ${DATABASE_REGION}
        database_name="`/usr/bin/exo -O json dbaas list | /usr/bin/jq '(.[] | .name)' | /bin/sed 's/\"//g' | /bin/grep ${DATABASE_NAME}`"
        
        if ( [ "${database_name}" = "" ] )
        then
            status "I had trouble creating the database will have to exit....."
            status "Trying again....."
            /bin/sleep 30
       fi
    done

    status "######################################################################################################################################################"
    status "You might want to check that a database called ${DATABASE_NAME} is present using your Exoscale GUI system"
    status "######################################################################################################################################################"
    status "Press <enter> when you are satisfied"
    read x

    export DATABASE_INSTALLATION_TYPE="DBaaS"
    export DBaaS_HOSTNAME="`/usr/bin/exo -O json dbaas show -z ${DATABASE_REGION} ${DATABASE_NAME} | /usr/bin/jq ".${DATABASE_ENGINE}.uri_params.host" | /bin/sed 's/\"//g'`"

    while ( [ "${DBaaS_PASSWORD}" = "" ] || [ "${DBaaS_USERNAME}" = "" ] )
    do
        status "Trying to obtain database credentials...This might take a couple of minutes as the new database initialises..."
        /bin/sleep 10
        export DBaaS_USERNAME="`/usr/bin/exo -O json dbaas show -z ${DATABASE_REGION} ${DATABASE_NAME} | /usr/bin/jq ".${DATABASE_ENGINE}.uri_params.user" | /bin/sed 's/\"//g'`"
        export DBaaS_PASSWORD="`/usr/bin/exo -O json dbaas show -z ${DATABASE_REGION} ${DATABASE_NAME} | /usr/bin/jq ".${DATABASE_ENGINE}.uri_params.password" | /bin/sed 's/\"//g'`"
    done   
    
    export DBaaS_DBNAME="${DATABASE_NAME}"
    export DB_PORT="`/usr/bin/exo -O json dbaas show -z ${DATABASE_REGION} ${DATABASE_NAME} | /usr/bin/jq ".${DATABASE_ENGINE}.uri_params.port" | /bin/sed 's/\"//g'`"

    status "The Values I have retrieved for your database setup are:"
    status "##########################################################"
    status "HOSTNAME:${DBaaS_HOSTNAME}"
    status "USERNAME:${DBaaS_USERNAME}"
    status "PASSWORD:${DBaaS_PASSWORD}"
    status "PORT:${DB_PORT}"
    status "##########################################################"
    status "If these settings look OK to you, press <enter>"
    read x
fi

#########################################################################################################
#DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:mysql:eu-west-1b:db.t3.micro:TestDatabase:testdb4:20:2035:testdatabaseuser1:ghdbRtjh=g"
#DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:mariadb:eu-west-1a:db.t3.micro:TestDatabase:testdb1:20:2035:testdatabaseuser1:ghdbRtjh=g"
#DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:postgres:eu-west-1a:db.t3.micro:TestDatabase:testdb1:20:2035:testdatabaseuser1:ghdbRtjh=g"
#########################################################################################################

if ( [ "${CLOUDHOST}" = "aws" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
then
    if ( [ "`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/grep DBAAS`" != "" ] )
    then
        DATABASE_TYPE="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $1}'`"
        database_details="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/sed 's/^.*DBAAS://g'`"
        DATABASE_ENGINE="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $1}'`"
        DATABASE_REGION="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $2}'`"
        DATABASE_SIZE="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $3}'`"
        DATABASE_NAME="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $4}'`"
        DATABASE_IDENTIFIER="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $5}'`"
        ALLOCATED_STORAGE="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $6}'`"
        DB_PORT="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $7}'`"
        DATABASE_USERNAME="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $8}'`"
        DATABASE_PASSWORD="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $9}'`"

        vpc_id="`/usr/bin/aws ec2 describe-subnets | /usr/bin/jq '.Subnets[] | .SubnetId + " " + .VpcId' | /bin/sed 's/\"//g' | /bin/grep ${SUBNET_ID}  | /usr/bin/awk '{print $2}'`"
        security_group_id="`/usr/bin/aws ec2 describe-security-groups | /usr/bin/jq '.SecurityGroups[] | .GroupName + " " + .GroupId' | /bin/grep AgileDeploymentToolkitSecurityGroup | /bin/sed 's/\"//g' | /usr/bin/awk '{print $NF}'`"

        if ( [ "${security_group_id}" != "" ] )
        then
            /usr/bin/aws ec2 revoke-security-group-ingress --group-id ${security_group_id}  --ip-permissions  "`/usr/bin/aws ec2 describe-security-groups --output json --group-ids ${security_group_id} --query "SecurityGroups[0].IpPermissions"`"    
        else
            /usr/bin/aws ec2 create-security-group --description "This is the security group for your agile deployment toolkit" --group-name "AgileDeploymentToolkitSecurityGroup" --vpc-id=${vpc_id}
        fi

        security_group_id="`/usr/bin/aws ec2 describe-security-groups | /usr/bin/jq '.SecurityGroups[] | .GroupName + " " + .GroupId' | /bin/grep AgileDeploymentToolkitSecurityGroup | /bin/sed 's/\"//g' | /usr/bin/awk '{print $NF}'`"

        security_group_id1="`/usr/bin/aws ec2 describe-security-groups | /usr/bin/jq '.SecurityGroups[] | .GroupName + " " + .GroupId' | /bin/grep AgileDeploymentToolkitWebserversSecurityGroup | /bin/sed 's/\"//g' | /usr/bin/awk '{print $NF}'`"


        if ( [ "${security_group_id1}" != "" ] )
        then
            /usr/bin/aws ec2 revoke-security-group-ingress --group-id ${security_group_id1}  --ip-permissions  "`/usr/bin/aws ec2 describe-security-groups --output json --group-ids ${security_group_id1} --query "SecurityGroups[0].IpPermissions"`"    
        else
            /usr/bin/aws ec2 create-security-group --description "This is the security group for your agile deployment toolkit" --group-name "AgileDeploymentToolkitWebserversSecurityGroup" --vpc-id=${vpc_id}
        fi

        security_group_id1="`/usr/bin/aws ec2 describe-security-groups | /usr/bin/jq '.SecurityGroups[] | .GroupName + " " + .GroupId' | /bin/grep AgileDeploymentToolkitWebserversSecurityGroup | /bin/sed 's/\"//g' | /usr/bin/awk '{print $NF}'`"

        /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=tcp,FromPort=0,ToPort=65535,IpRanges='[{CidrIp=0.0.0.0/0}]'
        /usr/bin/aws ec2 authorize-security-group-ingress --group-id ${security_group_id} --ip-permissions IpProtocol=icmp,FromPort=-1,ToPort=-1,IpRanges='[{CidrIp=0.0.0.0/0}]'
    
        /usr/bin/aws rds delete-db-subnet-group --db-subnet-group-name "AgileDeploymentToolkitSubnetGroup" 
        /usr/bin/aws rds create-db-subnet-group --db-subnet-group-name "AgileDeploymentToolkitSubnetGroup" --db-subnet-group-description "Agile Deployment DB subnet group" --subnet-ids "${SUBNET_ID}" "${SUBNET_ID1}"

        /usr/bin/aws rds create-db-instance --db-name "${DATABASE_NAME}" --db-instance-identifier "${DATABASE_IDENTIFIER}" --allocated-storage "${ALLOCATED_STORAGE}" --db-instance-class "${DATABASE_SIZE}" --engine "${DATABASE_ENGINE}" --master-username "${DATABASE_USERNAME}"  --master-user-password "${DATABASE_PASSWORD}" --availability-zone "${DATABASE_REGION}" --db-subnet-group-name agiledeploymentdbsubnetgroup --port ${DB_PORT} --no-publicly-accessible  --storage-encrypted --vpc-security-group-ids ${security_group_id} ${security_group_id1} --db-subnet-group-name "AgileDeploymentToolkitSubnetGroup"

        if ( [ "$?" = "0" ] )
        then
            db_name=""
            while ( [ "${db_name}" = "" ] )
            do
                endpoints="`/usr/bin/aws rds describe-db-instances | /usr/bin/jq '.DBInstances[] | .Endpoint | .Address' | /bin/sed 's/\"//g' | /usr/bin/tr '\n' ' '`"
                for endpoint in ${endpoints}
                do
                    db_name="`/bin/echo ${endpoint} | /usr/bin/awk -F'.' '{print $1}'`"
                    if ( [ "${db_name}" = "null" ] )
                    then
                        db_name=""
                    fi
                    if ( [ "${db_name}" = "${DATABASE_IDENTIFIER}" ] )
                    then
                        export DBaaS_HOSTNAME="${endpoint}"
                        export DATABASE_DBaaS_INSTALLATION_TYPE="${DATABASE_TYPE}"
                        export DBaaS_USERNAME="${DATABASE_USERNAME}"
                        export DBaaS_PASSWORD="${DATABASE_PASSWORD}"
                        export DBaaS_DBNAME="${db_name}"
                   fi
               done
               status "Setting up and configuring your database, waiting for database endpoint to become available. Will try again in 30 seconds"
               status "It may take 5 minutes or more for your database to come online"
               status "#########################################################################################################################"
               /bin/sleep 30
           done
       fi
    fi
fi
