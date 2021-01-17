#!/bin/bash
###########################################################################################################################
# These values override the default values set in the 1st template provided with the ADT repository:
# Template: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templates/linode/linode1.tmpl
# Description: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templates/linode/linode1.description
#All of these variables need to be set correctly for the build to work. You will need to obtain these values from digital ocean and cloudflare:
#S3_ACCESS_KEY - "Your linode object storage key"
#S3_SECRET_KEY - "Your linode object storage secret key"
#TOKEN - "Your linode personal access token"
#DNS_USERNAME - "Your cloudflare email address"
#DNS_SECURITY_KEY - "Your cloudflare global API key"
#The rest you can generate or set locally yourself, but, all these variables must be set correctly before you add this script to the user data of your droplet
####################################################################################################################################################################
#****ESSENTIAL****: (sometimes) there is a caching problem when drupal is installed and so you will sometimes see an error message when you first try to access 
# the live site. Therefore when running this script, you must tail the build output log...
#
#    tail -f /root/agile-deployment-toolkit/logs/build*out*
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
# <UDF name="DRUPAL_VERSION" label="Drupal Version, for example, '9.0.7'" />
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
# <UDF name="NO_AUTOSCALERS" label="The number of autoscalers (if applicable)" oneof="1,2,3,4,5" default="1"/>
#######################################################################################################
#This is the main script. Ensure the SSH key is authorised in case it hasn't been set yet. Also disable password based authentication
/bin/mkdir ~/.ssh
/bin/echo "${SSH}" >> ~/.ssh/authorized_keys
/bin/sed -i 's/#*PasswordAuthentication [a-zA-Z]*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
service ssh restart
#Install the git software
/usr/bin/apt -qq -y install git
cd /root
#Clone the Agile Deployment Toolkit
/usr/bin/git clone https://github.com/agile-deployer/agile-infrastructure-build-client-scripts.git
cd agile-infrastructure-build-client-scripts
#Start the build properly by calling the wrapper script. The user should then monitor the build on their new linode by tailing the logs in the logs directory
/bin/sh HardcoreADTWrapper.sh
