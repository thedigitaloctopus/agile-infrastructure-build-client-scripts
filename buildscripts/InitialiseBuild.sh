#!/bin/sh
################################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : If this is the first time that the build script has been run on a particular
# build client machine, then there needs to be some configuration and the needed software needs to
# be installed. This script does those tasks
################################################################################################
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
################################################################################################
################################################################################################
#set -x

${BUILD_HOME}/installscripts/Update.sh "${BUILDOS}"

if ( [ ! -d ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER} ] )
then
    /bin/mkdir -p ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}
fi
if ( [ ! -d ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER} ] )
then
    /bin/mkdir -p ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}
fi
if ( [ ! -d ${BUILD_HOME}/runtimedata/${CLOUDHOST} ] )
then
    /bin/mkdir -p ${BUILD_HOME}/runtimedata/${CLOUDHOST}
fi
if ( [ ! -d ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} ] )
then
    /bin/mkdir -p ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}
fi

if ( [ "${BUILDOS}" = "ubuntu" ] || [ "${BUILDOS}" = "debian" ] )
then
    if ( [ ! -f /usr/bin/banner ] )
    then
        ${BUILD_HOME}/installscripts/InstallSysVBanner.sh "${BUILDOS}"
    fi

    if ( [ ! -f /usr/bin/sshpass ] )
    then
        ${BUILD_HOME}/installscripts/InstallSSHPass.sh "${BUILDOS}"
    fi

    if ( [ ! -f /usr/bin/jq ] )
    then
        ${BUILD_HOME}/installscripts/InstallJQ.sh "${BUILDOS}"
    fi

    if ( [ ! -f /usr/bin/curl ] )
    then
        ${BUILD_HOME}/installscripts/InstallCurl.sh "${BUILDOS}"
    fi

    if ( [ ! -f /usr/bin/git ] )
    then
        ${BUILD_HOME}/installscripts/InstallGit.sh "${BUILDOS}"
    fi
fi
