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
status "Modifying this file would be part of 'installing' your application                             "
status "##################################################################################################"
status "Please enter one of:"
status "0: to not install an application "
status "or 1: a customised joomla based application"
status "or 2: a customised wordpress based application"
status "##################################################################################################"

response=""

while ( [ "${response}" = "" ] || [ "`/bin/echo '0 1 2' | /bin/grep ${response}`" = "" ] )
do
    status "Please select one based on the application you are installing:" 
    status " 0) No Customisations (Virgin CMS installs of any type)"
    status "---------------------------------------------------------------------"
    status " 1) Customisations for the Joomla Demo application"
    status "---------------------------------------------------------------------"
    status " 2) Customisations required for the Wordpress 'Nuocial Boss'  application"
    status "    Nuocial Boss baseline repositories are stored in bitbucket at the following urls:"
    status "    Sourcecode: https://bitbucket.org/agiledeployer/nuocialboss-webroot-sourcecode-baseline"
    status "    Database  : https://bitbucket.org/agiledeployer/nuocialboss-db-baseline"
    status "---------------------------------------------------------------------"
    read response
done

APPLICATION_IDENTIFIER=${response}

APPLICATION_NAME=""

if ( [ "${APPLICATION_IDENTIFIER}" = "1" ] )
then
    APPLICATION_NAME="BASIC JOOMLA SOCIAL NETWORK "
fi

if ( [ "${APPLICATION_IDENTIFIER}" = "2" ] )
then
    APPLICATION_NAME="NUOCIALBOSS WORDPRESS SOCIAL NETWORK"
fi
