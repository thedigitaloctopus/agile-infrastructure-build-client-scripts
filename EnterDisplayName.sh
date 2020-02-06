#!/bin/sh
##########################################################################################################################################
# Description: This script will obtain the display name for the application being deployed
# Author: Peter Winter
# Date : 17/01/2017
##########################################################################################################################################
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

#Ask the user for a display name for their application. This is used later to customise the application to a particular
#branding if you like. So, if you are deploying an example socialnetwork called The Marionettes Online Community, the display
#name you would put here would simply be 'The Marionettes'

status "##################################################################################################"
status "#####Please enter a display name for your website/application                                #####"
status "#####For example: 'Local Volunteers'                                                         #####"
status "##################################################################################################"
status "Enter Display Name:"

read WEBSITE_DISPLAY_NAME

while ( [ "${WEBSITE_DISPLAY_NAME}" = "" ] )
do
    status "Display name can't be blank, try again"
    read WEBSITE_DISPLAY_NAME
done

WEBSITE_DISPLAY_NAME="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed "s/'//g" | /bin/sed 's/ /_/g'`"
