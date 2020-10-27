#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2020
# Description: This will configure the ~/.s3cfg tool for use with s3cmd. It checks that
# the supplied configuration is working correctly before accepting it
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
####################################################################################
####################################################################################
#set -x

if ( [ ! -f /usr/bin/s3cmd ] )
then
    ${BUILD_HOME}/providerscripts/datastore/InstallDatastoreTools.sh 'S3CMD' ${BUILDOS}
fi

/usr/bin/s3cmd mb s3://1$$agile 3>&1
/usr/bin/s3cmd rb s3://1$$agile 3>&1

while ( [ "$?" != "0" ] )
do
    if ( [ "${S3_ACCESS_KEY}" = "" ] || [ "${S3_SECRET_KEY}" = "" ] || [ "${S3_HOST_BASE}" = "" ] || [ "${S3_ENCRYPTION_PASSWORD}" = "" ] )
    then
        status "Your Datastore configuration is not set up correctly, please take a moment to configure it"
    
        status ""
        status "I want to setup your S3 datastore. For this to be possible, I will need a few pieces of information from you"
        status "###################################################################################################################################"
        status "Please tell me the access key for your S3 datastore service provider"
        status "You can create these keys via the GUI system of your cloudhost according to their documentation"
        status "The keys or personal access tokens you create should follow the principle of least privilege meaning that you only grant the power to modify the Object Store"
        status "to these keys and not other capabilities as well"
        status "###################################################################################################################################"
        status "Please enter your access key"
        read S3_ACCESS_KEY

        status ""
        status "Please also tell me the secret key for your S3 datastore service provider"
        read S3_SECRET_KEY

        status ""

        status "We need to set up a hostbase value"
        status "###################################################################################################################################"
        status "Some example hostbases for different providers are:"
        status "Digital Ocean: ams3.digitaloceanspaces.com"
        status "Exoscale:"
        status "Linode:"
        status "Vultr:"
        status "Amazon:"
        status "The hostbase you provide here should be of a similar format based on the provider you are using for your S3 compatible object store"
        status "###################################################################################################################################"
        status "Please tell me the hostbase for your S3 datastore service provider"
        read S3_HOST_BASE

        status ""
        status "Please enter a password for in transit encryption to your datastore (make a note of it or look in ~/.s3cfg if you need a reminder"
        read S3_ENCRYPTION_PASSWORD
    fi

    /bin/echo "[default]
access_key = ${S3_ACCESS_KEY}
bucket_location = US
host_base = ${S3_HOST_BASE}
host_bucket = %(bucket)s.${S3_HOST_BASE}
secret_key = ${S3_SECRET_KEY}
check_ssl_certificate = True
check_ssl_hostname = True
gpg_command = /usr/bin/gpg
gpg_decrypt = %(gpg_command)s -d --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_encrypt = %(gpg_command)s -c --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_passphrase = ${S3_ENCRYPTION_PASSWORD} " > ~/.s3cfg

    /usr/bin/s3cmd mb s3://1$$agile 3>&1
    /usr/bin/s3cmd rb s3://1$$agile 3>&1
done

/bin/cp ~/.s3cfg ${BUILD_HOME}/.s3cfg.${CLOUDHOST}  
