#!/bin/sh
##########################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will enable the user to choose what "datastore" provider they
# wish to choose. A datastore is a highly available webservice where arbitrary files and
# numbers of files can be stored. In ordinary usage, this datastore will be used to store
# images and media.
# This script also allows the user to elect to have "supersafe" backups made. What this means
# is that when a backup of the webroot or the database is run it stores a secondary backup
# to the user's elected datastore. This is super safe, because if anything happens to the
# ordinary backup, in the repository then you also have another one in the datastore to rely on. You
# know the old saying, backup, backup and backup again and so it is recommended to have "supersafe"
# backups switched on.
###########################################################################################
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
############################################################################################
############################################################################################
#set -x

if ( [ "${PREVIOUS_BUILD_CONFIG}" = "0" ] )
then

    status "##################################################################################################################################"
    status "You can pick one of these providers for your datastore provider. This is where your assets will be stored if you configure remote"
    status "Assets storage rather than storing them directly on your webserver. It is mandatory to use remote storage for assets if you have more"
    status "than one webserver in use"
    status "IMPORTANT: buckets have global namespace, so if you have deployed your application with it's assets in a bucket from a different"
    status "region with the same provider you are currently deploying to, you may experience a failure because the bucket will exist but will"
    status "not be accessible in or from your current region. In short, make sure that all the buckets your application requires can be created"
    status "in the region you are currently deployting to"
    status "We currently support  1: Amazon S3 2: Digital Ocean Spaces 3: Exoscale Object Store 4: Linode Object Store 5:Vultr Object Store"
    status "##################################################################################################################################"
    status "Please make you choice of datastore (1),(2),(3),(4),(5)"
    read choice

    while ( [ "`/bin/echo "1 2 3 4 5" | /bin/grep ${choice}`" = "" ] )
    do
        status "Invalid choice, please try again..."
        read choice
    done

    if ( [ "`/bin/echo ${choice} | /bin/grep '1'`" != "" ] )
    then
        DATASTORE_CHOICE="amazonS3"
        ${BUILD_HOME}/providerscripts/datastore/InitialiseDatastore.sh "${DATASTORE_CHOICE}" "${BUILDOS}"
    fi
    if ( [ "`/bin/echo ${choice} | /bin/grep '2'`" != "" ] )
    then
        DATASTORE_CHOICE="digitalocean"
        ${BUILD_HOME}/providerscripts/datastore/InitialiseDatastore.sh "${DATASTORE_CHOICE}" "${BUILDOS}"
    fi
    if ( [ "`/bin/echo ${choice} | /bin/grep '3'`" != "" ] )
    then
        DATASTORE_CHOICE="exoscale"
        ${BUILD_HOME}/providerscripts/datastore/InitialiseDatastore.sh "${DATASTORE_CHOICE}" "${BUILDOS}"
    fi
    if ( [ "`/bin/echo ${choice} | /bin/grep '4'`" != "" ] )
    then
        DATASTORE_CHOICE="linode"
        ${BUILD_HOME}/providerscripts/datastore/InitialiseDatastore.sh "${DATASTORE_CHOICE}" "${BUILDOS}"
    fi
    if ( [ "`/bin/echo ${choice} | /bin/grep '5'`" != "" ] )
    then
        DATASTORE_CHOICE="vultr"
        ${BUILD_HOME}/providerscripts/datastore/InitialiseDatastore.sh "${DATASTORE_CHOICE}" "${BUILDOS}"
    fi
    
    status "#################################################################################################################"
    status "Sometimes you can incur charge for 'data out' to the internet. If this is the case, you might want to switch off"
    status "hourly backups because if your application is several hundred megabytes, that mounts up to gigabytes per week of"
    status "hourly backups to your application git repo which can mean, in some cases, significant costs"
    status "in such a scenario, you would likely want to limit your backups to daily periodicity and more infrequently"
    status "Would you like to switch off or disable hourly backups to save costs?"
    status "#################################################################################################################"
    status "Please enter (Y|y) if you would like to disable hourly backups to your git repo"

    read answer

    if ( [ "${answer}" = "Y" ] || [ "${answer}" = "y" ] )
    then
        DISABLE_HOURLY="1"
        status "NOTE: if you now enable super safe backups, hourly backups will still be made to your datastore"
        status "Press the <enter> key to continue"
        read x
    else
        DISABLE_HOURLY="0"
    fi

    if ( [ "${DATASTORE_CHOICE}" != "none" ] )
    then
        status "############################################################################################################################"
        status "#####Super safe backups are additional backups to your repository backups (Super safe backups are highly recommended) ######"
        status "############################################################################################################################"
        status "Do you wish to have super safe backups of your webroot and database (if you have one) to your datastore of choice?"
        status "(Y/N)"
        read response

        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
        then
            SUPERSAFE_WEBROOT="1"
        fi

        if ( [ "${DATABASE_INSTALLATION_TYPE}" != "None" ] )
        then
            status "Do you wish to have super safe backups of your database to your datastore of choice?"
            status "(Y/N)"
            read response

            if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
            then
                SUPERSAFE_DB="1"
            fi
        fi
    fi
fi

