#!/bin/sh
######################################################################################################
# Description: This script will install the AWS CLI toolkit
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
    /usr/bin/apt-get install unzip
    /usr/bin/curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    /usr/bin/unzip -o awscliv2.zip
    /bin/rm awscliv2.zip
    ./aws/install
    ./aws/install --update
    /bin/rm /usr/bin/aws
    /bin/ln -s /usr/local/bin/aws /usr/bin/aws
fi

if ( [ "${BUILD_OS}" = "debian" ] )
then
    /usr/bin/apt-get install unzip
    /usr/bin/curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    /usr/bin/unzip -o awscliv2.zip
    ./aws/install
    ./aws/install --update
    /bin/rm /usr/bin/aws
    /bin/ln -s /usr/local/bin/aws /usr/bin/aws
fi

