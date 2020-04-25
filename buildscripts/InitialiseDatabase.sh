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
        status "#### 2)3rd Party DBaaS (insecure - direct to database, no encryption, OK, if your database server is on same private     ####"
        status "####                    network as your database client or application)                                                  ####"
        status "#### 3)3rd Party DBaaS (secured - via an ssh tunnel, encrypted of use if your db connection is over the public network or####"
        status "####                    internet. Will require that you set up a local (to your DB) tunneling machine)                   ####"
        status "#### Please Enter 1,2 or 3                                                                                               ####"
        status "#############################################################################################################################"
        read userresponse

        while ( [ "${userresponse}" = "" ] || [ "`/bin/echo 1 2 3 | /bin/grep ${userresponse}`" = "" ] )
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
            status "If your provider assigns security groups to your database, please can you tell us the identifier for the security group your"
            status "Database is assigned to. For example, on AWS, it is likely to be something like, sg-0fad5hf744c044361 press <enter> for no group"
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
        if ( [ "${userresponse}" = "3" ] )
        then
            DATABASE_INSTALLATION_TYPE="DBaaS-secured"

            status "Right on. You have chosen to use DBaaS. I can't know what DBaaS provider you are using or what database types they support, but"
            status "Here is what we support, so, please choose what you want type of DBaaS you want to use from this list."
            status "At the moment, we support 1) MYSQL (Maria DB) 2) PostgreSQL"
            read response

            while ( [ "${response}" = "" ] || [ "`/bin/echo 1 2  | /bin/grep ${response}`" = "" ] )
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

            status "###########################################################################################################################"
            status "####Please ensure you have started a database of the requisite size with the DBaaS service provider of your choice     ####"
            status "####Also, you need to spin up a standard (small) cloud server to use for the SSH tunnel to your Database               ####"
            status "####Please also ensure that you have set up an SSH KeyPair for your new cloud host server and switched off             ####"
            status "####password based authentication.                                                                                     ####"
            status "####If you don't know how to do these things, please refer to your chosen provider's documentation                     ####"
            status "####Press the <enter> key when this is done (you can test the connection from your build client if you like, using ssh)####"
            status "###########################################################################################################################"

            status ""
            status "##############################################################################################################"
            status "####You should have set a username and password for your database with your provider.                     ####"
            status "####Can you please enter the username for your database:                                                  ####"
            status "##############################################################################################################"
            read DBaaS_USERNAME

            status ""
            status "##############################################################################################################"
            status "####Can you please enter the password for your database:                                                  ####"
            status "##############################################################################################################"
            read DBaaS_PASSWORD

            status ""
            status "##############################################################################################################"
            status "####You should also have given your database a name. Please enter the name of your database here:         ####"
            status "##############################################################################################################"
            read DBaaS_DBNAME

            status ""
            status "#############################################################################################################################################"
            status "####It is necessary to know the IP or dns hostname of the cloud server local to your database (the same cloud host) which will be a relay  ####"
            status "####For the ssh tunnel to the database. If you need to know more, plese look in ${BUILD_HOME}/doco/AgileToolkitDeployment/DeployingDBaaS.md####"
            status "####So, please enter the PUBLIC ip or dns hostname address of your server local to your database (same cloudhost, same region)             ####"
            status "####Note, it is possible to set up multiple ssh tunnel machines and their ip addresses are allocated to webservers to use in a round robin ####"
            status "####Fashion. To do this, make sure your ip addresses are well formed and enter them here as a colon separated list, for example            ####"
            status "xxx.xxx.xxx.xxx:yyy.yyy.yyy.yyy:zzz.zzz.zzz.zzz. This list of ip addresses will then be considered valid ssh tunnel machines all leading   ####"
            status "to the same database in the end"
            status "###############################################################################################################################################"
            read DBaaS_REMOTE_SSH_PROXY_IP

            status ""
            status "#######################################################################################################################################"
            status "####Just to complicate things, sometimes linux is deployed with a different default user other than root sometimes, it is 'ubuntu' ####"
            status "####When we are secure shelling onto your ssh tunnel cloud server, we need to make sure we get the default user name right         ####"
            status "####So, it is probably root, but check with your provider how they set up the default user                                         ####"
            status "####So, please input the default user for your DBaaS cloud host, probably 'root', but please check                                 ####"
            status "#######################################################################################################################################"
            read DEFAULT_DBaaS_OS_USER

            status ""
            status "##############################################################################################################################"
            status "####Please enter your the private key of your ssh keys to your cloud host server hosted locally to your BBaaS database    ####"
            status "##############################################################################################################################"

            if ( [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/dbaas_server_key.pem ] )
            then
                status ""
                status "Hi there. I have found an ssh private key for your remote relay server to your DBaaS cloud host, do you want me to use that? (Y|N)"
                read response

                if ( [ "${response}" != "Y" ]  && [ "${response}" != "y" ] )
                then
                    status ""
                    status  "OK, please paste your the private key to your cloud host server hosted locally to your DBaaS database <enter> then <ctrl-D> to complete"
                    DBaaS_SERVER_KEY=`cat`
                    /bin/echo "${DBaaS_SERVER_KEY}" | /bin/sed '/^$/d' > ${BUILD_HOME}/ssl/${WEBSITE_URL}/dbaas_server_key.pem
                    /bin/chmod 400 ${BUILD_HOME}/ssl/${WEBSITE_URL}/dbaas_server_key.pem

                    testip="`/bin/echo ${DBaaS_REMOTE_SSH_PROXY_IP} | /usr/bin/awk -F':' '{print $1}'`"

                    /usr/bin/ssh -o StrictHostKeyChecking=no -p 22 -i ${BUILD_HOME}/ssl/${WEBSITE_URL}/dbaas_server_key.pem ${DEFAULT_DBaaS_OS_USER}@${testip} 'exit'

                    if ( [ "$?" != "0" ] )
                    then
                        status "It seems like that's not the right certificate. Exiting..."
                        exit
                    fi
                fi
            else
                success="0"
                while ( [ "${success}" = "0" ] )
                do
                    status ""
                    status "#################################################################################################################################################"
                    status "OK, please paste your the private key of your ssh keys to your cloud host server hosted locally to your DBaaS database <ctrl-D> to complete  ####"
                    status "#################################################################################################################################################"
                    DBaaS_SERVER_KEY=`cat`
                    /bin/mkdir -p ${BUILD_HOME}/ssl/${WEBSITE_URL}
                    /bin/echo "${DBaaS_SERVER_KEY}" > ${BUILD_HOME}/ssl/${WEBSITE_URL}/dbaas_server_key.pem
                    /bin/chmod 400 ${BUILD_HOME}/ssl/${WEBSITE_URL}/dbaas_server_key.pem

                    testip="`/bin/echo ${DBaaS_REMOTE_SSH_PROXY_IP} | /usr/bin/awk -F':' '{print $1}'`"

                    /usr/bin/ssh -o StrictHostKeyChecking=no -p 22 -i ${BUILD_HOME}/ssl/${WEBSITE_URL}/dbaas_server_key.pem ${DEFAULT_DBaaS_OS_USER}@${testip} 'exit'

                    if ( [ "$?" != "0" ] )
                    then
                        status "It seems like that's not the right certificate. Let's try again...."
                        success="0"
                    else
                        success="1"
                    fi
                done
            fi

            status ""
            status "#############################################################################################################################################"
            status "####Also, please tell us the endpoint of your database in the cloud. Please enter the name of your database here:           ####"
            status "####Using amazon as an example, this should be something like: tester.crvxjfddo74b.eu-west-1.rds.amazonaws.com                           ####"
            status "####SPECIAL NOTICE - be aware that there is no port number on there and the port used by your database in the cloud should be: ${DB_PORT}####"
            status "#############################################################################################################################################"
            read DBaaS_HOSTNAME

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


