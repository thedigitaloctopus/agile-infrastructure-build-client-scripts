#!/bin/sh
############################################################################################################
# This script enables you to make an additional backup of your backup. Backups run periodically for your site
# and each have their own repository based on their periodicity in Bitbucket. Hourly, daily, weekly, monthly, bi-monthly
# and so on. These run for both your webroot and your database and I am sure that Bitbucket themselves make
# ample provision for disaster recovery, but still, some people maybe slightly paranoid and like even more.
# The largest public data repository on the planet is probably Amazon S3, if your data isn't safe there as
# ordinary members of the public, it probably isn't safe anywhere. And so, if you want to make an additional
# redundancy backup or two, then all you need to do is run this script, supply your credentials for Amazon,
# your access key and your secret key and a backup will be made for you there, which you can access through
# aws.amazon.com. The agile infrastructure itself will make no active use of Amazon S3, but, there are
# some helper scripts which will enable you to manipulate your Amazon backed up data should you choose to.
########################################################################################################################
####RUN THIS SCRIPT MANUALLY WHENEVER YOU FEEL YOU WANT TO HAVE A SUPER SAFE BACKUP OF ONE OF A REPOSITORY REPOSITORIES
####RUN IT ONCE FOR EACH REPOSITORY YOU WISH TO BACKUP PASSING REPOSITORY NAME FROM THE HTTPS URL (which you can find on bitbucket)
####TO THE REPOSITORY YOU WISH TO BACKUP TO THIS SCRIPT
#########################################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

#To run this script, ./SuperSafeBackup.sh <bitbucket username> <bitbucket password> <bitbucket repository name>
#for example: ./SuperSafeBackup.sh "repman" "dfgasd098456" "socialnet-webroot-sourcecode-daily"


if ( [ ! -f  ./SuperSafeBackupToDatastore.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

BUILD_HOME="`/bin/cat ../buildconfiguration/buildhome`"


if ( [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ] )
then
    /bin/echo "Usage ./SuperSafeBackup.sh <bitbucket username> <bitbucket password> <bitbucket repository name>"
    exit
fi

INFRASTRUCTURE_REPOSITORY_USERNAME="$1"
INFRASTRUCTURE_REPOSITORY_PASSWORD="$2"
REPOSITORY_REP_NAME="$3"
INFRASTRUCTURE_REPOSITORY_PROVIDER="XXX"
INFRASTRUCTURE_REPOSITORY_OWNER="YYY"

/bin/echo "Please select your datastore provider 1. Amazon S3 2. Google Cloud 3. Digital Ocean 4. Exoscale"
read choice

if ( [ "`/bin/echo 1 2 3 4 | grep ${choice}`" = "" ] )
then
    /bin/echo "Invalid datastore provider, please try again...."
    read choice
fi

if ( [ "${choice}" = "1" ] )
then
    datastoreprovider="amazons3"
elif ( [ "${choice}" = "2" ] )
then
    datastoreprovider="digitalocean"
elif ( [ "${choice}" = "3" ] )
then
    datastoreprovider="exoscale"
fi

BUILD_HOME="`/bin/pwd`"
if ( [ ! -d ${BUILD_HOME}/supersafebackup ] )
then
    /bin/mkdir ${BUILD_HOME}/supersafebackup
fi

cd ${BUILD_HOME}/supersafebackup

/bin/echo "Are you running 1)ubuntu or 2)debian? Enter 1 or 2"
read response

if ( [ "${response}" = "1" ] )
then
    buildos="ubuntu"
elif ( [ "${response}" = "2" ] )
then
    buildos="debian"
fi

/bin/rm -r ${BUILD_HOME}/supersafebackup/* 2>/dev/null


if ( [ "`/bin/echo ${choice} | /bin/grep '1 2 3'`" != "" ] )
then
    if ( [ ! -f /usr/bin/s3cmd ] )
    then
        ${BUILD_HOME}/providerscripts/datastore/InstallDatastoreTools.sh 'S3CMD' ${buildos}
    fi

    if ( [ ! -f ~/.s3cfg ] )
    then
        /bin/echo "You need to configure your datastore tools. You can get your access keys by going to your AWS account at aws.amazon.com and following the instructions"
        /usr/bin/s3cmd --configure
    fi

    if ( [ "`/bin/echo ${choice} | /bin/grep '2'`" != "" ] )
    then
        if ( [ ! -f /root/.boto ] )
        then
            #/usr/bin/wget https://storage.googleapis.com/pub/gsutil.tar.gz
            #/bin/tar xfz gsutil.tar.gz -C ${BUILD_HOME}
            ${BUILD_HOME}/providerscripts/datastore/InstallDatastoreTools.sh 'GSUTIL' ${buildos}
            ${BUILD_HOME}/gsutil/gsutil config
        fi
    fi
fi

cd ${BUILD_HOME}/supersafebackup

/bin/rm -r ${BUILD_HOME}/supersafebackup/* 2>/dev/null
/bin/rm -r ${BUILD_HOME}/supersafebackup/.git 2> /dev/null

/usr/bin/git init

${BUILD_HOME}/providerscripts/git/GitClone.sh ${INFRASTRUCTURE_REPOSITORY_PROVIDER} ${INFRASTRUCTURE_REPOSITORY_USERNAME} ${INFRASTRUCTURE_REPOSITORY_PASSWORD} ${INFRASTRUCTURE_REPOSITORY_OWNER} ${REPOSITORY_REP_NAME}

cd ${BUILD_HOME}/supersafebackup/

/bin/tar cvfz ${REPOSITORY_REP_NAME}.tar.gz ${BUILD_HOME}/supersafebackup/${REPOSITORY_REP_NAME}
/bin/rm -r ${BUILD_HOME}/supersafebackup/${REPOSITORY_REP_NAME}
/bin/rm -r ${BUILD_HOME}/supersafebackup/.git

date="`/bin/date '+%d'`"
date=${date}"`/bin/date '+%m'`"
date=${date}"`/bin/date '+%y'`"

if ( [ "${datastoreprovider}" = "amazons3" ] ||  [ "${datastoreprovider}" = "digitalocean" ] ||  [ "${datastoreprovider}" = "exoscale" ] )
then
    /usr/bin/s3cmd mb s3://${REPOSITORY_REP_NAME}${date} 2>/dev/null
    /usr/bin/s3cmd put --multipart-chunk-size-mb=5 --recursive ${BUILD_HOME}/supersafebackup/. s3://${REPOSITORY_REP_NAME}${date}
fi
