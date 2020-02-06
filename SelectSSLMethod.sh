#!/bin/sh
######################################################################################################
# Description: The basic idea is that we can use an automated provider to get our SSL certificate or
# we can get one manually.
# Both options are supported. If manual is chosen, then later on the user will be asked to provide
# their certificate files for use as part of SSL.
# Author: Peter Winter
# Date: 17/01/2017
######################################################################################################
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
status ""
status "##############################################################################################"
status "It's necessary to provide an SSL certificate for the webserver(s) to use. In time, you will be"
status "able to select automatic or manual as SSL generation methods"
status "If you select automatic, it is all taken care of for you for free. If you select manual, you "
status "have to go to a certificate company online and purchase one"
status "Currently, we only support automatic"
status "##############################################################################################"
status "Which method of SSL Certificate generation would you like to use?"
status "1) Automatic 2) Manual - obtaining your own certificate from a 3rd party"
read response

while (  [ "${response}" = "" ] || [ "`/bin/echo 1 2 | /bin/grep "${response}"`" = "" ] )
do
    status "That is not a valid option. Please try again"
    read response
done

if ( [ "${response}" = "1" ] )
then
    SSL_GENERATION_METHOD="AUTOMATIC"
fi

if ( [ "${response}" = "2" ] )
then
    SSL_GENERATION_METHOD="MANUAL"
fi

if ( [ "${SSL_GENERATION_METHOD}" = "AUTOMATIC" ] )
then
    status "#########################################################################"
    status "What is the name of the certificate generation service you will be using?"
    status "#########################################################################"
    status "Currently, we support 1) Let's Encrypt"

    read response

    while (  [ "${response}" = "" ] || [ "`/bin/echo 1 | /bin/grep "${response}"`" = "" ] )
    do
        status "That is not a valid option. Please try again"
        read response
    done
    if ( [ "${response}" = "1" ] )
    then
        SSL_GENERATION_SERVICE="LETSENCRYPT"
    fi
fi
