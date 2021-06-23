#!/bin/sh
######################################################################################################
# Description: This script will install the exo utility
# Author: Peter Winter
# Date: 17/01/2017
#######################################################################################################
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

if ( [ "${1}" != "" ] )
then
    BUILD_OS="${1}"
fi

if ( [ "${BUILD_OS}" = "ubuntu" ] )
then
    exoscale_cli_archive="`/usr/bin/curl https://github.com/exoscale/cli/releases/ | /bin/grep tar.gz | /bin/grep amd | /bin/grep download | /bin/grep linux | /usr/bin/head -1 | /bin/sed 's/.*exoscale-cli/exoscale-cli/g' | /usr/bin/awk -F'"' '{print $1}'`"
    version="`/bin/echo ${exoscale_cli_archive} | /bin/sed 's/.*exoscale-cli_//g' | /bin/sed 's/_linux.*//g'`"
    /usr/bin/wget https://github.com/exoscale/cli/releases/download/v${version}/${exoscale_cli_archive}
fi

if ( [ "${BUILD_OS}" = "debian" ] )
then
    exoscale_cli_archive="`/usr/bin/curl https://github.com/exoscale/cli/releases/ | /bin/grep tar.gz | /bin/grep amd | /bin/grep download | /bin/grep linux | /usr/bin/head -1 | /bin/sed 's/.*exoscale-cli/exoscale-cli/g' | /usr/bin/awk -F'"' '{print $1}'`"
    version="`/bin/echo ${exoscale_cli_archive} | /bin/sed 's/.*exoscale-cli_//g' | /bin/sed 's/_linux.*//g'`"
    /usr/bin/wget https://github.com/exoscale/cli/releases/download/v${version}/${exoscale_cli_archive}
fi
