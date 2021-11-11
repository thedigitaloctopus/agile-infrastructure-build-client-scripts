#!/bin/sh
#########################################################################################################
#DATABASE_DBaaS_INSTALLATION_TYPE="DBAAS:mysql:lon1:1:db-s-1vcpu-1gb:8:testdbcluster1:testdb1"
#########################################################################################################

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
    if ( [ "`/bin/echo ${DATABASE_INSTALLATION_TYPE} | /bin/grep DBAAS`" != "" ] )
    then
        database_details="`/bin/echo ${DATABASE_INSTALLATION_TYPE} | /bin/sed 's/^DBAAS://g'`"
        CLUSTER_ENGINE="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $1}'`"
        CLUSTER_REGION="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $2}'`"
        CLUSTER_NODES="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $3}'`"
        CLUSTER_SIZE="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $4}'`"
        CLUSTER_VERSION="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $5}'`"
        CLUSTER_NAME="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $6}'`"
        DATABASE_NAME="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $7}'`"
    fi

    /usr/local/bin/doctl databases create ${CLUSTER_NAME} --engine ${CLUSTER_ENGINE} --region ${CLUSTER_REGION}  --num-nodes ${CLUSTER_NODES} --size ${CLUSTER_SIZE} --version ${CLUSTER_VERSION} 

    cluster_id="`/usr/local/bin/doctl databases list | /bin/grep ${CLUSTER_NAME} | /usr/bin/awk '{print $1}'`"

    while ( [ "${cluster_id}" = "" ] )
    do
        cluster_id="`/usr/local/bin/doctl databases list | /bin/grep ${CLUSTER_NAME} | /usr/bin/awk '{print $1}'`"
        /bin/sleep 10
    done

    /usr/local/bin/doctl databases db create ${cluster_id} ${DATABASE_NAME}


    while ( [ "`/usr/local/bin/doctl databases db list ${cluster_id} ${DATABASE_NAME} | /bin/grep ${DATABASE_NAME}`" = "" ] )
    do
        /bin/sleep 10
    done

    if ( [ "${CLUSTER_ENGINE}" = "mysql" ] )
    then
        export DATABASE_DBaaS_INSTALLATION_TYPE="MySQL"
    elif ( [ "${CLUSTER_ENGINE}" = "postgres" ] )
    then
        export DATABASE_DBaaS_INSTALLATION_TYPE="Postgres"
    fi
   
    export DBaaS_HOSTNAME="`/usr/local/bin/doctl databases connection ${cluster_id} | /usr/bin/awk '{print $3}' | /usr/bin/tail -1`"
    export DBaaS_USERNAME="`/usr/local/bin/doctl databases user list ${cluster_id} | /usr/bin/awk '{print $1}' | /usr/bin/tail -1`"
    export DBaaS_PASSWORD="`/usr/local/bin/doctl databases user list ${cluster_id} | /usr/bin/awk '{print $3}' | /usr/bin/tail -1`"
    export DBaaS_DBNAME="${DATABASE_NAME}"
fi
