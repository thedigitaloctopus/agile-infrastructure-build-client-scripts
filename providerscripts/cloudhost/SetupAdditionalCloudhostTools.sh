#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date  : 13/07/2021
# Description : If you have an additional requirements for your cloudhost tools for your
# provider you can set them up here. 
#####################################################################################
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
######################################################################################
######################################################################################
#set -x

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
    :
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
    /bin/mkdir -p /root/.config/exoscale

    ACCESS_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/ACCESS_KEY`"
    SECRET_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/SECRET_KEY`"

    /bin/echo "defaultaccount = \"${CLOUDHOST_EMAIL_ADDRESS}\"
[[accounts]]
  account = \"${CLOUDHOST_EMAIL_ADDRESS}\"
  endpoint = \"https://api.exoscale.com/v1\"
  environment = \"\"
  key = \"${ACCESS_KEY}\"
  name = \"${CLOUDHOST_EMAIL_ADDRESS}\"
  secret = \"${SECRET_KEY}\""> /root/.config/exoscale/exoscale.toml
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
    /bin/mkdir /root/.config ${BUILD_HOME}/.config
    TOKEN="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN`"

    /bin/echo "[DEFAULT]
default-user = ${LINODEACCOUNT_USERNAME}
[${LINODEACCOUNT_USERNAME}]
token = ${TOKEN}" | /usr/bin/tee ${BUILD_HOME}/.config/linode-cli /root/.config/linode-cli

fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
    :
fi

if ( [ "${CLOUDHOST}" = "aws" ] )
then
    :
fi
  
  
