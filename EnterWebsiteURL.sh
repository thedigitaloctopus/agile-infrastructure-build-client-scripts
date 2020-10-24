#!/bin/sh
##############################################################################################################################
# Description: This script will get the URL for the website being deployed
# Author: Peter Winter
# Date: 17/01/2017
##############################################################################################################################
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

#Ask the user for the URL to their website
status
status
status "##################################################################################################"
status "#### Please enter a full url (including subdomain) for your website/application              #####"
status "#### For example: www.mycommunity.org.uk                                                     #####"
status "#### If your application isn't web facing and doesn't require a URL, then please simply enter#####"
status "#### xxx.yyy.zzz or equivalent. That said, you have to be consistent between deployments    #####"
status "#### as even though your app might not require a domain name to function, the repository and #####"
status "#### backup names are built out of whatever you enter here irrespective of whether the app   #####"
status "#### is web facing or not. So if you change what you enter here between deployments, the     #####"
status "#### the toolkit won't be able to discover and access your backups from the repo/datastore   #####"
status "##################################################################################################"
status "Enter Website URL:"
read WEBSITE_URL
while ( [ "`/bin/echo ${WEBSITE_URL} | /bin/grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'`" = "" ] )
do
    status "Invalid URL, please try again"
    read WEBSITE_URL
done

WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
