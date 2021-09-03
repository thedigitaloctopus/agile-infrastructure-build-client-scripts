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
status "#####We currently support 0: None 1: Cloudflare 2: Rackspace 3: Digital Ocean                   #####"
status "#####                     4: Exoscale                                                           #####"
status "#####################################################################################################"
status "Please select a DNS provider (0|1|2)"
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
    while ( [ "`${BUILD_HOME}/providerscripts/dns/CreateZone.sh "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${WEBSITE_URL}" "${DNS_CHOICE}" "${DNS_REGION}"`" = "-1" ] )
    do
        status "Can't find valid credentials to authenticate to rackspace. Please enter or modify the credentials you have supplied"
        /bin/mkdir -p ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials
        if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSUSERNAME ] )
        then
            status "Please enter your Rackspace username"
            read DNS_USERNAME
            /bin/echo ${DNS_USERNAME} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSUSERNAME
        else
            DNS_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSUSERNAME`"
            status "Have found a username stored from a previous build for your Rackspace account"
            status "It is set to: ${DNS_USERNAME}"
            status "Please enter Y/y if this is a correct username"
            read answer
            if ( [ "`/bin/echo "${answer}" | /bin/grep 'y'`" = "" ]  && [ "`/bin/echo "${answer}" | /bin/grep 'Y'`" = "" ] )
            then
                status "So, please input the username of your rackspace account"
                read DNS_USERNAME
                /bin/echo "${DNS_USERNAME}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSUSERNAME
            fi
        fi

        if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSSECURITYKEY ] )
        then
            status "#####################################################################################################"
            status "We also need the API key for your rackspace account. You can either request this from the domain owner"
            status "or if you are the domain owner, you can find it by authenticating to your rackspace account, clicking "
            status "on your name at the top right and then clicking on 'Account Settings and you should find the API key "
            status "there and copy and paste it below"
            status "#####################################################################################################"
            status "Please input your rackspace API key"
            read DNS_SECURITY_KEY
            /bin/echo ${DNS_SECURITY_KEY} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSSECURITYKEY
            DNS_SECURITY_KEY="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSSECURITYKEY`"
        else
            DNS_SECURITY_KEY="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSSECURITYKEY`"
            status "Have found an access key stored from a previous build for your rackspace account"
            status "It is set to: ${DNS_SECURITY_KEY}"
            status "Please enter Y/y if this is a correct access key"
            read answer
            if ( [ "`/bin/echo "${answer}" | /bin/grep 'y'`" = "" ]  && [ "`/bin/echo "${answer}" | /bin/grep 'Y'`" = "" ] )
            then
                status "So, please input the access key of your rackspace account"
                read DNS_SECURITY_KEY
                /bin/echo "${DNS_SECURITY_KEY}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSSECURITYKEY
            fi
        fi

        if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSUSERNAME ] )
        then
            status "Please input your rackspace Email Address"
            read DNS_USERNAME
            /bin/echo ${DNS_USERNAME} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSUSERNAME
            DNS_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSUSERNAME`"
        else
            DNS_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSUSERNAME`"
            status "Have found an email address stored from a previous build for your rackspace account"
            status "It is set to: ${DNS_USERNAME}"
            status "Please enter Y/y if this is a correct email address"
            read answer
            if ( [ "`/bin/echo "${answer}" | /bin/grep 'y'`" = "" ]  && [ "`/bin/echo "${answer}" | /bin/grep 'Y'`" = "" ] )
            then
                status "So, please input the access email address of your rackspace account"
                read DNS_USERNAME
                /bin/echo "${DNS_USERNAME}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSUSERNAME
            fi
        fi
        if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSREGION ] )
        then
            answer=""
            DNS_REGION=""
            while ( [ "${DNS_REGION}" = "" ] )
            do
                status "Please enter the three letter identifier for the region you wish to deploy to from the following list"
                status "Dallas - DFW, Chicago - ORD, Virginia IAD, London LON, Sydney SYD, Hong Kon HKG"
                read answer
                if ( [ "`/bin/echo "DFW ORD IAD LON SYD HKG" | /bin/grep ${answer}`" != "" ] )
                then
                    DNS_REGION="`/bin/echo ${answer} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
                    /bin/echo "${DNS_REGION}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSREGION
                fi
            done
        else
            DNS_REGION="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSREGION`"
            status "Have found an selected region stored from a previous build for your rackspace web dns account"
            status "It is set to: ${DNS_REGION}"
            status "Please enter Y/y if this is a correct region"
            read answer
            if ( [ "`/bin/echo "${answer}" | /bin/grep 'y'`" = "" ]  && [ "`/bin/echo "${answer}" | /bin/grep 'Y'`" = "" ] )
            then
                answer=""
                DNS_REGION=""
                while ( [ "${DNS_REGION}" = "" ] )
                do
                    status "Please enter the three letter identifier for the region you wish to deploy to from the following list"
                    status "Dallas - DFW, Chicago - ORD, Virginia IAD, London LON, Sydney SYD, Hong Kon HKG"
                    read answer
                    if ( [ "`/bin/echo "DFW ORD IAD LON SYD HKG" | /bin/grep ${answer}`" != "" ] )
                    then
                        DNS_REGION="`/bin/echo ${answer} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
                        /bin/echo "${DNS_REGION}" > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSREGION
                    fi
                done
            fi
        fi
        DNS_CHOICE="rackspace"
        /bin/echo ${DNS_CHOICE} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-rackspace-credentials/DNSCHOICE
    done
elif ( [ "${choice}" = "3" ] )
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
elif ( [ "${choice}" = "4" ] )
then
    DNS_CHOICE="exoscale"
    /bin/mkdir -p ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials > /dev/null

    if ( [ ! -f ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-exoscale-credentials/DNSSECURITYKEY ] )
    then
       status "#####################################################################################################"
       status "We also need the access key for your exoscale account. You can either request this from the domain owner"
       status "or if you are the domain owner, you can find it by authenticating to your digitalocean account, clicking "
       status "on your name at the top right and then clicking on 'Account Settings and you should find the access key "
       status "there and copy and paste it below"
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
fi
