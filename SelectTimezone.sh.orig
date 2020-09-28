#!/bin/sh
#####################################################################################################
# Description: This script gets the continent and city to be able to set what timezone the user is in
# Author: Peter Winter
# Date: 17/01/2017
#####################################################################################################
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
####################################################################################################
####################################################################################################
#set -x

#Lets the user select a timezone and a city (should be where the servers are, not necessarily where the user is)

SERVER_TIMEZONE_CONTINENT="UNDEFINED"
SERVER_TIMEZONE_CITY="UNDEFINED"

timezones="`/usr/bin/timedatectl list-timezones`"

while ( [ "`/bin/echo ${timezones} | /bin/grep ${SERVER_TIMEZONE_CONTINENT} | /bin/grep ${SERVER_TIMEZONE_CITY}`" = "" ] )
do
    status "###########################################################################"
    status "Hi Mate and welcome. First of all let's figure out what timezone you are in"
    status "###########################################################################"
    status "Please type in one of the following to make a selection:"
    continents="`/usr/bin/timedatectl list-timezones | /usr/bin/awk -F'/' '{print $1}' | /usr/bin/sort -u`"
    continent=""
    /bin/echo ${continents} >&3
    read continent
    while ( [ "`/bin/echo ${continents} | /bin/grep ${continent}`" = "" ] )
    do
        status "Sorry, that's not a valid continent, have another go"
        /bin/echo ${continents} >&3
        read continent
    done

    status "################################################"
    status "OK, now let's figure out what city you are in..."
    status "################################################"
    status "Press the <enter> key to continue>"
    read response

    citys="`/usr/bin/timedatectl list-timezones | /usr/bin/awk -F'/' '{print $2}' | /usr/bin/sort -u`"
    city=""
    /bin/echo ${citys} >&3
    read city
    while ( [ "`/bin/echo ${citys} | /bin/grep ${city}`" = "" ] )
    do
        status "Sorry, that's not a valid city, have another go"
        /bin/echo ${citys} >&3
        read city
    done

    export SERVER_TIMEZONE_CONTINENT="${continent}"
    export SERVER_TIMEZONE_CITY="${city}"

    if ( [ "`/bin/echo ${timezones} | /bin/grep \"${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}\"`" = "" ] )
    then
        status "There's no timezone ${continent}/${city}, press any key to try again"
        read response
    fi
    /usr/bin/timedatectl set-ntp true
done

