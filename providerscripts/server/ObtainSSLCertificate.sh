#!/bin/sh
#####################################################################################
# Description: This is a script which will generate an SSL Certificate. When a webserver
# is being built from the build client and not through the autoscaling mechanism, there
# are 3 scenarios
#
# 1) No certificate has been issued for the current domain name before in which case,
# one is generated and stored in the build directory hierarchy where it can be retrieved later
#
# 2) A certificate has been generated before for this domain name and we want to reuse it
# by selecting it from the build client filesystem where we stored it in 1. In this case,
# this script will not be used to generate a certificate.
#
# 3) There is a previously issued certificate we can use, but, it has expired, in which case
# this script will be used to generate a new certificate.
#
# Something to be aware of. There are limits set on certificate issuance so, if you run
# scenario 1, several times for some reason - it shouldn't happen in normal usage, then,
# you will hit the limit and certificates will stop being issued. In this case, it is
# necessary to wait some days and then the servers will see that you haven't issued
# certificates for a period and then reallow issuance and so on.
#####################################################################################
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

SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

if ( [ ! -d /usr/local/go ] )
then
    ${BUILD_HOME}/installscripts/InstallGo.sh ${BUILDOS}
fi

export GOROOT=/usr/local/go
export GOPATH=$HOME
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

if ( [ ! -f /usr/bin/lego ] )
then
    ${BUILD_HOME}/installscripts/InstallLego.sh ${BUILDOS}
fi

DOMAIN_URL="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F':' '{print $NF}' | /usr/bin/awk -F'.' '{$1="";print}' | /bin/sed 's/^ //' | /bin/sed 's/ /./g'`"

if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
then

    #For production
    if ( [ "${PRODUCTION}" = "1" ] && [ "${DEVELOPMENT}" = "0" ] )
    then
        command="CLOUDFLARE_EMAIL="${DNS_USERNAME}" CLOUDFLARE_API_KEY="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
    fi
    #For Testing
    if ( [ "${PRODUCTION}" = "0" ] && [ "${DEVELOPMENT}" = "1" ] )
    then
        command="CLOUDFLARE_EMAIL="${DNS_USERNAME}" CLOUDFLARE_API_KEY="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --server=https://acme-staging-v02.api.letsencrypt.org/directory --dns-timeout=120 --accept-tos run"
    fi
    
    if ( [ "${HARDCORE}" = "1" ] )
    then
        export CLOUDFLARE_EMAIL="${DNS_USERNAME}" 
        export CLOUDFLARE_API_KEY="${DNS_SECURITY_KEY}"
        
        #Production
        if ( [ "${PRODUCTION}" = "1" ] && [ "${DEVELOPMENT}" = "0" ] )
        then
            command="/usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
        fi
        
        #Testing
        if ( [ "${PRODUCTION}" = "0" ] && [ "${DEVELOPMENT}" = "1" ] )
        then
            command="/usr/bin/lego --email="${DNS_USERNAME}" --server=https://acme-staging-v02.api.letsencrypt.org/directory --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
        fi
        
        while ( [ "`/usr/bin/find ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.issuer.crt -mmin -5 2>/dev/null`" = "" ] )
        do
            status "Valid Certificate not found, trying to issue SSL certificate for your domain ${WEBSITE_URL}"
            eval ${command}
            /bin/sleep 10
        done
    else
        status ""
        status ""
        status "##################################################################################################"
        status ""
        status "WE NEED A NEW SSL CERTRIFICATE. FOLLOW THESE STEPS EXACLTY AND THINGS WILL BE FINE..."
        status ""
        status " 1) Open up a new terminal on your build client machine - something like:"
        status "------------COMMAND-----------------"
        status "    /usr/bin/ssh ${BUILD_CLIENT_IP}"
        status "------------COMMAND-----------------"
        status ""
        status " 2) Precisely and carefully change working directory to your build home directory, precisely like:"
        status "-----------------COMMAND--------------------------"
        status "    cd ${BUILD_HOME}"
        status "-----------------COMMAND--------------------------"
        status ""
        status " 3) Issue the following command (you can copy and paste it all onto the command line of your new terminal window) "
        status "     ------------------------------------------COMMAND-------------------------------------------"
        status "       ${command} "
        status "     ------------------------------------------COMMAND-------------------------------------------"
        status ""
        status " 4) Check that there is a directory ${BUILD_HOME}/.lego that has up to date (check the timestamp) certificates in it"
        status ""
        status "   Also, when you issue the command it should say whether a certificate was successfully generated or not"
        status ""
        status "###################################################################################################"
        status "Once you have done all that, you can press the <enter> key to continue with the build"
        status ""
        status ""
        read x
    fi
fi

if ( [ "${DNS_CHOICE}" = "rackspace" ] )
then

    #We use our git email address for rackspace because all rackspace requires is a username
    #For production
    
   if ( [ "${PRODUCTION}" = "1" ] && [ "${DEVELOPMENT}" = "0" ] )
   then
       command="RACKSPACE_USER="${DNS_USERNAME}" RACKSPACE_API_KEY="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
   fi

   if ( [ "${PRODUCTION}" = "0" ] && [ "${DEVELOPMENT}" = "1" ] )
   then
        command="RACKSPACE_USER="${DNS_USERNAME}" RACKSPACE_API_KEY="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --server=https://acme-staging-v02.api.letsencrypt.org/directory --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}"  --server=https://acme-staging-v02.api.letsencrypt.org/directory --dns-timeout=120 --accept-tos run"
    fi
    
    if ( [ "${HARDCORE}" = "1" ] )
    then
        export RACKSPACE_USER="${DNS_USERNAME}" 
        export RACKSPACE_API_KEY="${DNS_SECURITY_KEY}"
        
        if ( [ "${PRODUCTION}" = "1" ] && [ "${DEVELOPMENT}" = "0" ] )
        then
            command="/usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
        fi
        
        if ( [ "${PRODUCTION}" = "0" ] && [ "${DEVELOPMENT}" = "1" ] )
        then
            command="/usr/bin/lego --email="${DNS_USERNAME}" --server=https://acme-staging-v02.api.letsencrypt.org/directory --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
        fi
        
        while ( [ "`/usr/bin/find ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.issuer.crt -mmin -5 2>/dev/null`" = "" ] )
        do
            status "Valid Certificate not found, trying to issue SSL certificate for your domain ${WEBSITE_URL}"
            eval ${command}
            /bin/sleep 10
        done
    else
        status ""
        status ""
        status "##################################################################################################"
        status ""
        status "WE NEED A NEW SSL CERTRIFICATE. FOLLOW THESE STEPS EXACLTY AND THINGS WILL BE FINE..."
        status ""
        status " 1) Open up a new terminal on your build client machine - something like:"
        status "------------COMMAND-----------------"
        status "    /usr/bin/ssh ${BUILD_CLIENT_IP}"
        status "------------COMMAND-----------------"
        status ""
        status " 2) Precisely and carefully change working directory to your build home directory, precisely like:"
        status "-----------------COMMAND--------------------------"
        status "    cd ${BUILD_HOME}"
        status "-----------------COMMAND--------------------------"
        status ""
        status " 3) Issue the following command (you can copy and paste it all onto the command line of your new terminal window) "
        status "     ------------------------------------------COMMAND-------------------------------------------"
        status "       ${command} "
        status "     ------------------------------------------COMMAND-------------------------------------------"
        status ""
        status " 4) Check that there is a directory ${BUILD_HOME}/.lego that has up to date (check the timestamp) certificates in it"
        status ""
        status "   Also, when you issue the command it should say whether a certificate was successfully generated or not"
        status ""
        status "###################################################################################################"
        status "Once you have done all that, you can press the <enter> key to continue with the build"
        status ""
        status ""
        read x
    fi
fi

if ( [ "${DNS_CHOICE}" = "digitalocean" ] )
then
    #For production
    if ( [ "${PRODUCTION}" = "1" ] && [ "${DEVELOPMENT}" = "0" ] )
    then
        command="DO_AUTH_TOKEN="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
    fi
    
    if ( [ "${PRODUCTION}" = "0" ] && [ "${DEVELOPMENT}" = "1" ] )
    then
        command="DO_AUTH_TOKEN="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --server=https://acme-staging-v02.api.letsencrypt.org/directory --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
    fi
    
    if ( [ "${HARDCORE}" = "1" ] )
    then
        export DO_AUTH_TOKEN="${DNS_SECURITY_KEY}"
        
        #For production
        if ( [ "${PRODUCTION}" = "1" ] && [ "${DEVELOPMENT}" = "0" ] )
        then
            command="/usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
        fi
        #For testing 
        if ( [ "${PRODUCTION}" = "0" ] && [ "${DEVELOPMENT}" = "1" ] )
        then
            command="/usr/bin/lego --email="${DNS_USERNAME}" --server=https://acme-staging-v02.api.letsencrypt.org/directory --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
        fi
        
        while ( [ "`/usr/bin/find ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.issuer.crt -mmin -5 2>/dev/null`" = "" ] )
        do
            status "Valid Certificate not found, trying to issue SSL certificate for your domain ${WEBSITE_URL}"
            eval ${command}
            /bin/sleep 10
        done
    else
        status ""
        status ""
        status "##################################################################################################"
        status ""
        status "WE NEED A NEW SSL CERTRIFICATE. FOLLOW THESE STEPS EXACLTY AND THINGS WILL BE FINE..."
        status ""
        status " 1) Open up a new terminal on your build client machine - something like:"
        status "------------COMMAND-----------------"
        status "    /usr/bin/ssh ${BUILD_CLIENT_IP}"
        status "------------COMMAND-----------------"
        status ""
        status " 2) Precisely and carefully change working directory to your build home directory, precisely like:"
        status "-----------------COMMAND--------------------------"
        status "    cd ${BUILD_HOME}"
        status "-----------------COMMAND--------------------------"
        status ""
        status " 3) Issue the following command (you can copy and paste it all onto the command line of your new terminal window) "
        status "     ------------------------------------------COMMAND-------------------------------------------"
        status "       ${command} "
        status "     ------------------------------------------COMMAND-------------------------------------------"
        status ""
        status " 4) Check that there is a directory ${BUILD_HOME}/.lego that has up to date (check the timestamp) certificates in it"
        status ""
        status "   Also, when you issue the command it should say whether a certificate was successfully generated or not"
        status ""
        status "###################################################################################################"
        status "Once you have done all that, you can press the <enter> key to continue with the build"
        status ""
        status ""
        read x
    fi
fi

if ( [ "${DNS_CHOICE}" = "exoscale" ] )
then
    EXOSCALE_API_KEY="`/bin/echo ${DNS_SECURITY_KEY} | /usr/bin/awk -F':' '{print $1}'`"
    EXOSCALE_API_SECRET="`/bin/echo ${DNS_SECURITY_KEY} | /usr/bin/awk -F':' '{print $2}'`"

    #For production
    if ( [ "${PRODUCTION}" = "1" ] && [ "${DEVELOPMENT}" = "0" ] )
    then
        command="EXOSCALE_API_KEY=${EXOSCALE_API_KEY} EXOSCALE_API_SECRET=${EXOSCALE_API_SECRET} /usr/bin/lego --email ${DNS_USERNAME} --dns ${DNS_CHOICE} --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
    fi
    
    if ( [ "${PRODUCTION}" = "0" ] && [ "${DEVELOPMENT}" = "1" ] )
    then
        command="EXOSCALE_API_KEY=${EXOSCALE_API_KEY} EXOSCALE_API_SECRET=${EXOSCALE_API_SECRET} /usr/bin/lego --email ${DNS_USERNAME} --server=https://acme-staging-v02.api.letsencrypt.org/directory --dns ${DNS_CHOICE} --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
    fi
    
    if ( [ "${HARDCORE}" = "1" ] )
    then
        #For production
        if ( [ "${PRODUCTION}" = "1" ] && [ "${DEVELOPMENT}" = "0" ] )
        then
            command="EXOSCALE_API_KEY=${EXOSCALE_API_KEY} EXOSCALE_API_SECRET=${EXOSCALE_API_SECRET} /usr/bin/lego --email ${DNS_USERNAME} --dns ${DNS_CHOICE} --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
        fi
        #For testing 
        if ( [ "${PRODUCTION}" = "0" ] && [ "${DEVELOPMENT}" = "1" ] )
        then
            command="EXOSCALE_API_KEY=${EXOSCALE_API_KEY} EXOSCALE_API_SECRET=${EXOSCALE_API_SECRET} /usr/bin/lego --email ${DNS_USERNAME} --server=https://acme-staging-v02.api.letsencrypt.org/directory --dns ${DNS_CHOICE} --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
        fi
        
        while ( [ "`/usr/bin/find ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.issuer.crt -mmin -5 2>/dev/null`" = "" ] )
        do
            status "Valid Certificate not found, trying to issue SSL certificate for your domain ${WEBSITE_URL}"
            eval ${command}
            /bin/sleep 10
        done
    else
        status ""
        status ""
        status "##################################################################################################"
        status ""
        status "WE NEED A NEW SSL CERTRIFICATE. FOLLOW THESE STEPS EXACLTY AND THINGS WILL BE FINE..."
        status ""
        status " 1) Open up a new terminal on your build client machine - something like:"
        status "------------COMMAND-----------------"
        status "    /usr/bin/ssh ${BUILD_CLIENT_IP}"
        status "------------COMMAND-----------------"
        status ""
        status " 2) Precisely and carefully change working directory to your build home directory, precisely like:"
        status "-----------------COMMAND--------------------------"
        status "    cd ${BUILD_HOME}"
        status "-----------------COMMAND--------------------------"
        status ""
        status " 3) Issue the following command (you can copy and paste it all onto the command line of your new terminal window) "
        status "     ------------------------------------------COMMAND-------------------------------------------"
        status "       ${command} "
        status "     ------------------------------------------COMMAND-------------------------------------------"
        status ""
        status " 4) Check that there is a directory ${BUILD_HOME}/.lego that has up to date (check the timestamp) certificates in it"
        status ""
        status "   Also, when you issue the command it should say whether a certificate was successfully generated or not"
        status ""
        status "###################################################################################################"
        status "Once you have done all that, you can press the <enter> key to continue with the build"
        status ""
        status ""
        read x
    fi
fi
