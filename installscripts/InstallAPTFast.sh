#!/bin/sh
######################################################################################################
# Description: This will install apt-fast. You can choose to use apt-fast for installations in the buildstyles.dat file
# Author: Peter Winter
# Date: 17/10/2021
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
    /usr/bin/add-apt-repository -y ppa:apt-fast/stable 
    /usr/bin/apt-get -qq -y update
    /usr/bin/apt-get -qq -y install apt-fast  
fi

if ( [ "${BUILD_OS}" = "debian" ] )
then
    /usr/bin/add-apt-repository -y ppa:apt-fast/stable 
    /usr/bin/apt-get -qq -y update
    /usr/bin/apt-get -qq -y install apt-fast  
fi
