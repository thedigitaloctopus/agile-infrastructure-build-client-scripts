#!/bin/sh
######################################################################################################
# Description: This script will install the Vultr CLI toolkit
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
    #official deprecated
   # /usr/bin/git clone https://github.com/vultr/vultr-cli.git
   # cd vultr-cli
   # /usr/bin/make builds/vultr-cli_linux_amd64
   # /bin/cp builds/vultr* /usr/bin/vultr
   # cd ..
    
    #Official
    /usr/bin/go get -u github.com/vultr/vultr-cli/v2
    vultr-cli="`/usr/bin/find / -name "vultr-cli" -print | /bin/grep bin | /bin/grep vultr-cli`"
    /bin/cp ${vultr-cli} /usr/bin/vultr
   
   #Clonk
    #latest="`/usr/bin/curl https://github.com/JamesClonk/vultr/releases/latest | /bin/sed 's/.*tag\///g' | /bin/sed 's/\".*//g' | /bin/sed 's/v//g'`"
    #/usr/bin/wget https://github.com/JamesClonk/vultr/releases/download/v${latest}/vultr_${latest}_Linux-64bit.tar.gz
    #if ( [ ! -d ${BUILD_HOME}/vultr ] )
    #then
    #    /bin/mkdir ${BUILD_HOME}/vultr
    #fi
    #/bin/tar xvfz ${BUILD_HOME}/vultr_${latest}_Linux-64bit.tar.gz  -C ${BUILD_HOME}/vultr
    #/bin/mv ${BUILD_HOME}/vultr/vultr /usr/bin
    #/bin/rm -r ${BUILD_HOME}/vultr
fi

if ( [ "${BUILD_OS}" = "debian" ] )
then
    #official deprecated 
 #   /usr/bin/git clone https://github.com/vultr/vultr-cli.git
 #   cd vultr-cli
 #   /usr/bin/make builds/vultr-cli_linux_amd64
  #  /bin/cp builds/vultr* /usr/bin/vultr
   # cd ..
   
    #Official
    /usr/bin/go get -u github.com/vultr/vultr-cli/v2
    vultr-cli="`/usr/bin/find / -name "vultr-cli" -print | /bin/grep bin | /bin/grep vultr-cli`"
    /bin/cp ${vultr-cli} /usr/bin/vultr
    
    #Clonk
    #latest="`/usr/bin/curl https://github.com/JamesClonk/vultr/releases/latest | /bin/sed 's/.*tag\///g' | /bin/sed 's/\".*//g' | /bin/sed 's/v//g'`"
    #/usr/bin/wget https://github.com/JamesClonk/vultr/releases/download/v${latest}/vultr_${latest}_Linux-64bit.tar.gz
    #if ( [ ! -d ${BUILD_HOME}/vultr ] )
    #then
    #    /bin/mkdir ${BUILD_HOME}/vultr
    #fi
    #/bin/tar xvfz ${BUILD_HOME}/vultr_${latest}_Linux-64bit.tar.gz  -C ${BUILD_HOME}/vultr
    #/bin/mv ${BUILD_HOME}/vultr/vultr /usr/bin
    #/bin/mv ${BUILD_HOME}/vultr /usr/bin
fi
