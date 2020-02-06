#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Install the tools for manipulating the Datastores
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
####################################################################################
####################################################################################
#set -x

if ( [ "$2" != "" ] )
then
    buildos="${2}"
fi

BUILD_HOME="`/bin/pwd`"

if ( [ "$1" = "S3CMD" ] )
then

    if ( [ ! -f /usr/bin/python ] )
    then
        ${BUILD_HOME}/installscripts/PurgePython.sh ${buildos}
        ${BUILD_HOME}/installscripts/Update.sh ${buildos}
        ${BUILD_HOME}/installscripts/ForceInstall.sh  ${buildos}
        ${BUILD_HOME}/installscripts/InstallPythonPIP.sh  ${buildos}
    fi

    if ( [ ! -f /usr/bin/s3cmd ] )
    then
        /bin/mkdir scratch
        cd scratch
        /usr/bin/git clone https://github.com/s3tools/s3cmd.git
        /bin/mkdir -p /usr/bin/s3cmdtools
        /bin/mv s3cmd S3 /usr/bin/s3cmdtools
        /bin/ln -s /usr/bin/s3cmdtools/s3cmd/s3cmd /usr/bin/s3cmd
        ${BUILD_HOME}/installscripts/InstallPythonPIP.sh "${buildos}"
        ${BUILD_HOME}/installscripts/InstallPythonDateUtil.sh "${buildos}"
        cd ..
        /bin/rm -r scratch
    fi
fi

