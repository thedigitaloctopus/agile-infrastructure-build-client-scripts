#!/bin/sh
##############################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description: This script presents the user with the choice of whcih region to deploy in. It will
# list the regions that are available for the current provider and ask the user to select one of
# them to deploy to. Generally the region should be geographically closest to wherever the bulk
# of the users will be.
# It also allows the user to select a size for each of the machines that will be running in the
# infrastructure. Again, it presents a list of sizes to the user which are specific to that cloud
# provider and ask the user to select one of them for each machine type. For more information on the
# full specification of each machine size, please refer to the specific provider's documentation
################################################################################################
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
#################################################################################################
#################################################################################################
#set -x

sizes="`${BUILD_HOME}/providerscripts/cloudhost/ListAvailableSizes.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"
regions="`${BUILD_HOME}/providerscripts/cloudhost/ListAvailableRegions.sh ${CLOUDHOST}`"

if ( [ "${PREVIOUS_BUILD_CONFIG}" = "0" ] )
then

    status "################################################################################################################"
    status "##### We need to select a region to deploy our infrastructure in                                           #####"
    status "################################################################################################################"
    found="0"
    while ( [ "${found}" = "0" ] )
    do
        /bin/echo "Please select from the following list of regions to deploy. Select by typing its slug"
        /bin/echo ${regions} >&3
        read region
        for region1 in ${regions}
        do
            if ( [ "${region1}" = "${region}" ] )
            then
                found="1"
            fi
        done
        if ( [ "${found}" = "0" ] )
        then
            status "Sorry that's not a valid region"
        fi
    done

    REGION_ID="`${BUILD_HOME}/providerscripts/cloudhost/GetRegion.sh ${region} ${CLOUDHOST}`"

    ################################################################################################################################################

    if ( [ "${DATABASE_INSTALLATION_TYPE}" != "None" ] )
    then
        status "##################################################################################################################################"
        status "##### You need to select a size for your database server                                                                    #####"
        status "##### Note, please choose a reasonable size for your database server memory, you know, 512mb is not sufficient               #####"
        status "##################################################################################################################################"

        while ( [ "${DB_SERVER_TYPE}" = "" ] )
        do
            found="0"
            while ( [ "${found}" = "0" ] )
            do
                /bin/echo "Please select from the following list of sizes to deploy for your database. Select a size by typing its slug"
                /bin/echo ${sizes} >&3
                read size

                for size1 in ${sizes}
                do
                    if ( [ "${size1}" = "${size}" ] )
                    then
                        found="1"
                    fi
                done

                if ( [ "${found}" = "0" ] )
                then
                    status "Sorry that's not a valid size"
                fi
            done

            DB_SIZE=${size}
            DB_SERVER_TYPE="`${BUILD_HOME}/providerscripts/server/GetServerTypeID.sh ${DB_SIZE} "DATABASE" ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"
            if ( [ "${DB_SERVER_TYPE}" = "" ] )
            then
                status "It seems as if that server type isn't currently available, please try making another choice"
            fi
        done
    fi


    status "###############################################################################################################################"
    status "##### We need to select a machine size for our webserver(s)                                                               #####"
    status "#####Note, please choose a reasonable size for your webserver memory, you know, 512mb is not sufficient                   #####"
    status "###############################################################################################################################"


    while ( [ "${WS_SERVER_TYPE}" = "" ] )
    do
        found="0"
        while ( [ "${found}" = "0" ] )
        do
            status "Please select from the following list of sizes for your webserver. Select a size by typing its slug."
            /bin/echo ${sizes} >&3
            read size

            for size1 in ${sizes}
            do
                if ( [ "${size1}" = "${size}" ] )
                then
                    found="1"
                fi
            done

            if ( [ "${found}" = "0" ] )
            then
                status "Sorry that's not a valid size"
            fi
        done
        WS_SIZE=${size}
        WS_SERVER_TYPE="`${BUILD_HOME}/providerscripts/server/GetServerTypeID.sh ${WS_SIZE} "WEBSERVER" ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"

        status "Bearing in mind that you have selected a webserver size of ${WS_SIZE} please tell us how many webservers you wish to deploy"
        read NUMBER_WS

        if ( [ $NUMBER_WS -gt 0 ] )
        then
            status "Thanks...."
        else
            status "That doesn't appear to be a number, please try again"
            read NUMBER_WS
        fi

        if ( [ "${WS_SERVER_TYPE}" = "" ] )
        then
            status "It seems as if that server type isn't currently available, please try making another choice"
        fi
    done
fi

###########################################################################################################################################################

status "####################################################################################################################################################"
status "Do you wish to directly mount your image/media assets from a shared directory onto your webserver(s)?"
status "####################################################################################################################################################"
status "IF YOU USE MULTIPLE WEBSERVERS, AND SESSIONS ARE NOT PERSISTED TO THE DATABASE, YOUR ASSETS WILL NEED TO BE SHARED AMONG "
status "THEM BY SELECTING THIS OPTION AND THE SESSION PATH IN YOUR APPLICATION SET TO THE SHARED IMAGE/MEDIA DIRECTORY PATH SO THE"
status "SESSION DATA CAN BE WRITTEN THERE"
status "####################################################################################################################################################"
status "Do you wish to store your assets in a shared filesystem either in the cloud of with an elastic file system when supported?"
status "Please enter (Y|y) or (N|n)"
read response

if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
then
    PERSIST_ASSETS_TO_CLOUD="1"
else
    PERSIST_ASSETS_TO_CLOUD="0"
fi

###########################################################################################################################################################

if ( [ "${PREVIOUS_BUILD_CONFIG}" = "0" ] )
then
    status "#####################################################################################################################"
    status "##### We need to select a size of machine on which to run our autoscaler                                        #####"
    status "#####################################################################################################################"

    while ( [ "${AS_SERVER_TYPE}" = "" ] )
    do
        found="0"
        while ( [ "${found}" = "0" ] )
        do
            /bin/echo "Please select from the following list of sizes to deploy for your autoscaler. Select a size by typing its slug"
            /bin/echo ${sizes} >&3
            read size

            for size1 in ${sizes}
            do
                if ( [ "${size1}" = "${size}" ] )
                then
                    found="1"
                fi
            done
            if ( [ "${found}" = "0" ] )
            then
                status "Sorry that's not a valid size"
            fi
        done

        AS_SIZE=${size}
        AS_SERVER_TYPE="`${BUILD_HOME}/providerscripts/server/GetServerTypeID.sh ${AS_SIZE} "AUTOSCALER" ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"

        if ( [ "${AS_SERVER_TYPE}" = "" ] )
        then
            status "It seems as if that server type isn't currently available, please try making another choice"
        fi
    done
fi
