#!/bin/sh
##############################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will copy our generated config file for a particular
# provider over to our new machine
###############################################################################
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
#################################################################################
#################################################################################
#set -x

datastore_provider="${1}"
ip="${2}"
CLOUDHOST="${3}"
BUILD_IDENTIFIER="${4}"
ALGORITHM="${5}"
BUILD_HOME="${6}"
SERVER_USER="${7}"
SERVER_USER_PASSWORD="${8}"

OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "

if ( [ "${datastore_provider}" = "amazonS3" ] || [ "${datastore_provider}" = "digitalocean" ] || [ "${datastore_provider}" = "exoscale" ] || [ "${datastore_provider}" = "linode" ] || [ "${datastore_provider}" = "vultr" ] )
then
    /usr/bin/scp ${OPTIONS} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${HOME}/.s3cfg ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.s3cfg  >/dev/null 2>&1
fi
