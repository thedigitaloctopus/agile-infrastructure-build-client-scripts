#!/bin/sh
##################################################################################################################
# Description: When you deploy an application you have built using this toolkit, you may want to perform some of your own
# customisations specific to that application. If you do you will need to make your customisations in the
# ${HOME}/applicationscripts directory on the webserver and ${HOME}/applicationscripts directory on the database
# server. If you want to make customisations which only apply to a specific application type, then, following
# the example scripts should make it clear enough how to do that. The only other thing you need to do is to add
# your application to this file as you can see the "BASIC SOCIAL NETWORK" has been added as an example.
# At build time, then all you need to do is select the application type you are installing and it will perform the
# customisations you have defined on the webserver and database server.
#
# So, say you had created an application, "Basic Blogging Platform" in your favourite CMS, then, you would define
# your customisations on the webserver and database and then, add an option below, Basic Blogging Platform,
# following the example which has already been given. If you don't want any customisations specific
# to your application, then you don't need to add it here, but, it is probably best practice that you do so that for
# anyone modifying or extending you application the strcture is in place. If you are a developer, then in time, you
# will probably have several applications installed. Maybe, "Fred's Friends Community", "Jane's
# blogging platform" or "Jan's ecommerce platfom" and so on. The limit on what you can create as an application depends
# only on the limitis of the CMS.
# Author : Peter C Winter
# Date : 10/4/2017
####################################################################################################################
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

# When you build and customise an application, you can give it a type, so that you can bespoke customise it.
# This is where you select the type of the application you are deploying. If it is a virgin application, then
# it's type will always be 0. A virgin application is, for example, an unmodified CMS instance as is from the developers.
status ""
status "##################################################################################################"
status "We have some preconfigured applications which you may wish to deploy. If so, please select one "
status "You can add your own custom built applications here as you require                             "
status "Please enter 0: to not install an application (This should be the case if you are installing a virgin copy of an Application"
status "or 1: a customised joomla based social network (repository provider Bitbucket)"
status "or 2: a customised wordpress based social network (repository provider Bitbucket)"
status "##################################################################################################"

response=""

while ( [ "${response}" = "" ] || [ "`/bin/echo '0 1 2' | /bin/grep ${response}`" = "" ] )
do
    status "Please enter 0),1) or 2) to select"
    read response
done

APPLICATION_IDENTIFIER=${response}

#It is envisaged that in the future, more langauges will be supported. Java and so on.
status "##################################################################"
status "What language do you need for your deployment? Currently we support:"
status "1) Just HTML/JAVASCRIPT 2) PHP"
status "##################################################################"

response=""

while (  [ "${response}" = "" ] || [ "`/bin/echo '1 2' | /bin/grep ${response}`" = "" ] )
do
    status "Please enter 1) or 2) to select"
    read response
done

if ( [ "${response}" = "1" ] )
then
    APPLICATION_LANGUAGE="HTML"
elif ( [ "${response}" = "2" ] )
then
    APPLICATION_LANGUAGE="PHP"

    status "#######################################################################################################################"
    status "Which version of PHP do you want to install? Available versions are: 7.0,7.1,7.2,7.3,7.4"
    status "#######################################################################################################################"
    status "Please enter one of 7.0 7.1 7.2 7.3 7.4"

    read PHP_VERSION

    while ( [ "`/bin/echo '7.0 7.1 7.2 7.3 7.4' | /bin/grep ${PHP_VERSION}`" = "" ] )
    do
        status "Sorry, that's not a valid selection, please try again"
        status "Please enter one of 7.0 7.1 7.2 7.3 7.4"
        read PHP_VERSION
    done
    
    status "#################################################################################################################################"
    status "Hi, you have chosen to install PHP, there's some additional configuration options you can set"
    status "These values are to do with how the PHP server will respond to requests and if you search for, static, dynamic or ondemand for php"
    status "you will find more information about it. If you are unsure, just enter N below to accept default values"
    status "##################################################################################################################################"
    status "If you want to use the default values enter N else if you want to reconfigure them here, enter Y"
    read response
    
    if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
    then
         status "Please select whether you want to use"
         status "1)static"
         status "2)dynamic"
         status "3)on demand" 
         status "for your server configuration"
         status "Please enter one of 1, 2 or 3"
         read response
         while ( ["`/bin/echo "1 2 3" | /bin/grep ${response}`" = "" ] )
         do
             status "That's an invalid response, please try again"
             status "Please enter one of 1,2 or 3"
             read response
         done

         if ( [ "${response}" = "1" ] )
         then
             PHP_MODE="static"
         elif ( [ "${response}" = "2" ] )
         then
             PHP_MODE="dynamic"
         elif ( [ "${response}" = "3" ] )
         then
             PHP_MODE="ondemand"
         fi

         if ( [ "${PHP_MODE}" = "static" ] || [ "${PHP_MODE}" = "dynamic" ] || [ "${PHP_MODE}" = "ondemand" ] )
         then
             status "Please enter the value for the configuration value max_children"
             read response
             while ( [ 1 ] )
             do
                 if ( [ "${response}" -eq "${response}" 2>/dev/null ] )
                 then
                     PHP_MAX_CHILDREN="${response}"
                     break
                 else
                     status "Input must be a number, please try again:"
                     read response
                 fi
             done
         fi

         if ( [ "${PHP_MODE}" = "dynamic" ] )
         then
             status "Please enter the value for the configuration value start_servers"
             read response
             while ( [ 1 ] )
             do
                 if ( [ "${response}" -eq "${response}" 2>/dev/null ] )
                 then
                     PHP_START_SERVERS="${response}"
                     break
                 else
                     status "Input must be a number, please try again:"
                     read response
                 fi
             done
        fi

        if ( [ "${PHP_MODE}" = "dynamic" ] )
        then
            status "Please enter the value for the configuration value min_spare_servers"
            read response
            while ( [ 1 ] )
            do
                if ( [ "${response}" -eq "${response}" 2>/dev/null ] )
                then
                    PHP_MIN_SPARE_SERVERS="${response}"
                    break
                else
                    status "Input must be a number, please try again:"
                    read response
                fi
            done
        fi

        if ( [ "${PHP_MODE}" = "dynamic" ] )
        then
            status "Please enter the value for the configuration value max_spare_servers"
            read response
            while ( [ 1 ] )
            do
                if ( [ "${response}" -eq "${response}" 2>/dev/null ] )
                then
                    PHP_MAX_SPARE_SERVERS="${response}"
                    break
                else
                    status "Input must be a number, please try again:"
                    read response
                fi
            done
        fi

        if ( [ "${PHP_MODE}" = "ondemand" ] )
        then
            status "Please enter the value for the configuration value process_idle_timeout"
            read response
            while ( [ 1 ] )
            do
                if ( [ "${response}" -eq "${response}" 2>/dev/null ] )
                then
                    PHP_PROCESS_IDLE_TIMEOUT="${response}"
                    break
                else  
                    status "Input must be a number, please try again:"
                    read response
                fi
            done
	    fi
    fi
fi

APPLICATION_NAME=""

if ( [ "${APPLICATION_IDENTIFIER}" = "1" ] )
then
    APPLICATION_NAME="BASIC SOCIAL NETWORK"
fi

if ( [ "${APPLICATION_IDENTIFIER}" = "2" ] )
then
    APPLICATION_NAME="SIMPLE SOCIAL NETWORK"
fi
