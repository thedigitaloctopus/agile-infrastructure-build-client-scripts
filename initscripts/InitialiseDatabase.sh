#!/bin/sh
###########################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script allows the user to select which type of database deployment they
# wish to have. They can have either a single instance deployment or a DBaaS deployment
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
    status "####################################"
    status "Would you like to install a database"
    status "####################################"
    status "Please enter (Y|y) to install a database"
    read response

    while ( [ "${response}" = "" ] || [ "`/bin/echo "y Y n N" | /bin/grep ${response}`" = "" ] )
    do
        status "Invalid response...."
        status "Would you like to install a database"
        status "Please enter (Y|y) to install a database"
        read response
    done

    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        status "#############################################################################################################################"
        status "#### Would you like to install                                                                                           ####"
        status "#### 1)Single Database Instance                                                                                          ####"
        status "#### 2)Managed Database (DBaaS)                                                                                          ####"
        status "#### Please Enter 1 or 2                                                                                                 ####"
        status "#############################################################################################################################"
        read userresponse

        while ( [ "${userresponse}" = "" ] || [ "`/bin/echo 1 2 | /bin/grep ${userresponse}`" = "" ] )
        do
            status "Invalid input, please try again"
            read userresponse
        done

        if ( [ "${userresponse}" = "1" ] )
        then
            status "Which database type would you like to install?"
            status "At the moment, we support 1) Maria DB  2) PostgreSQL 3) MySQL"
            read response
            while ( [ "${response}" = "" ] || [ "`/bin/echo 1 2 3 | /bin/grep ${response}`" = "" ] )
            do
                status "Invalid input, please try again"
                read response
            done
            if ( [ "${response}" = "1" ] )
            then
                DATABASE_INSTALLATION_TYPE="Maria"
            fi
            if ( [ "${response}" = "2" ] )
            then
                DATABASE_INSTALLATION_TYPE="Postgres"
            fi
            if ( [ "${response}" = "3" ] )
            then
                DATABASE_INSTALLATION_TYPE="MySQL"
            fi
        fi
        
        if ( [ "${userresponse}" = "2" ] )
        then
            DATABASE_INSTALLATION_TYPE="DBaaS"

            status "Right on. You have chosen to use DBaaS. I can't know what DBaaS provider you are using or what database types they support, but"
            status "Here is what we support, so, please choose what you want type of DBaaS you want to use from this list."
            status "At the moment, we support 1) MYSQL (Maria DB)  2) PostgreSQL"
            read response

            while ( [ "${response}" = "" ] || [ "`/bin/echo 1 2 | /bin/grep ${response}`" = "" ] )
            do
                status "Invalid input, please try again"
                read response
            done

            if ( [ "${response}" = "1" ] )
            then
                DATABASE_DBaaS_INSTALLATION_TYPE="Maria"
            fi

            if ( [ "${response}" = "2" ] )
            then
                DATABASE_DBaaS_INSTALLATION_TYPE="Postgres"
            fi

            status "###############################################################################################################################"
            status "Can you please tell me the endpoint of your database. This might take the form tester.cdfij3fddo74b.eu-west-1.rds.amazonaws.com"
            status "###############################################################################################################################"
            read DBaaS_HOSTNAME

            status "#############################################################################################"
            status "You should have set a username and password for your database with your provider."
            status "Can you please enter the username for your database:"
            status "#############################################################################################"
            read DBaaS_USERNAME

            status "####################################################"
            status "Can you please enter the password for your database:"
            status "####################################################"
            read DBaaS_PASSWORD

            status "#############################################################################################"
            status "You should also have given your database a name. Please enter the name of your database here:"
            status "#############################################################################################"
            read DBaaS_DBNAME
            
            status "############################################################################################################################"
            status "If your provider uses security groups, you should check if a security group called AgileDeploymentToolkitSecurityGroup has been created"
            status "for your account. If it hasn't you should create a security group called precisely AgileDeploymentToolkitSecurityGroup and assign it to your managed database"
            status "You should then tell us the security group ID here by entering it below. For AWS this will likely have a format something like: sg-0fad5hf744c044361"
            status "Just press enter with no input if your provider doesn't use security groups"
            status "############################################################################################################################"
            read DBaaS_DBSECURITYGROUP

            status "Because you are installing DBaaS, if your database is large, you will want to manage it (backups and so on) from the DBaaS"
            status "provider you are using. This means that you won't be using the Agile Deployment Toolkit backups mechanism for your DB and therefore"
            status "Don't need to install the application db as it is expected to be already available in the DBaaS database"
            status "So, if you database is large, make sure it is installed fully with your DBaaS provider and secondly, make sure that your"
            status "backup periodicity set with the DBaaS provider synchronises with the backups being taken on the webserver for the application webr
            oot"
            status "########################################################################################################################"
            status "If you want to use a DB which is already available with your DBaaS provider and bypass the database installation process"
            status "of the agile deployment toolkit enter (Y|y)"
            read response
            if ( [ "`/bin/echo "Y y " | /bin/grep ${response}`" != "" ] )
            then
                BYPASS_DB_LAYER="1"
            fi
        fi
    else
        status "OK, your wish is my command, no database is being installed"
        DATABASE_INSTALLATION_TYPE="None"
    fi
fi


