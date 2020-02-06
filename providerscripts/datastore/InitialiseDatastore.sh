#!/bin/sh
###################################################################################
# Description: This script will initialise the datastore tools parameters to that the
# tools can be used
# Date : 07-11-16
# Author: Peter Winter
##################################################################################
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

status () {
    /bin/echo "$1" | /usr/bin/tee /dev/fd/3
}

datastore_provider="${1}"
buildos="${2}"

if ( [ "${datastore_provider}" = "amazonS3" ] )
then
    if ( [ ! -f /usr/bin/s3cmd ] )
    then
        ${BUILD_HOME}/providerscripts/datastore/InstallDatastoreTools.sh 'S3CMD' ${buildos}
    fi

    if ( [ -f ${BUILD_HOME}/.s3cfg.amazon ] )
    then
        status "I have found a configuration for an amazon datastore. Do you want me to display it to you? (Y|N)"
        read response
        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
        then
            status "==================================================================================================================="
            status "`/bin/cat ${BUILD_HOME}/.s3cfg.amazon`"
            status "==================================================================================================================="
        fi

        status "So, is the existing configuration acceptable to you? If you know it is or can see that it is, then enter Y else enter N to reconfigure it"
        read response
        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
        then
            status "OK, using existing configuration, press <enter> to continue"
            /bin/cp ${BUILD_HOME}/.s3cfg.amazon ~/.s3cfg
            read
        else
            /bin/rm ${BUILD_HOME}/.s3cfg.amazon
        fi
    fi

    while ( [ ! -f ${BUILD_HOME}/.s3cfg.amazon ] )
    do
        status "You need to configure your datastore tools. You can get your access keys by going to your AWS account at aws.amazon.com and following the instructions"
        status "NOTE: you can alternatively configure for digital ocean spaces if you like, more info :"
        status "https://www.digitalocean.com/community/tutorials/how-to-configure-s3cmd-2-x-to-manage-digitalocean-spaces"
        status "****IMPORTANT NOTE***** For AWS choose a secret key which has no forward slashes in it as this will cause issues later on"
        /usr/bin/s3cmd --configure >&3
        /bin/cp ~/.s3cfg ${BUILD_HOME}/.s3cfg.amazon
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/amazonS3
    done
fi

if ( [ "${datastore_provider}" = "digitalocean" ] )
then
    if ( [ ! -f /usr/bin/s3cmd ] )
    then
        ${BUILD_HOME}/providerscripts/datastore/InstallDatastoreTools.sh 'S3CMD' ${buildos}
    fi

    if ( [ -f ${BUILD_HOME}/.s3cfg.digitalocean ] )
    then
        status "I have found a configuration for an digital ocean datastore. Do you want me to display it to you? (Y|N)"
        read response
        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
        then
            status "==================================================================================================================="
            status "`/bin/cat ${BUILD_HOME}/.s3cfg.digitalocean`"
            status "==================================================================================================================="
        fi

        status "So, is the existing configuration acceptable to you? If you know it is or can see that it is, then enter Y else enter N to reconfigure it"
        read response
        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
        then
            status "OK, using existing configuration, press <enter> to continue"
            /bin/cp ${BUILD_HOME}/.s3cfg.digitalocean ~/.s3cfg
            read
        else
            /bin/rm ${BUILD_HOME}/.s3cfg.digitalocean
        fi
    fi

    while ( [ ! -f ${BUILD_HOME}/.s3cfg.digitalocean ] )
    do
        status "Please tell us the endpoint for your digital ocean spaces (for example, ams3.digitaloceanspaces.com)"
        read DIGITAL_OCEAN_SPACES_ENDPOINT

        status "You need to configure your datastore tools. You can get your access keys by going to your digital ocean account and using the API menu"
        status "Once you have your keys, please use them in the following configuration"

        status "====================================================================================================================================="
        status "Oddly, we have to run the configuration tool twice for technical reasons. Each time it runs, the procedure is a little different"
        status "The first time it runs,  follow these steps"
        status "   1) Enter your access keys as you obtained them from digital ocean"
        status "   2) Just press enter key for all subsequent options until it says, 'test connection' it will fail but that's OK and expected"
        status "   3) When it asks if you want to save your configuration, say yes"
        status "   4) Don't re run the configuration process, it will rerun itself"
        status "The second time it runs, press enter to all the options and then say 'yes' to test the configuration and select yes to save configuration"
        status "====================================================================================================================================="
        status "Press the enter key to begin the configuration"
        status ""
        read x
        status "========================================================================================================"
        status "ESSENTIAL NOTE FOR CORRECT OPERATION. THE BUCKET(S) LOCATION HAS TO BE SET TO 'US' FOR CORRECT OPERATION"
        status "IT'S A LITTLE CONFUSING AND TECHNICALLY A BUG, BUT EVEN WITH THE LOCATION MANDATED TO BE US IN ALL CASES"
        status "BUCKETS WILL STILL BE CREATED ACCORDING TO THE ENDPOINT YOU HAVE JUST SET, I.E. FOR EXAMPLE, AMS"
        status "========================================================================================================"
        /usr/bin/s3cmd --configure >&3
        /bin/sed -i "s/^host_base.*/host_base = ${DIGITAL_OCEAN_SPACES_ENDPOINT}/" ~/.s3cfg
        /bin/sed -i "s/^host_bucket.*/host_bucket = %(bucket)s.${DIGITAL_OCEAN_SPACES_ENDPOINT}/" ~/.s3cfg
        status "=================================================================================================================================="
        status "FOR THIS PROVIDER IT IS NECESSARY TO RECONFIRM ALL THE DETAILS YOU HAVE SET. PLEASE JUST REPEATEDLY PRESS <ENTER> TO ACCEPT AS SET"
        status "=================================================================================================================================="
        /usr/bin/s3cmd --configure >&3
        /bin/cp ~/.s3cfg ${BUILD_HOME}/.s3cfg.digitalocean
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/digitalocean
    done
fi

if ( [ "${datastore_provider}" = "exoscale" ] )
then
    if ( [ ! -f /usr/bin/s3cmd ] )
    then
        ${BUILD_HOME}/providerscripts/datastore/InstallDatastoreTools.sh 'S3CMD' ${buildos}
    fi

    if ( [ -f ${BUILD_HOME}/.s3cfg.exoscale ] )
    then
        status "I have found a configuration for an exoscale datastore. Do you want me to display it to you? (Y|N)"
        read response
        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
        then
            status "==================================================================================================================="
            status "`/bin/cat ${BUILD_HOME}/.s3cfg.exoscale`"
            status "==================================================================================================================="
        fi

        status "So, is the existing configuration acceptable to you? If you know it is or can see that it is, then enter Y else enter N to reconfigure it"
        read response
        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
        then
            status "OK, using existing configuration, press <enter> to continue"
            /bin/cp ${BUILD_HOME}/.s3cfg.exoscale ~/.s3cfg
            read x
        else
            /bin/rm ${BUILD_HOME}/.s3cfg.exoscale
        fi
    fi

    while ( [ ! -f ${BUILD_HOME}/.s3cfg.exoscale ] )
    do
        status "Please tell us the endpoint for your exoscale object store (for example, sos-ch-dk-2.exo.io)"
        read EXOSCALE_ENDPOINT

        status "You need to configure your datastore tools. You can get your access keys by going to your exoscale account and going to object storage"
        status "Once you have your keys, please use them in the following configuration"

        status "====================================================================================================================================="
        status "Oddly, we have to run the configuration tool twice for technical reasons. Each time it runs, the procedure is a little different"
        status "The first time it runs,  follow these steps"
        status "   1) Enter your access keys as you obtained them from exoscale"
        status "   2) Just press enter key for all subsequent options until it says, 'test connection' it will fail but that's OK and expected"
        status "   3) When it asks if you want to save your configuration, say yes"
        status "   4) Don't re run the configuration process, it will rerun itself"
        status "The second time it runs, press enter to all the options and then say 'yes' to test the configuration and select yes to save configuration"
        status "====================================================================================================================================="
        status "Press the enter key to begin the configuration"
        status ""
        read x
        /usr/bin/s3cmd --configure >&3
        /bin/sed -i "s/^host_base.*/host_base = ${EXOSCALE_ENDPOINT}/" ~/.s3cfg
        /bin/sed -i "s/^host_bucket.*/host_bucket = %(bucket)s.${EXOSCALE_ENDPOINT}/" ~/.s3cfg
        status "=================================================================================================================================="
        status "FOR THIS PROVIDER IT IS NECESSARY TO RECONFIRM ALL THE DETAILS YOU HAVE SET. PLEASE JUST REPEATEDLY PRESS <ENTER> TO ACCEPT AS SET"
        status "=================================================================================================================================="
        /usr/bin/s3cmd --configure >&3
        /bin/cp ~/.s3cfg ${BUILD_HOME}/.s3cfg.exoscale
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/exoscale
    done
fi

if ( [ "${datastore_provider}" = "linode" ] )
then
    if ( [ ! -f /usr/bin/s3cmd ] )
    then
        ${BUILD_HOME}/providerscripts/datastore/InstallDatastoreTools.sh 'S3CMD' ${buildos}
    fi

    if ( [ -f ${BUILD_HOME}/.s3cfg.linode ] )
    then
        status "I have found a configuration for an linode datastore. Do you want me to display it to you? (Y|N)"
        read response
        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
        then
            status "==================================================================================================================="
            status "`/bin/cat ${BUILD_HOME}/.s3cfg.linode`"
            status "==================================================================================================================="
        fi

        status "So, is the existing configuration acceptable to you? If you know it is or can see that it is, then enter Y else enter N to reconfigure it"
        read response
        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
        then
            status "OK, using existing configuration, press <enter> to continue"
            /bin/cp ${BUILD_HOME}/.s3cfg.linode ~/.s3cfg
            read x
        else
            /bin/rm ${BUILD_HOME}/.s3cfg.linode
        fi
    fi

    while ( [ ! -f ${BUILD_HOME}/.s3cfg.linode ] )
    do
        status "Please tell us the endpoint for your exoscale object store (for example, us-east-1.linodeobjects.com)"
        read LINODE_ENDPOINT

        status "You need to configure your datastore tools. You can get your access keys by going to your exoscale account and going to object storage"
        status "Once you have your keys, please use them in the following configuration"

        status "====================================================================================================================================="
        status "Oddly, we have to run the configuration tool twice for technical reasons. Each time it runs, the procedure is a little different"
        status "The first time it runs,  follow these steps"
        status "   1) Enter your access keys as you obtained them from exoscale"
        status "   2) Just press enter key for all subsequent options until it says, 'test connection' it will fail but that's OK and expected"
        status "   3) When it asks if you want to save your configuration, say yes"
        status "   4) Don't re run the configuration process, it will rerun itself"
        status "The second time it runs, press enter to all the options and then say 'yes' to test the configuration and select yes to save configuration"
        status "====================================================================================================================================="
        status "Press the enter key to begin the configuration"
        status ""
        read x
        /usr/bin/s3cmd --configure >&3
        /bin/sed -i "s/^host_base.*/host_base = ${LINODE_ENDPOINT}/" ~/.s3cfg
        /bin/sed -i "s/^host_bucket.*/host_bucket = %(bucket)s.${LINODE_ENDPOINT}/" ~/.s3cfg
        status "=================================================================================================================================="
        status "FOR THIS PROVIDER IT IS NECESSARY TO RECONFIRM ALL THE DETAILS YOU HAVE SET. PLEASE JUST REPEATEDLY PRESS <ENTER> TO ACCEPT AS SET"
        status "=================================================================================================================================="
        /usr/bin/s3cmd --configure >&3
        /bin/cp ~/.s3cfg ${BUILD_HOME}/.s3cfg.linode
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/linode
    done
fi

if ( [ "${datastore_provider}" = "vultr" ] )
then
    if ( [ ! -f /usr/bin/s3cmd ] )
    then
        ${BUILD_HOME}/providerscripts/datastore/InstallDatastoreTools.sh 'S3CMD' ${buildos}
    fi

    if ( [ -f ${BUILD_HOME}/.s3cfg.vultr ] )
    then
        status "I have found a configuration for an vultr datastore. Do you want me to display it to you? (Y|N)"
        read response
        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
        then
            status "==================================================================================================================="
            status "`/bin/cat ${BUILD_HOME}/.s3cfg.vultr`"
            status "==================================================================================================================="
        fi

        status "So, is the existing configuration acceptable to you? If you know it is or can see that it is, then enter Y else enter N to reconfigure it"
        read response
        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
        then
            status "OK, using existing configuration, press <enter> to continue"
            /bin/cp ${BUILD_HOME}/.s3cfg.vultr ~/.s3cfg
            read x
        else
            /bin/rm ${BUILD_HOME}/.s3cfg.vultr
        fi
    fi

    while ( [ ! -f ${BUILD_HOME}/.s3cfg.vultr ] )
    do
        status "Please tell us the endpoint for your vultr object store"
        read VULTR_ENDPOINT

        status "You need to configure your datastore tools. You can get your access keys by going to your vultr account and going to object storage"
        status "Once you have your keys, please use them in the following configuration"

        status "====================================================================================================================================="
        status "Oddly, we have to run the configuration tool twice for technical reasons. Each time it runs, the procedure is a little different"
        status "The first time it runs,  follow these steps"
        status "   1) Enter your access keys as you obtained them from vultr"
        status "   2) Just press enter key for all subsequent options until it says, 'test connection' it will fail but that's OK and expected"
        status "   3) When it asks if you want to save your configuration, say yes"
        status "   4) Don't re run the configuration process, it will rerun itself"
        status "The second time it runs, press enter to all the options and then say 'yes' to test the configuration and select yes to save configuration"
        status "====================================================================================================================================="
        status "Press the enter key to begin the configuration"
        status ""
        read x
        /usr/bin/s3cmd --configure >&3
        /bin/sed -i "s/^host_base.*/host_base = ${VULTR_ENDPOINT}/" ~/.s3cfg
        /bin/sed -i "s/^host_bucket.*/host_bucket = %(bucket)s.${VULTR_ENDPOINT}/" ~/.s3cfg
        status "=================================================================================================================================="
        status "FOR THIS PROVIDER IT IS NECESSARY TO RECONFIRM ALL THE DETAILS YOU HAVE SET. PLEASE JUST REPEATEDLY PRESS <ENTER> TO ACCEPT AS SET"
        status "=================================================================================================================================="
        /usr/bin/s3cmd --configure >&3
        /bin/cp ~/.s3cfg ${BUILD_HOME}/.s3cfg.vultr
        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/vultr
    done
fi


