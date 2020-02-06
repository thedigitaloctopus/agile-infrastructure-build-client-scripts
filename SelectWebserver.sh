#!/bin/sh
######################################################################################################
# Description: This gives the user a choice as to which webserver they wish to deploy to
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

#Let the user decide which webserver they would like to use. Again, this is extensible to support new webservers in the future.

status ""
status ""
status "#####################################################################################################"
status "#####Which webserver would you like to deploy to?                                               #####"
status "#####We currently support 0: No Webserver 1: Nginx 2: Apache 3: Lighttpd                        #####"
status "#####################################################################################################"
status "Please make a webserver choice (0|1|2|3)"
read choice

while ( [ "${choice}" = "" ] || [ "`/bin/echo "0 1 2 3" | /bin/grep ${choice}`" = "" ] )
do
    status "Invalid choice, please try again..."
    read choice
done

if ( [ "${choice}" = "0" ] )
then
    WEBSERVER_CHOICE="NONE"
fi
if ( [ "${choice}" = "1" ] )
then
    WEBSERVER_CHOICE="NGINX"
fi
if ( [ "${choice}" = "2" ] )
then
    WEBSERVER_CHOICE="APACHE"
fi
if ( [ "${choice}" = "3" ] )
then
    WEBSERVER_CHOICE="LIGHTTPD"
fi
