#!/bin/sh
#################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will retrieve all the record id's for the selected
# domain name (website url)
#################################################################################
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
###################################################################################
###################################################################################
#set -x

websiteurl="${2}"
domainurl="`/bin/echo ${2} | /usr/bin/cut -d'.' -f2-`"
subdomain="`/bin/echo ${2} | /usr/bin/awk -F'.' '{print $1}'`"
dns="${5}"

if ( [ "${dns}" = "digitalocean" ] )
then
    /usr/local/bin/doctl compute domain records list ${domainurl} | /bin/grep ${subdomain} | /usr/bin/awk '{print $1}'
fi

zoneid="${1}"
websiteurl="${2}"
email="${3}"
authkey="${4}"
dns="${5}"

/bin/echo "zoneid:${zoneid} email:${email} authkey:${authkey} websiteurl:${websiteurl} dns:${dns}" >> /tmp/getallrecords.log


if ( [ "${dns}" = "cloudflare" ] )
then
    /usr/bin/curl -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/dns_records?type=A&name=${websiteurl}&page=1&per_page=20&order=type&direction=desc&match=all" -H "X-Auth-Email: ${email}" -H "X-Auth-Key: ${authkey}" -H "Content-Type: application/json" | /usr/bin/jq '.result[].id' | /bin/sed 's/"//g'
fi

zoneid="${1}"
websiteurl="`/bin/echo ${2} | /usr/bin/cut -d'.' -f2-`"
email="${3}"
authkey="${4}"
dns="${5}"

if ( [ "${dns}" = "exoscale" ] )
then
    /usr/bin/curl  -H "X-DNS-Token: ${authkey}" -H 'Accept: application/json' https://api.exoscale.com/dns/v1/domains/${websiteurl}/records
fi

domainurl="`/bin/echo ${2} | /usr/bin/cut -d'.' -f2-`"
websiteurl="${2}"
username="${3}"
apikey="${4}"
dns="${5}"
region=${6}

if ( [ "${dns}" = "rackspace" ] )
then
    token="`/usr/bin/curl -s -X POST https://identity.api.rackspacecloud.com/v2.0/tokens -H "Content-Type: application/json" -d '{ "auth": { "RAX-KSKEY:apiKeyCredentials": { "username": "'${username}'", "apiKey": "'${apikey}'" } } }' | /usr/bin/python -m json.tool | /usr/bin/jq ".access.token.id" | /bin/sed 's/"//g'`"
    endpoint="`/usr/bin/curl -s -X POST https://identity.api.rackspacecloud.com/v2.0/tokens -H "Content-Type: application/json" -d '{ "auth": { "RAX-KSKEY:apiKeyCredentials": { "username": "'${username}'", "apiKey": "'${apikey}'" } } }' | /usr/bin/python -m json.tool | /usr/bin/jq ".access.serviceCatalog[].endpoints[].publicURL" | /bin/sed 's/"//g' | /bin/grep ${region} | /bin/grep dns`"
    domainid="`/usr/bin/curl -X GET -H "X-Auth-Token:${token}" -H "Accept:application/json" "${endpoint}/domains" | /usr/bin/python -m json.tool | /usr/bin/jq '.domains[] | select(.name=="'${domainurl}'") | .id'`"
    ids="`/usr/bin/curl -X GET -H "X-Auth-Token: ${token}" -H "Content-Type:application/json" "${endpoint}/domains/${domainid}/records" | /usr/bin/python -m json.tool | /usr/bin/jq '.records[] | select(.name=="'${websiteurl}'") | .id' | /bin/sed 's/"//g'`"
    idslist=""
    for id in $ids
    do
        if ( [ "`/bin/echo ${id} | /bin/grep "^A-"`" != "" ] )
        then
            idlist="${idlist} ${id}"
        fi
    done
    /bin/echo ${idlist}
fi
