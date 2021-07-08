#!/bin/bash
###########################################################################################################################
# These values override the default values set in the 1st template provided with the ADT repository:
# Template: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templates/linode/linode1.tmpl
# Description: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templates/linode/linode1.description
#All of these variables need to be set correctly for the build to work. You will need to obtain these values from linode and cloudflare:
#S3_ACCESS_KEY - "Your linode object storage key"
#S3_SECRET_KEY - "Your linode object storage secret key"
#TOKEN - "Your linode personal access token"
#DNS_USERNAME - "Your cloudflare email address"
#DNS_SECURITY_KEY - "Your cloudflare global API key"
#The rest you can generate or set locally yourself, but, all these variables must be set correctly before you add this script to the user data of your linode
####################################################################################################################################################################
#****ESSENTIAL****: (sometimes) there is a caching problem when drupal is installed and so you will sometimes see an error message when you first try to access 
# the live site. Therefore when running this script, you must tail the build output log...
#
#    tail -f /root/agile-infrastructure-build-client-scripts/logs/build*out*
#
#and follow the instructions at the end of it to clear the cache AFTER you have installed drupal through the gui system. 
#The caching problem is internmittent, so you may not see it, but, in most tests I have done it is there. The process you are asked to perform at the end of the build 
#process will truncate the caching tables in the database and clear the error message. 
####################################################################################################################################################################
# <UDF name="SSH" label="SSH Public Key" />
# <UDF name="BUILDOS" label="Operating system to deploy to" oneof="ubuntu,debian" default="debian"/>
# <UDF name="BUILDOS_VERSION" label="Operating system to deploy to" oneof="20.04,10" default="10"/>
# <UDF name="CLOUDHOST" label="Who we are deploying with (always linode for a stack script)" oneof="linode" default="linode"/>
# <UDF name="REGION_ID" label="The region for your linodes" oneof="ap-west,ap-central,ap-southeast,us-central,us-west,us-east,eu-west,ap-south,eu-central,ap-northeast" default="eu-west"/>
# <UDF name="BUILD_IDENTIFIER" label="The unique name to identify this build with, for example, myblogproject if your website is www.myblog.org.uk" />
# <UDF name="APPLICATION_BASELINE_SOURCECODE_REPOSITORY" label="Application Version, for example, 'DRUPAL:9.0.7'" />
# <UDF name="DRUPAL_VERSION" label="Drupal Version, for example, '9.1.2'" />
# <UDF name="TOKEN" label="Your linode personal access token (must have account,images, object storage, linodes, ips,stackscript" />
# <UDF name="S3_ACCESS_KEY" label="Your linode object storage access key" />
# <UDF name="S3_SECRET_KEY" label="Your linode object storage secret key" />
# <UDF name="S3_HOST_BASE" label="Your linode object storage host base" oneof="us-east-1.linodeobjects.com,eu-central-1.linodeobjects.com,ap-south-1.linodeobjects.com" default="eu-central-1.linodeobjects.com"/>
# <UDF name="S3_LOCATION" label="Your object storage host base" oneof="US" default="US"/>
# <UDF name="DNS_USERNAME" label="Your Cloudflare email address" />
# <UDF name="DNS_SECURITY_KEY" label="Your Global API key for your Cloudflare account" />
# <UDF name="DNS_CHOICE" label="Your DNS provider (always Cloudflare for this stack script)" oneof="cloudflare" default="cloudflare"  />
# <UDF name="WEBSITE_DISPLAY_NAME" label="The display name for your Website, for example, 'My Holiday Blog'" />
# <UDF name="WEBSITE_NAME" label="The core of your DNS domain name, if your URL=www.nuocial.org.uk, enter 'nuocial' here" />
# <UDF name="WEBSITE_URL" label="The Cloudflare registered URL of your website, for example, www.nuocial.org.uk" />
# <UDF name="SELECTED_TEMPLATE" label="The ADT template number to build from" oneof="4"/ default="4">
# <UDF name="PHP_VERSION" label="Which PHP Version do you want to deploy to?" oneof="7.0,7.1,7.2,7.3,7.4,8.0" default="7.4"/>
#######################################################################################################
###############################################################################################
# SET THESE FOR YOUR BUILD CLIENT MACHINE
# THESE WILL BE THE USERNAME THE PASSWORD YOU CAN USE TO DO A SUDO ONCE AUTHENTICATED AND THE SSH PORT TO CONNECT ON
# CONNECT TO YOUR BUILD CLIENT MACHINE AS FOLLOWS:
# ssh -i <ssh-private-key> -p ${BUILDCLIENT_SSH_PORT} $BUILDCLIENT_USER@<buildclientip>
# $BUILDCLIENT_USER>sudo su
# password:${BUILDCLIENT_PASSWORD}
# cd agile-infrastructure-build-client-scripts/logs
# tail -f build*out*
####################################################################################
export BUILDCLIENT_USER="agile-deployer"
export BUILDCLIENT_PASSWORD="mnbcxz098321QQZZ"
export BUILDCLIENT_SSH_PORT="1035"

/usr/sbin/adduser --disabled-password --gecos \"\" ${BUILDCLIENT_USER} 
/bin/sed -i '$ a\ ClientAliveInterval 60\nTCPKeepAlive yes\nClientAliveCountMax 10000' /etc/ssh/sshd_config
/bin/sed -i 's/.*PermitRootLogin.*$/PermitRootLogin no/g' /etc/ssh/sshd_config
/bin/echo ${BUILDCLIENT_USER}:${BUILDCLIENT_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/chpasswd 
 /usr/bin/gpasswd -a ${BUILDCLIENT_USER} sudo 

/bin/mkdir -p /home/${BUILDCLIENT_USER}/.ssh
/bin/echo "${SSH}" >> /home/${BUILDCLIENT_USER}/.ssh/authorized_keys

/bin/sed -i 's/#*PasswordAuthentication [a-zA-Z]*/PasswordAuthentication no/' /etc/ssh/sshd_config

if ( [ "${BUILDCLIENT_SSH_PORT}" = "" ] )
then
    BUILDCLIENT_SSH_PORT="22"
fi

/bin/sed -i "s/^Port.*$/Port ${BUILDCLIENT_SSH_PORT}/g" /etc/ssh/sshd_config
/bin/sed -i "s/^#Port.*$/Port ${BUILDCLIENT_SSH_PORT}/g" /etc/ssh/sshd_config

systemctl restart sshd
service ssh restart

/usr/bin/apt -qq -y update
/usr/bin/apt -qq -y install git
/usr/bin/apt -qq -y install ufw

/usr/sbin/ufw enable
/usr/sbin/ufw default deny incoming
/usr/sbin/ufw default allow outgoing
####################################################################################################################################################
#It is possible to lock down ssh connections to only from a specific ip address which is more secure, but, if the IP address of your machine changes,
#for example, if you connect your laptop to a different network, then, you will have to connect to the build client machine through the console of
#your VPS system provider and allow your new IP address through the firewall. This might be more of a hassle than its worth
#####################################################################################################################################################
/usr/sbin/ufw allow ${BUILDCLIENT_SSH_PORT}/tcp 

cd /home/${BUILDCLIENT_USER}

if ( [ "${INFRASTRUCTURE_REPOSITORY_OWNER}" != "" ] )
then
    /usr/bin/git clone https://github.com/${INFRASTRUCTURE_REPOSITORY_OWNER}/agile-infrastructure-build-client-scripts.git
else
    /usr/bin/git clone https://github.com/agile-deployer/agile-infrastructure-build-client-scripts.git
fi

cd agile-infrastructure-build-client-scripts

/bin/sh HardcoreADTWrapper.sh
