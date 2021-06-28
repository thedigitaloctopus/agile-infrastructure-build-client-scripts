#!/bin/sh
###########################################################################################
# Author: Peter Winter
# Date  : 13/7/2016
# Description : This script presents the user with the choice of which periodicity of backup
# to use when building the infrastructure and application.
# There are 6 periodicities to choose from as you can see in the "status" statements below
############################################################################################
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

backuprepository=""
backuparchive=""
USE_NEW="0"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"

if ( [ "${PREVIOUS_BUILD_CONFIG}" = "1" ] )
then
    status ""
    status ""
    status "Hey there. Do you want to use the same repository to build from as last time or use a new one(s)?"
    status "Enter (Y|y) to use the same sourcecode repository as the previous build. Enter anything else to use new ones"
    read response

    if ( [ "${response}" != "Y" ] && [ "${response}" != "y" ] )
    then
        USE_NEW="1"
    fi

    if ( [ "${BUILD_CHOICE}" = "2" ] )
    then
        backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-hourly-${BUILD_IDENTIFIER}"
        backuparchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-hourly/applicationsourcecode.tar.gz"
elif ( [ "${BUILD_CHOICE}" = "3" ] )
    then
        backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-daily-${BUILD_IDENTIFIER}"
        backuparchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-daily/applicationsourcecode.tar.gz"
elif ( [ "${BUILD_CHOICE}" = "4" ] )
    then
        backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-weekly-${BUILD_IDENTIFIER}"
        backuparchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-weekly/applicationsourcecode.tar.gz"
elif ( [ "${BUILD_CHOICE}" = "5" ] )
    then
        backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-monthly-${BUILD_IDENTIFIER}"
        backuparchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-monthly/applicationsourcecode.tar.gz"
elif ( [ "${BUILD_CHOICE}" = "6" ] )
    then
        backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-bimonthly-${BUILD_IDENTIFIER}"
        backuparchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-bimonthly/applicationsourcecode.tar.gz"
    fi
fi

#If we don't have a config file from a previous build or, we are forcing ourselves to be new, then, we can do the below
if ( [ "${PREVIOUS_BUILD_CONFIG}" = "0" ] || [ "${USE_NEW}" = "1" ] )
then
    DEVELOPMENT="0"
    PRODUCTION="0"

    if ( [ "${GENERATE_SNAPSHOTS}" -eq "1" ] )
    then
        response="2"
    else
        status "Are you deploying for 1)Development or 2)Production?"
        status "Please enter: 1 or 2"
        read response
    fi

    while ( [ "${response}" != "1" ] && [ "${response}" != "2" ] )
    do
        status "That's an invalid response, please enter 1 or 2 to select"
        read response
    done

    if ( [ "${response}" = "1" ] )
    then
        DEVELOPMENT="1"
        PRODUCTION="0"

        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/PRODUCTION:0
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/DEVELOPMENT:1
elif ( [ "${response}" = "2" ] )
    then
        PRODUCTION="1"
        DEVELOPMENT="0"

        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/PRODUCTION:1
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/DEVELOPMENT:0
    fi

    while ( [ 1 ] )
    do
        status ""
        status "Please select, would you like to build from a :"
        status ""
        #We don't want to deploy virgin installations to the cloud, we should use a local server for our development in all cases, baseline what
        #we have done and then move it to the cloud if we want to
        if ( [ "${DATABASE_INSTALLATION_TYPE}" != "DBaaS" ] && [ "${AUTOSCALE_FROM_SNAPSHOTS}" != "1" ] && [ "${GENERATE_SNAPSHOTS}" != "1" ])
        then
            status "0) Virgin Build (If you want a fresh (virgin) install of an Application, select this option)"
            status ""
        fi

        status "1) Baseline Build (The application developer should provide a baseline of his application. You can install it by selecting this option)"
        status ""

        #If we are generating snapshots, then we can't use these build options
        if ( [ "${GENERATE_SNAPSHOTS}" != "1" ] )
        then
            status "2) Hourly  (Build the website based on the daily backup. These backups are taken once and hour and will be the most recent to build from"
            status ""
            status "3) Daily  (Build the website based on the daily backup. Daily backups occur overnight (GMT)"
            status ""
            status "4) Weekly (Build the website based on the weekly backup. Useful if you had a problem on the site and you need to roll back to a previous version)"
            status ""
            status "5) Monthly (Build the website based on the monthly backup)"
            status ""
            status "6) Bi-Monthly (Build the website based on the bi-monthly backup)"
        fi
        status ""
        status "########################################################################################################################################"

        BUILD_CHOICE="NONE"
        APPLICATION_BASELINE_SOURCECODE_REPOSITORY=""
        BASELINE_DB_REPOSITORY=""

        while ( [ "`/bin/echo "0 1 2 3 4 5 6" | /bin/grep ${BUILD_CHOICE}`" = "" ] )
        do
            if ( [ "${APPLICATION_NAME}" != "" ] )
            then
                status "You need to point me to a repo with the sourcecode for an application of type: " ${APPLICATION_NAME}
            fi
            status "Please enter the build choice you wish to select ..."
            status ""
            read BUILD_CHOICE
        done

        case ${BUILD_CHOICE} in
            0)  . ${BUILD_HOME}/buildscripts/InitialiseVirginApplication.sh
                break ;;
            1)      status "#################################################################################################################"
                status "You previously chose to build an application of type: " ${APPLICATION_NAME}
                status "As you are choosing to build from a baseline build, please enter the URL to the repository in BitBucket where your sourcecode is stored for your application"
                status "You can find this by navigate to your repository and copying and pasting the repository name from the URL"
                status "For example: socialnetwork-webroot-sourcecode-baseline"
                status "#################################################################################################################"
                status "Please enter your application repository name"
                read repourl
                APPLICATION_BASELINE_SOURCECODE_REPOSITORY="`/bin/echo $repourl | /bin/sed 's/https:\/\///g' | /bin/sed 's/http:\/\///g'`"
                BUILD_ARCHIVE_CHOICE="baseline"

                while ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}`" = "" ] )
                do
                    status "Cannot access repository: ${repourl}.git, please enter another repository name"
                    read repourl
                    APPLICATION_BASELINE_SOURCECODE_REPOSITORY="`/bin/echo $repourl | /bin/sed 's/https:\/\///g' | /bin/sed 's/http:\/\///g'`"
                done

                if ( [ "${DATABASE_INSTALLATION_TYPE}" != "None" ] )
                then
                    status "Thanks ... Now please input the repository URL of your database code repository"
                    status "For example socialnetwork-db-baseline"
                    read dburl
                    BASELINE_DB_REPOSITORY="`/bin/echo $dburl | /bin/sed 's/https:\/\///g' | /bin/sed 's/http:\/\///g'`"

                    while ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${BASELINE_DB_REPOSITORY}`" = "" ] )
                    do
                        status "Cannot access repository: ${dburl}.git, please enter another repository name"
                        read dburl
                        BASELINE_DB_REPOSITORY="`/bin/echo $dburl | /bin/sed 's/https:\/\///g' | /bin/sed 's/http:\/\///g'`"
                    done
                fi
                break ;;
            2)
                BUILD_ARCHIVE_CHOICE="hourly"
                backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-hourly-${BUILD_IDENTIFIER}"
                backupdbrepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-db-hourly-${BUILD_IDENTIFIER}"

                if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${backuprepository}`" = "" ] )
                then
                    APPLICATION_BASELINE_SOURCECODE_REPOSITORY=""
                    status ""
                    status "Cannot access repository: ${backuprepository}.git in your application repository"
                    status "The first \"hourly\" repository will not be available to build from until"
                    status "your website has been running for at least an hour "
                    status "For the first build, you have to build from the standard baseline (choice 1)"
                    status ""

                    response=""
                    while ( [ "${response}" = "" ] )
                    do
                        status "Do you want me to look in your datastore, (y|Y)?"
                        read response
                    done

                    if ( [ "`/bin/echo 'y Y' | grep ${response}`" != "" ] )
                    then
                        backuparchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-hourly/applicationsourcecode.tar.gz"
                        if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_CHOICE} ${backuparchive}`" = "" ] )
                        then
                            status "Sorry, still couldn't find the sourcecode"
                            status "Exiting......."
                            exit
                        else
                            status "Found some sourcecode at ${backuparchive} in provider ${DATASTORE_CHOICE}"
                            status "Press <enter> if this is acceptable to you???, <ctrl-c> to exit"
                            read response
                        fi
                    else
                        exit
                    fi
                else
                    backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-hourly-${BUILD_IDENTIFIER}"
                fi

                if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${backupdbrepository}`" = "" ] )
                then
                    status ""
                    status "Cannot access the db repository: ${backupdbrepository}.git from your repository provider"
                    status "The first \"hourly\" repository will not be available to build from until"
                    status "your website has been running for at least an hourly"
                    status "For the first build, you have to build from the standard baseline (choice 1)"
                    status ""

                    response=""
                    while ( [ "${response}" = "" ] )
                    do
                        status "Do you want me to look in your datastore, (y|Y)?"
                        read response
                    done

                    if ( [ "`/bin/echo 'y Y' | grep ${response}`" != "" ] )
                    then
                        backupdbarchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-hourly/${WEBSITE_NAME}-DB-backup.tar.gz"
                        if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_CHOICE} ${backupdbarchive}`" = "" ] )
                        then
                            status "Sorry, still couldn't find the sourcecode"
                            status "Exiting......."
                            exit
                        else
                            status "Found some DB data at ${backupdbarchive} in provider ${DATASTORE_CHOICE}"
                            status "Press <enter> if this is acceptable to you???, <ctrl-c> to exit"
                            read response
                        fi
                    else
                        exit
                    fi
                fi
                break ;;
            3)
                BUILD_ARCHIVE_CHOICE="daily"
                backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-daily-${BUILD_IDENTIFIER}"
                backupdbrepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-db-hourly-${BUILD_IDENTIFIER}"

                if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${backuprepository}`" = "" ] )
                then
                    APPLICATION_BASELINE_SOURCECODE_REPOSITORY=""
                    status ""
                    status "Cannot access repository: ${backuprepository}.git in your application repository"
                    status "The first \"daily\" repository will not be available to build from until"
                    status "your website has been running for at least 24hours "
                    status "For the first build, you have to build from the standard baseline (choice 1)"
                    status ""
                    status "Do you want me to look in your datastore?"
                    read response
                    if ( [ "`/bin/echo 'y Y' | grep ${response}`" != "" ] )
                    then
                        backuparchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-daily/applicationsourcecode.tar.gz"
                        if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_CHOICE} ${backuparchive}`" = "" ] )
                        then
                            status "Sorry, still couldn't find the sourcecode"
                            status "Exiting......."
                            exit
                        else
                            status "Found some sourcecode at ${backuparchive} in provider ${DATASTORE_CHOICE}"
                            status "Press <enter> if this is acceptable to you???, <ctrl-c> to exit"
                            read response
                        fi
                    else
                        exit
                    fi
                else
                    backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-daily-${BUILD_IDENTIFIER}"
                fi

                if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${backupdbrepository}`" = "" ] )
                then
                    status ""
                    status "Cannot access repository: ${backupdbrepository}.git from your repository provider"
                    status "The first \"daily\" repository will not be available to build from until the first time the website has been running through"
                    status "The night and an automated hourly backup has been made and written to the repository"
                    status "For the first day, you have to build from the standard baseline"
                    status ""

                    response=""
                    while ( [ "${response}" = "" ] )
                    do
                        status "Do you want me to look in your datastore, (y|Y)?"
                        read response
                    done

                    if ( [ "`/bin/echo 'y Y' | grep ${response}`" != "" ] )
                    then
                        backupdbarchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-daily/${WEBSITE_NAME}-DB-backup.tar.gz"
                        if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_CHOICE} ${backupdbarchive}`" = "" ] )
                        then
                            status "Sorry, still couldn't find the sourcecode"
                            status "Exiting......."
                            exit
                        else
                            status "Found some DB data at ${backupdbarchive} in provider ${DATASTORE_CHOICE}"
                            status "Press <enter> if this is acceptable to you???, <ctrl-c> to exit"
                            read response
                        fi
                    else
                        exit
                    fi
                fi
                break ;;
            4)
                BUILD_ARCHIVE_CHOICE="weekly"
                backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-weekly-${BUILD_IDENTIFIER}"
                backupdbrepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-db-hourly-${BUILD_IDENTIFIER}"

                if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${backuprepository}`" = "" ] )
                then
                    APPLICATION_BASELINE_SOURCECODE_REPOSITORY=""
                    status ""
                    status "Cannot access repository: ${backuprepository}.git in your application repository"
                    status "The first \"weekly\" repository will not be available to build from until the website has been running continuously"
                    status "for at least a week and an automated weekly backup has been made and written to the repository"
                    status "For up to a week, you will have to build from the standard baseline or possibly the daily backup  or weekly backup in your repsoitory"
                    status ""
                    status "Do you want me to look in your datastore?"
                    read response

                    if ( [ "`/bin/echo 'y Y' | grep ${response}`" != "" ] )
                    then
                        backuparchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-weekly/applicationsourcecode.tar.gz"
                        if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_CHOICE} ${backuparchive}`" = "" ] )
                        then
                            status "Sorry, still couldn't find the sourcecode"
                            status "Exiting......."
                            exit
                        else
                            status "Found some sourcecode at ${backuparchive} in provider ${DATASTORE_CHOICE}"
                            status "Press <enter> if this is acceptable to you???, <ctrl-c> to exit"
                            read response
                        fi
                    else
                        exit
                    fi
                else
                    backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-weekly-${BUILD_IDENTIFIER}"
                fi

                if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${backupdbrepository}`" = "" ] )
                then
                    status ""
                    status "Cannot access repository: ${backupdbrepository}.git in from your repository provider"
                    status "The first \"weekly\" repository will not be available to build from until the website has been running continuously"
                    status "for at least a week and an automated weekly backup has been made and written to the repository"
                    status "For up to a week, you will have to build from the standard baseline or possibly the daily backup  or weekly backup in your repsoitory"
                    status ""

                    response=""
                    while ( [ "${response}" = "" ] )
                    do
                        status "Do you want me to look in your datastore, (y|Y)?"
                        read response
                    done

                    if ( [ "`/bin/echo 'y Y' | grep ${response}`" != "" ] )
                    then
                        backupdbarchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-weekly/${WEBSITE_NAME}-DB-backup.tar.gz"
                        if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_CHOICE} ${backupdbarchive}`" = "" ] )
                        then
                            status "Sorry, still couldn't find the sourcecode"
                            status "Exiting......."
                            exit
                        else
                            status "Found some DB data at ${backupdbarchive} in provider ${DATASTORE_CHOICE}"
                            status "Press <enter> if this is acceptable to you???, <ctrl-c> to exit"
                            read response
                        fi
                    else
                        exit
                    fi
                fi
                break ;;
            5)
                BUILD_ARCHIVE_CHOICE="monthly"
                backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-monthly-${BUILD_IDENTIFIER}"
                backupdbrepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-db-hourly-${BUILD_IDENTIFIER}"

                if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${backuprepository}`" = "" ] )
                then
                    APPLICATION_BASELINE_SOURCECODE_REPOSITORY=""
                    status ""
                    status "Cannot access repository: ${backuprepository}.git in your application repository"
                    status "The first \"monthly\" repository will not be available to build from until the website has been running continuously"
                    status "for at least a month and an automated monthly backup has been made and written to the repository"
                    status "For up to 1 month, you will have to build from the standard baseline or possibly the daily backup, weekly backup backup in your repsoitory"
                    status ""

                    response=""
                    while ( [ "${response}" = "" ] )
                    do
                        status "Do you want me to look in your datastore, (y|Y)?"
                        read response
                    done

                    if ( [ "`/bin/echo 'y Y' | grep ${response}`" != "" ] )
                    then
                        backuparchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-monthly/applicationsourcecode.tar.gz"
                        if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_CHOICE} ${backuparchive}`" = "" ] )
                        then
                            status "Sorry, still couldn't find the sourcecode"
                            status "Exiting......."
                            exit
                        else
                            status "Found some sourcecode at ${backuparchive} in provider ${DATASTORE_CHOICE}"
                            status "Press <enter> if this is acceptable to you???, <ctrl-c> to exit"
                            read response
                        fi
                    else
                        exit
                    fi
                else
                    backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-monthly-${BUILD_IDENTIFIER}"
                fi

                if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${backupdbrepository}`" = "" ] )
                then
                    status ""
                    status "Cannot access repository: ${backupdbrepository}.git in your repository provider"
                    status "The first \"monthly\" repository will not be available to build from until the website has been running continuously"
                    status "for up to a month and an automated monthly backup has been made and written to the repository"
                    status "For up to 1 month, you will have to build from the standard baseline or possibly the daily backup, weekly backup backup in your repsoitory"
                    status ""

                    response=""

                    while ( [ "${response}" = "" ] )
                    do
                        status "Do you want me to look in your datastore, (y|Y)?"
                        read response
                    done

                    if ( [ "`/bin/echo 'y Y' | grep ${response}`" != "" ] )
                    then
                        backupdbarchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-monthly/${WEBSITE_NAME}-DB-backup.tar.gz"
                        if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_CHOICE} ${backupdbarchive}`" = "" ] )
                        then
                            status "Sorry, still couldn't find the sourcecode"
                            status "Exiting......."
                            exit
                        else
                            status "Found some DB data at ${backupdbarchive} in provider ${DATASTORE_CHOICE}"
                            status "Press <enter> if this is acceptable to you???, <ctrl-c> to exit"
                            read response
                        fi
                    else
                        exit
                    fi
                fi
                break ;;
            6)
                BUILD_ARCHIVE_CHOICE="bimonthly"
                backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-bimonthly-${BUILD_IDENTIFIER}"
                backupdbrepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-db-hourly-${BUILD_IDENTIFIER}"

                if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${backuprepository}`" = "" ] )
                then
                    APPLICATION_BASELINE_SOURCECODE_REPOSITORY=""
                    status ""
                    status "Cannot access repository: ${backuprepository}.git from your repository provider"
                    status "The first \"bimonthly\" repository will not be available to build from until the website has been running continuously"
                    status "for at most 2 months and an automated bi-monthly backup has been made and written to the repository"
                    status "For up to 2 months, you will have to build from the standard baseline or possibly the daily backup, weekly backup or monthly backup in your repsoitory"
                    status ""

                    response=""
                    while ( [ "${response}" = "" ] )
                    do
                        status "Do you want me to look in your datastore, (y|Y)?"
                        read response
                    done

                    if ( [ "`/bin/echo 'y Y' | grep ${response}`" != "" ] )
                    then
                        backuparchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-bimonthly/applicationsourcecode.tar.gz"
                        if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_CHOICE} ${backuparchive}`" = "" ] )
                        then
                            status "Sorry, still couldn't find the sourcecode"
                            status "Exiting......."
                            exit
                        else
                            status "Found some sourcecode at ${backuparchive} in provider ${DATASTORE_CHOICE}"
                            status "Press <enter> if this is acceptable to you???, <ctrl-c> to exit"
                            read response
                        fi
                    else
                        exit
                    fi
                else
                    backuprepository="${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-webroot-sourcecode-bimonthly-${BUILD_IDENTIFIER}"
                fi

                if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${backupdbrepository}`" = "" ] )
                then
                    status ""
                    status "Cannot access repository: ${backupdbrepository}.git from your repository provider"
                    status "The first \"bimonthly\" repository will not be available to build from until the website has been running continuously"
                    status "for at most 2 months and an automated bi-monthly backup has been made and written to the repository"
                    status "For up to 2 months, you will have to build from the standard baseline or possibly the daily backup, weekly backup or monthly backup in your repsoitory"
                    status ""
                    status "Do you want me to look in your datastore?"
                    read response
                    if ( [ "`/bin/echo 'y Y' | grep ${response}`" != "" ] )
                    then
                        backupdbarchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-bimonthly/${WEBSITE_NAME}-DB-backup.tar.gz"
                        if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_CHOICE} ${backupdbarchive}`" = "" ] )
                        then
                            status "Sorry, still couldn't find the sourcecode"
                            status "Exiting......."
                            exit
                        else
                            status "Found some DB data at ${backupdbarchive} in provider ${DATASTORE_CHOICE}"
                            status "Press <enter> if this is acceptable to you???, <ctrl-c> to exit"
                            read response
                        fi
                    else
                        exit
                    fi
                fi
                break ;;
            *)           status "Invalid choice, please enter one of '1', '2', '3', '4', '5', '6'" ;;
        esac
    done

fi

#For anything other than a virgin build, we won't know what application type we are, so interrogate to find out
if ( [ "${BUILD_CHOICE}" -ne "0"  ] )
then
    status "Interrogating to see what Application you are running, if any"
    . ${BUILD_HOME}/providerscripts/application/InterrogateApplicationType.sh
fi

#When we are a baseline, we want to persist all our assets to our datastore. This involves deleting any existing assets from the bucket
#we are persisting to so we issue a warning here, that the existing assets will be purged

if ( [ "${BUILD_CHOICE}" = "0" ] || [ "${BUILD_CHOICE}" = "1" ] )
then
    status "Checking to see if there are any assets already existing for the ${WEBSITE_URL} build in your datastore..."
    for assettype in `/bin/echo ${DIRECTORIES_TO_MOUNT} | /bin/sed 's/:/ /'`
    do
        bucketprefix="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
        ASSETS_BUCKET="`/bin/echo ${bucketprefix} | /bin/sed 's/\./-/g'`-${assettype}"
        ASSETS_BUCKET="`/bin/echo ${ASSETS_BUCKET} | /bin/sed 's/\./-/g'`"
        if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh "${DATASTORE_CHOICE}" "${ASSETS_BUCKET}" | /usr/bin/wc -l`" -gt "0" ] )
        then
            status "==================================================================================================================="
            status "=CRITICAL WARNING    CRITICAL WARNING   CRITICAL WARNING   CRITICAL WARNING   CRITICAL WARNING   CRITICAL WARNING="
            status "==================================================================================================================="
            status "Hi Mate, there's some assets in your datastore for this website. They are probably from a previous build"
            status "You have selected a baseline or a virgin build this means existing assets will be deleted."
            status "With this in mind, I will take a safety backup for you of your existing assets. The bucket name of the copy"
            status "Will be displayed which you might want to make a note of for future reference should you need to reinstall the previous"
            status "version."
            status "IMPORTANT:"
            status "Additional warning, though, any backups stored to your repository from your previous deployment will also"
            status "be overwritten during normal operation of this deploy, so you might want to check your repositories in your git provider"
            status "for existing backups and make copies of those also"
            status "======================================================================================================================"
            status "Press <enter> when you are ready to continue"
            read input
            status "Making a safety backup: s3://${ASSETS_BUCKET}-backup-$$ in your ${DATASTORE_CHOICE} datastore from a previous build of this website - ${WEBSITE_URL} , please wait....."
            /usr/bin/s3cmd mb s3://${ASSETS_BUCKET}-backup-$$
            /usr/bin/s3cmd sync s3://${ASSETS_BUCKET} s3://${ASSETS_BUCKET}-backup-$$
            /usr/bin/s3cmd --recursive --force del s3://${ASSETS_BUCKET}
            status "OK, thanks for waiting. You can find your previously deployed assets in s3://${ASSETS_BUCKET} in your ${DATASTORE_CHOICE} datastore."
            status " please press <enter> to continue"
            read x
        fi
    done
fi
