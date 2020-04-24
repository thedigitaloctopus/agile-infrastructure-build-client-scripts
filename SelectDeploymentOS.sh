#!/bin/sh
##############################################################################################
# Description: In terms of future proofing, I put an option here to select the deployment OS.
# It is not currently structured for the first release to support anything other than ubuntu + debian,
# which is the defacto standard for cloud hosting anyway, but, in the future, it might be
# feasible to give the user a choice about which OS they wish to deploy to
# Author: Peter Winter
# Date: 17/01/2017
#################################################################################################
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

#Select which OS version you wish to deploy on/to

status "################################################################"
status "Which version of GNU/linux are you running this build script on?"
status "Currently we support 1)Ubuntu 2)Debian"
status "################################################################"

response=""

DEFAULT_USER="root"

while ( [ "${response}" = "" ] || [ "`/bin/echo '1 2' | /bin/grep ${response}`" = "" ] )
do
    status "Please enter the number of the style of GNU/linux you are running"
    read response
done

if ( [ "${response}" = "1" ] )
then
    BUILDOS="ubuntu"
    status "OK, thanks for that. Please now tell me what version of Ubuntu you would like to deploy. Currently, there is 18.04 (LTS) and 20.04(LTS) please choose one"
    status "Please type one of '18.04' or '20.04' to specify which version of ubuntu you wish to deploy to"
    read response

    if (  [ "${response}" = "" ] || [ "`/bin/echo '18.04 20.04' | /bin/grep ${response}`" = "" ] )
    then
        status "Sorry mate, that's not a valid choice, please enter one of 18.04 and 20.04"
        read response
    fi

    BUILDOS_VERSION="${response}"
elif ( [ "${response}" = "2" ] )
then
    BUILDOS="debian"
    status "OK, thanks for that. Please now tell me what version of Debian you would like to deploy. Currently you can choose version 9 or version 10"
    status "Please type one of '9' or '10' to accept debian for your deployment OS"
    read response

    if (  [ "${response}" = "" ] || [ "`/bin/echo '9 10' | /bin/grep ${response}`" = "" ] )
    then
        status "Sorry mate, that's not a valid choice, please enter one of  9 or 10"
        read response
    fi

    BUILDOS_VERSION="${response}"
fi




