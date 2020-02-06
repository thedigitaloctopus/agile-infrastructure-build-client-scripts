#!/bin/bash
###################################################################################
# Author: Peter Winter
# Date  : 12/07/2016
# Description : This script will generate an SSL Certificate
###################################################################################
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
##################################################################################
##################################################################################
#set -x

status () {
    /bin/echo "$1" | /usr/bin/tee /dev/fd/3
}


OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

#IP has been added to the DNS provider and now we have to set up the SSL certificate for this webserver

if ( [ "${SSL_GENERATION_METHOD}" = "AUTOMATIC" ] )
then
    if ( [ "${SSL_GENERATION_SERVICE}" = "LETSENCRYPT" ] )
    then
        if ( [ ! -d ${BUILD_HOME}/ssl/${WEBSITE_URL} ] )
        then
            /bin/mkdir -p ${BUILD_HOME}/ssl/${WEBSITE_URL}
        fi

        status "We are setting up an SSL certificate for our webserver so it can establish secure connections"

        # We now need to get our SSL certificate.
        # There's three cases. 1) We have a valid SSL certificate for this domain name on our filesystem and we simply copy that over to our new server
        # 		       2) We have an SSL certificate on our filesystem but it is expired, so we need to generate a new one and copy it over.
        #		       3) We have no SSL certificate on our filesystem so we need to generate a new one and copy that over to our server

        if ( [ "`/bin/ls ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem 2>/dev/null`" != "" ] &&
        [ "`/bin/ls ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem 2>/dev/null`" != "" ] )
        then
            # Get the current date as seconds since epoch.
            NOW=$(date +%s)
            # Get the expiry date of our certificate.
            EXPIRE=$(/usr/bin/openssl x509 -in ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem -noout -enddate)
            # Trim the unecessary text at the start of the string.
            EXPIRE="`/bin/echo ${EXPIRE} | /usr/bin/awk -F'=' '{print $2}'`"
            # Convert the expiry date to seconds since epoch.
            EXPIRE=$(date --date="$EXPIRE" +%s)
            # Calculate the time left until the certificate expires.
            LIFE=$((EXPIRE-NOW))
            # The remaining life on our certificate below which we should renew (7 days).
            #RENEW=604800
            RENEW=604800
            # If the certificate has less life remaining than we want.
            if ( [ "${LIFE}" -lt "${RENEW}" ] )
            then
                if ( [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ] )
                then
                    /bin/mv ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem.previous`/bin/date | /bin/sed 's/ //g'`
                fi

                if ( [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ] )
                then
                    /bin/mv ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem.previous`/bin/date | /bin/sed 's/ //g'`
                fi

                if ( [ -d ${BUILD_HOME}/.lego ] )
                then
                    /bin/mv ${BUILD_HOME}/.lego ${BUILD_HOME}/.lego-previous-`/bin/date | /bin/sed 's/ //g'`
                fi

                . ${BUILD_HOME}/providerscripts/server/ObtainSSLCertificate.sh

                if ( [ -f ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.crt ] && [ -f ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.key ] )
                then
                    /bin/mv ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.crt ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem
                    /bin/mv ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.key ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem
                    /bin/cat ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem > ${BUILD_HOME}/ssl/${WEBSITE_URL}/ssl.pem
                    /bin/cp ${BUILD_HOME}/ssl/${WEBSITE_URL}/ssl.pem ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem
                    /bin/mv ${BUILD_HOME}/ssl/${WEBSITE_URL}/ssl.pem ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem
                    /bin/cp ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.json ${BUILD_HOME}/ssl/${WEBSITE_URL}/${WEBSITE_URL}.json
                fi

                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/mkdir -p /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}"
                /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/fullchain.pem
                /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/${WEBSITE_URL}.json ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/${WEBSITE_URL}.json
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/cp /home/${SERVER_USER}/.ssh/fullchain.pem /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}/fullchain.pem"
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/cp /home/${SERVER_USER}/.ssh/${WEBSITE_URL}.json /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}/${WEBSITE_URL}.json"
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/fullchain.pem"
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/${WEBSITE_URL}.json"
                /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/privkey.pem
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/cp /home/${SERVER_USER}/.ssh/privkey.pem /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}/privkey.pem"
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO}  /bin/chmod 400 /home/${SERVER_USER}/.ssh/privkey.pem"


                if (    [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ] &&
                    [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ]  &&
                [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/${WEBSITE_URL}.json ] )
                then
                    /bin/chmod 400 ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem
                    /bin/chmod 400 ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem
                    /bin/chmod 400 ${BUILD_HOME}/ssl/${WEBSITE_URL}/${WEBSITE_URL}.json
                else
                    status "Something seems to be a bit wrong. We were trying to generate a new SSL ceritificate on the webserver, but, it doesn't seem to have been generated"
                    status "Can't operate without it, this is a secure system, so have to exit. Please investigate in ${BUILD_HOME}/logs"
                    exit
                fi
            else
                #The ceritificate was valid, so just copy it straight onto our webserver ready for use
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/mkdir -p /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}"
                /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/fullchain.pem
                /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/${WEBSITE_URL}.json ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/${WEBSITE_URL}.json
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/cp /home/${SERVER_USER}/.ssh/fullchain.pem /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}/fullchain.pem"
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/cp /home/${SERVER_USER}/.ssh/${WEBSITE_URL}.json /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}/${WEBSITE_URL}.json"
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/fullchain.pem"
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/${WEBSITE_URL}.json"
                /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/privkey.pem
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/cp /home/${SERVER_USER}/.ssh/privkey.pem /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}/privkey.pem"
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO}  /bin/chmod 400 /home/${SERVER_USER}/.ssh/privkey.pem"
            fi
        else

            if ( [ -d ${BUILD_HOME}/.lego ] )
            then
                /bin/mv ${BUILD_HOME}/.lego ${BUILD_HOME}/.lego-previous-`/bin/date | /bin/sed 's/ //g'`
            fi

            #There was no certificate so generate one and copy it back to the build client for later use
            . ${BUILD_HOME}/providerscripts/server/ObtainSSLCertificate.sh

            if ( [ -f ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.crt ] && [ -f ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.key ] )
            then
                #All this is about is putting the generated certificate files in the right place on our nice new webserver
                /bin/mv ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.crt ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem
                /bin/mv ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.key ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem
                /bin/mv ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.json ${BUILD_HOME}/ssl/${WEBSITE_URL}/${WEBSITE_URL}.json
                /bin/cat ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem > ${BUILD_HOME}/ssl/${WEBSITE_URL}/ssl.pem
                /bin/cp ${BUILD_HOME}/ssl/${WEBSITE_URL}/ssl.pem ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem
                /bin/mv ${BUILD_HOME}/ssl/${WEBSITE_URL}/ssl.pem ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem


                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/mkdir -p /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}"
                /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/fullchain.pem
                /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/${WEBSITE_URL}.json ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/${WEBSITE_URL}.json
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/cp /home/${SERVER_USER}/.ssh/fullchain.pem /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}/fullchain.pem"
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/cp /home/${SERVER_USER}/.ssh/${WEBSITE_URL}.json /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}/${WEBSITE_URL}.json"
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/fullchain.pem"
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/${WEBSITE_URL}.json"
                /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/privkey.pem
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/cp /home/${SERVER_USER}/.ssh/privkey.pem /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}/privkey.pem"
                /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/privkey.pem"


                if (    [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ] &&
                    [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ] &&
                [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/${WEBSITE_URL}.json ] )
                then
                    /bin/chmod 400 ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem
                    /bin/chmod 400 ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem
                    /bin/chmod 400 ${BUILD_HOME}/ssl/${WEBSITE_URL}/${WEBSITE_URL}.json
                else
                    status "Something seems to be a bit wrong. We were trying to generate a new SSL ceritificate on the webserver, but, it doesnt seem to have been generated"
                    status "Cant operate without it, this is a secure system, so have to quit. Please investigate ${BUILD_HOME}/logs"
                    exit
                fi
            fi
        fi

    fi
fi
if ( [ "${SSL_GENERATION_METHOD}" = "MANUAL" ] )
then
    response="INPUTNEW"

    if ( [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ] && [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ] )
    then
        status "There is a certificate I can use. Do you want me to use that?, or are you going to give me a new one?"
        status "Found a certificate for this domain. For your info, this is its expiry date"
        /usr/bin/openssl x509 -in ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem -noout -enddate
        status "Please enter Y to use the existing one. Anything else to input a new one"
        read response
    fi
    if ( ( [ "${response}" != "Y" ] && [ "${response}" != "y" ] ) || [ "${response}" = "INPUTNEW" ] )
    then
        if ( [ ! -d ${BUILD_HOME}/ssl/${WEBSITE_URL} ] )
        then
            /bin/mkdir -p ${BUILD_HOME}/ssl/${WEBSITE_URL}
        fi

        status "You have selected the manual method of generating an SSL certificate. This presumes that you have the necessary SSL files from a 3rd party"
        status "Certificate provider. So, here I will have to ask you to input the certificates so that I can pass them over to your servers"
        status "So, mate, please paste your certificate chain here. <ctrl d> when done"
        status "ESSENTIAL - Only copy from the first dash in the file '-' to the last dash in the file. Do not copy any prefixed whitespace or suffixed whitespace"

        fullchain=`cat`
        /bin/echo "${fullchain}" > ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem
        /bin/chmod 400 ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem

        status "Cheers. So, mate, please paste your certifcate key here. <ctrl d> when done"
        status "ESSENTIAL - Only copy from the first dash in the file '-' to the last dash in the file. Do not copy any prefixed whitespace or suffixed whitespace"

        privkey=`cat`
        /bin/echo "${privkey}" > ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem
        /bin/chmod 400 ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem
    fi

    /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/mkdir -p /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}"
    /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/fullchain.pem
    /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/cp /home/${SERVER_USER}/.ssh/fullchain.pem /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}/fullchain.pem"
    /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/chmod 400 /home/${SERVER_USER}/.ssh/fullchain.pem"
    /usr/bin/scp -P ${SSH_PORT} ${OPTIONS} ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/privkey.pem
    /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO} /bin/cp /home/${SERVER_USER}/.ssh/privkey.pem /home/${SERVER_USER}/ssl/live/${WEBSITE_URL}/privkey.pem"
    /usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ip} "${SUDO}  /bin/chmod 400 /home/${SERVER_USER}/.ssh/privkey.pem"
fi
