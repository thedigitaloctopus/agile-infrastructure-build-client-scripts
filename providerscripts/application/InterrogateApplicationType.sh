#!/bin/sh
####################################################################################
# Description: This script will work out what Application we are deploying, if any.
# There are several scenarios. The 1st is that it is a virgin install of an Application
# in which case we can discern elsewhere which Application it is. The second is if we
# are deploying sourcecode from a repository such as bitbucket or github. The 3rd is
# if we are deploying from a datastore such as Amazon S3 or Google Cloud.  The way things
# work, the repositories are the primary backup mechanism, but backups are also made to
# a datastore. In the case when a repository pull fails, the system falls back to the
# datastore and checks for a copy there. This script is written to deal with all of
# those scenarios.
# Date: 07-11/2016
# Author: Peter Winter
####################################################################################
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
#####################################################################################
#####################################################################################
#set -x

status () {
    /bin/echo "$1" | /usr/bin/tee /dev/fd/3
}

INTERROGATION_HOME="${BUILD_HOME}/interrogation"

if ( [ ! -d ${INTERROGATION_HOME} ] )
then
    /bin/mkdir -p ${INTERROGATION_HOME}
fi

if ( [ -d ${INTERROGATION_HOME} ] )
then
    /bin/rm -r ${INTERROGATION_HOME}/* 1>/dev/null 2>/dev/null
fi

cd ${INTERROGATION_HOME}

interrogated="0"

if ( [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] )
then
    if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY} 2>/dev/null`" = "" ] )
    then
        status "Sorry, could not find the baseline repository for you application when I was expecting to, will have to exit..."
        status "Press <enter to exit>"
        read response
        exit
    else
        ${BUILD_HOME}/providerscripts/git/GitClone.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}
        . ${BUILD_HOME}/providerscripts/application/WhichApplicationByGitAndBaseline.sh
        /bin/rm -rf ${INTERROGATION_HOME}/${APPLICATION_BASELINE_SOURCECODE_REPOSITORY} 1>/dev/null 2>/dev/null
        interrogated="1"
    fi
fi

if ( [ "${interrogated}" = "0" ] )
then
    if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${backuprepository} 2>/dev/null`" != "" ] )
    then
        ${BUILD_HOME}/providerscripts/git/GitClone.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${backuprepository}
        . ${BUILD_HOME}/providerscripts/application/WhichApplicationByGitAndBackup.sh
        /bin/rm -rf ${INTERROGATION_HOME}/${backuprepository} 1>/dev/null 2>/dev/null
        interrogated="1"
    fi
fi


if ( [ "${backuparchive}" = "" ] && [ "${interrogated}" = "0" ] && [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] )
then

    ${BUILD_HOME}/providerscripts/datastore/GetFromDatastore.sh ${DATASTORE_CHOICE} ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}/applicationsourcecode.tar.gz

    if ( [ ! -f applicationsourcecode.tar.gz ] )
    then
        status "Oh dear, I couldn't find the backup of your sourcecode in your datastore either, will have to exit."
        status "Please check that you are setup to use the same datastore provider that you expected the sourcecode to be in"
        status "Your current datastore provider is ${DATASTORE_CHOICE} and the bucket you expect to be there is called ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}"
        exit
    else
        status "Great, I found some backed up sourcecode in your datastore, I will use that"
        status "Press <enter to continue> <ctrl-c> to exit"
        read response
        /bin/tar xvfz applicationsourcecode.tar.gz -C ${INTERROGATION_HOME}
        . ${BUILD_HOME}/providerscripts/application/WhichApplicationByDatastoreAndBaseline.sh
        interrogated="1"
    fi
elif ( [ "${interrogated}" = "0" ] )
then
    ${BUILD_HOME}/providerscripts/datastore/GetFromDatastore.sh ${DATASTORE_CHOICE} ${backuparchive}
    archivename="`/bin/echo ${backuparchive} | /usr/bin/awk -F'/' '{print $NF}'`"
    archive="${INTERROGATION_HOME}/${archivename}"

    if ( [ ! -f ${archive} ] )
    then
        status "Oh dear, I couldn't find the backup of your sourcecode in your datastore either, will have to exit."
        status "Please check that you are setup to use the same datastore provider that you expected the sourcecode to be in"
        status "Your current datastore provider is ${DATASTORE_CHOICE} and the bucket you expect to be there is called ${backuparchive}"
        exit
    else
        /bin/tar xvfz ${archive} -C ${INTERROGATION_HOME}
        . ${BUILD_HOME}/providerscripts/application/WhichApplicationByDatastoreAndBackup.sh
        interrogated="1"
    fi
fi

if ( [ -d ${INTERROGATION_HOME}/tmp ] )
then
    /bin/rm -rf ${INTERROGATION_HOME}/tmp 1>/dev/null 2>/dev/null
fi

if ( [ -f ${INTERROGATION_HOME}/applicationsourcecode.tar.gz ] )
then
    /bin/rm ${INTERROGATION_HOME}/applicationsourcecode.tar.gz 1>/dev/null 2>/dev/null
fi

cd ${BUILD_HOME}
