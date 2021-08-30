#!/bin/sh
###################################################################################
# Description : This script will copy the generated configuration file necessary for
# the selected provider to the machine being built.
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will copy the generated configuration file necessary for the selected provider to the machine being built.
###################################################################################
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

BUILD_HOME="${1}"
CLOUDHOST="${2}"
BUILD_IDENTIFIER="${3}"
ALGORITHM="${4}"
IP="${5}"
SERVER_USER="${6}"

OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "


if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
    /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${IP} "/bin/mkdir -p /home/${SERVER_USER}/.config/doctl"  >/dev/null 2>&1
    /usr/bin/scp ${OPTIONS} ${HOME}/.config/doctl/config.yaml ${SERVER_USER}@${IP}:/home/${SERVER_USER}/.config/doctl/config.yaml  >/dev/null 2>&1
    /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${IP} "/bin/chmod 600 /home/${SERVER_USER}/.config/doctl/config.yaml"  >/dev/null 2>&1
fi
if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
    /usr/bin/scp ${OPTIONS} ${HOME}/.cloudstack.ini ${SERVER_USER}@${IP}:/home/${SERVER_USER}/.cloudstack.ini  >/dev/null 2>&1
    /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${IP} "/bin/chmod 400 /home/${SERVER_USER}/.cloudstack.ini"  >/dev/null 2>&1
    /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${IP} "/bin/mkdir -p /home/${SERVER_USER}/.config/exoscale"  >/dev/null 2>&1
    /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${IP} "/bin/mkdir -p /root/.config/exoscale"  >/dev/null 2>&1
    /usr/bin/scp ${OPTIONS} ${HOME}/.config/exoscale/exoscale.toml ${SERVER_USER}@${IP}:/home/${SERVER_USER}/.config/exoscale  >/dev/null 2>&1
    /usr/bin/scp ${OPTIONS} ${HOME}/.config/exoscale/exoscale.toml ${SERVER_USER}@${IP}:/root/.config/exoscale  >/dev/null 2>&1
    /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${IP} "/bin/chmod 400 /home/${SERVER_USER}/.config/exoscale/exoscale.toml; /bin/chmod 400 /root/.config/exoscale/exoscale.toml "  >/dev/null 2>&1
fi
if ( [ "${CLOUDHOST}" = "linode" ] )
then
    /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${IP} "/bin/mkdir -p /home/${SERVER_USER}/.config"  >/dev/null 2>&1
    /usr/bin/scp ${OPTIONS} ${HOME}/.config/linode-cli ${SERVER_USER}@${IP}:/home/${SERVER_USER}/.config/linode-cli  >/dev/null 2>&1
    /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${IP} "/bin/chmod 400 /home/${SERVER_USER}/.config/linode-cli"  >/dev/null 2>&1
fi
if ( [ "${CLOUDHOST}" = "vultr" ] )
then
    /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${IP} "/usr/bin/touch /home/${SERVER_USER}/.ssh/VULTRAPIKEY:${VULTR_API_KEY}"  >/dev/null 2>&1
fi
if ( [ "${CLOUDHOST}" = "aws" ] )
then
    /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${IP} "/bin/mkdir -p /home/${SERVER_USER}/.aws"  >/dev/null 2>&1
    /usr/bin/scp ${OPTIONS} ${HOME}/.aws/config ${SERVER_USER}@${IP}:/home/${SERVER_USER}/.aws/config  >/dev/null 2>&1
    /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${IP} "/bin/chmod 400 /home/${SERVER_USER}/.aws/config"  >/dev/null 2>&1
    /usr/bin/scp ${OPTIONS} ${HOME}/.aws/credentials ${SERVER_USER}@${IP}:/home/${SERVER_USER}/.aws/credentials  >/dev/null 2>&1
    /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${IP} "/bin/chmod 400 /home/${SERVER_USER}/.aws/credentials"  >/dev/null 2>&1
fi



