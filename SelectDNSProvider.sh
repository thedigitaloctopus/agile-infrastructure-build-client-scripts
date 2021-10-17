#!/bin/sh
####################################################################################################
# Description: This script asks the user which DNS provider they wish to use
# Author: Peter Winter
# Date: 17/01/2017
####################################################################################################
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

#Ask the user which DNS provider they wish to use.

status ""
status ""
status "#####################################################################################################"
status "#####Which DNS provider tech would you like to use for you website/application                  #####"
status "#####We currently support 0: None 1: Cloudflare 2: Digital Ocean                                #####"
status "#####                     3: Exoscale 4:Linode                                                  #####"
status "#####################################################################################################"
status "Please select a DNS provider (0|1|2|3|4)"
read choice

while ( [ "${choice}" = "" ] || [ "`/bin/echo "0 1 2 3 4" | /bin/grep ${choice}`" = "" ] )
do
    status "Invalid choice, please try again..."
    read choice
done

if ( [ "${choice}" = "0" ] )
then
    DNS_CHOICE="NONE"
fi
if ( [ "${choice}" = "1" ] )
then
    if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-cloudflare-credentials/DNSUSERNAME ] )
    then
        /bin/mkdir -p ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-cloudflare-credentials
        status ""
        status "##########################################################################################################"
        status "With the Cloudflare acceleration technology, we need 2 more pieces of information from you"
        status "Please enter the email address of your cloudflare account. If you are reposible for only a subdomain"
        status "Then whoever registers the main domain should have also registered the domain with cloudflare and should, "
        status "therefore, have the email for the account with cloudflare"
        status "##########################################################################################################"
        status "So, please input the email address of your cloudflare account"
        read DNS_USERNAME
        /bin/echo ${DNS_USERNAME} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-cloudflare-credentials/DNSUSERNAME
    else
        DNS_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-cloudflare-credentials/DNSUSERNAME`"
        status "Have found an email address stored from a previous build for your cloudflare web dns account"
        status "It is set to: ${DNS_USERNAME}"

        status "Please enter Y/y if this is a correct email address"
        read answer
        if ( [ "`/bin/echo "${answer}" | /bin/grep 'y'`" = "" ]  && [ "`/bin/echo "${answer}" | /bin/grep 'Y'`" = "" ] )
        then
            status "So, please input the email address of your cloudflare account"
            read DNS_USERNAME
            /bin/echo "${DNS_USERNAME}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-cloudflare-credentials/DNSUSERNAME
        fi
    fi
    if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-cloudflare-credentials/DNSSECURITYKEY ] )
    then
        status ""
        status "##########################################################################################################"
        status "We also need the API key for your cloudflare account. You can either request this from the domain owner"
        status "or if you are the domain owner, you can find it by authenticating to your cloudflare account, clicking on"
        status "your name at the top right and then clicking on 'View API key for the Global API Key key"
        status "##########################################################################################################"
        status "Please input your cloudflare API key"
        read DNS_SECURITY_KEY
        /bin/echo ${DNS_SECURITY_KEY} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-cloudflare-credentials/DNSSECURITYKEY
        DNS_SECURITY_KEY="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-cloudflare-credentials/DNSSECURITYKEY`"
    else
        DNS_SECURITY_KEY="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-cloudflare-credentials/DNSSECURITYKEY`"
        status "Have found an access key stored from a previous build for your cloudflare web dns account"
        status "It is set to: ${DNS_SECURITY_KEY}"
        status "Please enter Y/y if this is a correct access key"
        read answer
        if ( [ "`/bin/echo "${answer}" | /bin/grep 'y'`" = "" ]  && [ "`/bin/echo "${answer}" | /bin/grep 'Y'`" = "" ] )
        then
            status "So, please input the access key of your cloudflare account"
            read DNS_SECURITY_KEY
            /bin/echo "${DNS_SECURITY_KEY}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-cloudflare-credentials/DNSSECURITYKEY
        fi
    fi
    DNS_CHOICE="cloudflare"
    /bin/echo ${DNS_CHOICE} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-cloudflare-credentials/DNSCHOICE
    ${BUILD_HOME}/providerscripts/dns/CreateZone.sh "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${WEBSITE_URL}" "${DNS_CHOICE}" "${DNS_REGION}"
elif ( [ "${choice}" = "2" ] )
then
    DNS_CHOICE="digitalocean"
    /bin/mkdir -p ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-digitalocean-credentials > /dev/null

    if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-digitalocean-credentials/DNSSECURITYKEY ] )
    then
       status "#####################################################################################################"
       status "We also need the access key for your digitalocean account. You can either request this from the domain owner"
       status "or if you are the domain owner, you can find it by authenticating to your digitalocean account, clicking "
       status "on your name at the top right and then clicking on 'Account Settings and you should find the access key "
       status "there and copy and paste it below"
       status "#####################################################################################################"
       status "Please input your digitalocean access key"
       read DNS_SECURITY_KEY
       /bin/echo ${DNS_SECURITY_KEY} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-digitalocean-credentials/DNSSECURITYKEY
       DNS_SECURITY_KEY="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-digitalocean-credentials/DNSSECURITYKEY`"
    else
       DNS_SECURITY_KEY="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-digitalocean-credentials/DNSSECURITYKEY`"
       status "Have found an access key stored from a previous build for your digitalocean account"
       status "It is set to: ${DNS_SECURITY_KEY}"
       status "Please enter Y/y if this is a correct access key"
       read answer
       if ( [ "`/bin/echo "${answer}" | /bin/grep 'y'`" = "" ]  && [ "`/bin/echo "${answer}" | /bin/grep 'Y'`" = "" ] )
       then
           status "So, please input the access key of your digitalocean account"
           read DNS_SECURITY_KEY
           /bin/echo "${DNS_SECURITY_KEY}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-digitalocean-credentials/DNSSECURITYKEY
       fi
   fi

   if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-digitalocean-credentials/DNSUSERNAME ] )
   then
       status "Please input your digital ocean Email Address"
       read DNS_USERNAME
       /bin/echo ${DNS_USERNAME} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-digitalocean-credentials/DNSUSERNAME
       DNS_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-digitalocean-credentials/DNSUSERNAME`"
   else
       DNS_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-digitalocean-credentials/DNSUSERNAME`"
       status "Have found an email address stored from a previous build for your digital ocean account"
       status "It is set to: ${DNS_USERNAME}"
       status "Please enter Y/y if this is a correct email address"
       read answer
            
       if ( [ "`/bin/echo "${answer}" | /bin/grep 'y'`" = "" ]  && [ "`/bin/echo "${answer}" | /bin/grep 'Y'`" = "" ] )
       then
           status "So, please input the access email address of your digital ocean account"
           read DNS_USERNAME
           /bin/echo "${DNS_USERNAME}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-digitalocean-credentials/DNSUSERNAME
       fi
   fi
elif ( [ "${choice}" = "3" ] )
then
    DNS_CHOICE="exoscale"
    /bin/mkdir -p ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials > /dev/null

    if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials/DNSSECURITYKEY ] )
    then
       status "#####################################################################################################"
       status "NOTE: Your DNS access key is a composite of your two exoscale keys with dns access, the access key and the secret key"
       status "Please enter these keys here as follows <exoscale dns access key>:<exoscale dns secret key>"
       status "#####################################################################################################"
       status "Please input your exoscale access key(s) - both access and secret separated with a colon"
       read DNS_SECURITY_KEY
       /bin/echo ${DNS_SECURITY_KEY} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials/DNSSECURITYKEY
       DNS_SECURITY_KEY="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials/DNSSECURITYKEY`"
    else
       DNS_SECURITY_KEY="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials/DNSSECURITYKEY`"
       status "Have found an access key stored from a previous build for your exoscale account"
       status "It is set to: ${DNS_SECURITY_KEY}"
       status "Please enter Y/y if this is a correct access key"
       read answer
       if ( [ "`/bin/echo "${answer}" | /bin/grep 'y'`" = "" ]  && [ "`/bin/echo "${answer}" | /bin/grep 'Y'`" = "" ] )
       then
           status "So, please input the access key of your exoscale account"
           read DNS_SECURITY_KEY
           /bin/echo "${DNS_SECURITY_KEY}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials/DNSSECURITYKEY
       fi
   fi

    if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials/DNSUSERNAME ] )
    then
        status "Please input your Exoscale Email Address"
        read DNS_USERNAME
        /bin/echo ${DNS_USERNAME} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials/DNSUSERNAME
        DNS_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials/DNSUSERNAME`"
    else
        DNS_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials/DNSUSERNAME`"
        status "Have found an email address stored from a previous build for your exoscale account"
        status "It is set to: ${DNS_USERNAME}"
        status "Please enter Y/y if this is a correct email address"
        read answer
        if ( [ "`/bin/echo "${answer}" | /bin/grep 'y'`" = "" ]  && [ "`/bin/echo "${answer}" | /bin/grep 'Y'`" = "" ] )
        then
            status "So, please input the access email address of your Exoscale account"
            read DNS_USERNAME
            /bin/echo "${DNS_USERNAME}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials/DNSUSERNAME
        fi
    fi
elif ( [ "${choice}" = "4" ] )
then
    DNS_CHOICE="linode"
    
    /bin/mkdir -p ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-linode-credentials > /dev/null

    if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-linode-credentials/DNSSECURITYKEY ] )
    then
       status "#####################################################################################################"
       status "NOTE: Your DNS access key is the same a personal acccess token for linode with domain manipulation rights"
       status "#####################################################################################################"
       status "Please input your linode access token"
       read DNS_SECURITY_KEY
       /bin/echo ${DNS_SECURITY_KEY} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-linode-credentials/DNSSECURITYKEY
       DNS_SECURITY_KEY="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-linode-credentials/DNSSECURITYKEY`"
    else
       DNS_SECURITY_KEY="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-linode-credentials/DNSSECURITYKEY`"
       status "Have found an access token stored from a previous build for your linode account"
       status "It is set to: ${DNS_SECURITY_KEY}"
       status "Please enter Y/y if this is a correct access key"
       read answer
       if ( [ "`/bin/echo "${answer}" | /bin/grep 'y'`" = "" ]  && [ "`/bin/echo "${answer}" | /bin/grep 'Y'`" = "" ] )
       then
           status "So, please input the access token of your linode account"
           read DNS_SECURITY_KEY
           /bin/echo "${DNS_SECURITY_KEY}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-linode-credentials/DNSSECURITYKEY
       fi
   fi

    if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-linode-credentials/DNSUSERNAME ] )
    then
        status "Please input your Linode Account Email Address"
        read DNS_USERNAME
        /bin/echo ${DNS_USERNAME} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-linode-credentials/DNSUSERNAME
        DNS_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-linode-credentials/DNSUSERNAME`"
    else
        DNS_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-linode-credentials/DNSUSERNAME`"
        status "Have found an email address stored from a previous build for your linode account"
        status "It is set to: ${DNS_USERNAME}"
        status "Please enter Y/y if this is a correct email address"
        read answer
        if ( [ "`/bin/echo "${answer}" | /bin/grep 'y'`" = "" ]  && [ "`/bin/echo "${answer}" | /bin/grep 'Y'`" = "" ] )
        then
            status "So, please input the access email address of your Linode account"
            read DNS_USERNAME
            /bin/echo "${DNS_USERNAME}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-linode-credentials/DNSUSERNAME
        fi
    fi
fi
