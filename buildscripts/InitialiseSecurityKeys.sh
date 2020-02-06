#!/bin/bash
#################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script sets up all the security keys needed by the infrastructure.
# Every time a new build is run, it removes the old keys and generates fresh new ones
# for usage. PLEASE NOTE: These keys will be written to your build client underneath
# 'the "keys" directory. You must keep these keys safe, if they leak, then your
# infrastructure could be compromised.
##################################################################################
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

${BUILD_HOME}/providerscripts/cloudhost/GetProviderAuthorisation.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}

TOKEN="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN 2>/dev/null`"

if ( [ ! -d ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER} ] )
then
    /bin/mkdir -p ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}
else
    /bin/rm ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/* 2>/dev/null
fi

/bin/rm ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}
/bin/rm ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub

/usr/bin/ssh-keygen -t rsa -N "" -f ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}

#Use a varaible for easy access to the build key

${BUILD_HOME}/providerscripts/security/DeleteSSHKeyPair.sh "${PUBLIC_KEY_NAME}-${BUILD_IDENTIFIER}" "${TOKEN}" ${CLOUDHOST}
${BUILD_HOME}/providerscripts/security/RegisterSSHKeyPair.sh "${PUBLIC_KEY_NAME}-${BUILD_IDENTIFIER}" "${TOKEN}" "`/bin/cat ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub`" ${CLOUDHOST}

PUBLIC_KEY_ID="`${BUILD_HOME}/providerscripts/security/GetSSHKeyID.sh \"${PUBLIC_KEY_NAME}-${BUILD_IDENTIFIER}\" ${CLOUDHOST}`"

/bin/echo ${PUBLIC_KEY_NAME} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/PUBLICKEYNAME
/bin/echo ${PUBLIC_KEY_ID} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/PUBLICKEYID
