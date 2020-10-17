#!/bin/sh
######################################################################################
# Description: This script will install the cloudhost tools for the provider you have
# selected. These tools will give API access to the provider which can then be used by
# the other scripts to manipulate resourced on that providers infrastructure.
# Date: 07-11-2016
# Author: Peter Winter
######################################################################################
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

status () {
    /bin/echo "$1" | /usr/bin/tee /dev/fd/3
}

BUILD_HOME="`/bin/pwd`"

cloudhost="${1}"
buildos="${2}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
    if ( [ ! -f /usr/local/bin/doctl ] )
    then
        status "Installing Doctl toolkit..."
        status  "Press <enter> key to continue"
        ${BUILD_HOME}/installscripts/InstallDoctl.sh "${buildos}"
    fi
fi
if ( [ "${cloudhost}" = "exoscale" ] )
then
    if ( [ ! -f /usr/bin/pip ] )
    then
        status "Installing Exoscale toolkit..."
        status  "Press <enter> key to continue"
        ${BUILD_HOME}/installscripts/PurgePython.sh "${buildos}"
        ${BUILD_HOME}/installscripts/Update.sh "${buildos}"
        ${BUILD_HOME}/installscripts/ForceInstall.sh "${buildos}"
        ${BUILD_HOME}/installscripts/InstallPythonPIP.sh "${buildos}"
    fi
    if ( [ ! -f /usr/local/bin/cs ] )
    then
        ${BUILD_HOME}/installscripts/Update.sh "${buildos}"
        ${BUILD_HOME}/installscripts/InstallCS.sh "${buildos}"
    fi
fi
if ( [ "${cloudhost}" = "linode" ] )
then
    if ( [ ! -f /usr/local/bin/linode-cli ] )
    then
        status "Installing Linode toolkit..."
        status  "Press <enter> key to continue"
        ${BUILD_HOME}/installscripts/Update.sh "${buildos}"
        ${BUILD_HOME}/installscripts/InstallPythonPIP.sh "${buildos}"
        ${BUILD_HOME}/installscripts/InstallLinodeCLI.sh "${buildos}"
        /usr/bin/unlink /usr/bin/python
        /usr/bin/ln -s /usr/bin/python3 /usr/bin/python
    fi
fi
if ( [ "${cloudhost}" = "vultr" ] )
then
    if ( [ ! -f /usr/bin/vultr ] )
    then
        status "Installing Vultr toolkit..."
        status  "Press <enter> key to continue"
        ${BUILD_HOME}/installscripts/InstallSudo.sh "${buildos}"
        ${BUILD_HOME}/installscripts/InstallVultrCLI.sh "${buildos}"        
    fi
fi

if ( [ "${cloudhost}" = "aws" ] )
then
    if ( [ ! -f /usr/bin/aws ] )
    then
        status "Installing awscli....."
        status  "Press <enter> key to continue"
        ${BUILD_HOME}/installscripts/InstallSudo.sh "${buildos}"
        ${BUILD_HOME}/installscripts/InstallJQ.sh "${buildos}"
        ${BUILD_HOME}/installscripts/InstallAWSCLI.sh "${buildos}"
    fi
fi


