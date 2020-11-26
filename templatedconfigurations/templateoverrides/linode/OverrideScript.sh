#!/bin/bash

#######################################################################################################################################################
# Linode uses Stack Scripts. You can take this script and create a stack script out of it from which to start your build client linode. You are free to add additional
# overrides to this script, for example, if you wanted to add a UDF value to configure the size of your webserver machines you could add a UDF term for 
# WS_SIZE which you would then be able to configure. Please refer to the template specification at:
# https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md 
# I have included a bare minimum of variables to override to keep the default script as simple as possible.
########################################################################################################################################################

# <UDF name="SSH" label="SSH Public Key" />
# <UDF name="BUILDOS" label="Operating system to deploy to" oneof="ubuntu,debian" default="debian"/>
# <UDF name="BUILDOS_VERSION" label="Operating system to deploy to" oneof="20.04,10" default="10"/>
# <UDF name="CLOUDHOST" label="Who we are deploying with (always linode for a stack script)" oneof="linode" default="linode"/>
# <UDF name="REGION_ID" label="The region for your linodes" oneof="ap-west,ap-central,ap-southeast,us-central,us-west,us-east,eu-west,ap-south,eu-central,ap-northeast" default="eu-west"/>
# <UDF name="BUILD_IDENTIFIER" label="The unique name to identify this build with, for example, myblogproject if your website is www.myblog.org.uk" />
# <UDF name="DNS_USERNAME" label="Your Cloudflare email address" />
# <UDF name="DNS_SECURITY_KEY" label="Your Global API key for your Cloudflare account" />
# <UDF name="DNS_CHOICE" label="Your DNS provider (always Cloudflare for this stack script)" oneof="cloudflare" default="cloudflare"  />
# <UDF name="WEBSITE_DISPLAY_NAME" label="The display name for your Website, for example, 'My Holiday Blog'" />
# <UDF name="WEBSITE_NAME" label="The core of your cloudflare registered URL (see item below), for example, if your URL=www.nuocial.org.uk, enter 'nuocial' here" />
# <UDF name="WEBSITE_URL" label="The cloudflare registered URL of your website, for example, www.nuocial.org.uk" />
# <UDF name="SELECTED_TEMPLATE" label="The ADT template number to build from" oneof="1,2,3,4,5,6,7,8,"/>
# <UDF name="SYSTEM_EMAIL_USERNAME" label="The username of your system SMTP user" default=""/>
# <UDF name="SYSTEM_EMAIL_PASSWORD" label="The password of your system SMTP user" default=""/>
# <UDF name="SYSTEM_EMAIL_PROVIDER" label="The provider of your system SMTP service 1:sendpulse 2:gmail 3:SES" oneof="1,2,3" default=""/>
# <UDF name="SYSTEM_TOEMAIL_ADDRESS" label="The email address for your system emails to be sent to" default=""/>
# <UDF name="SYSTEM_FROMEMAIL_ADDRESS" label="The email address for your system emails to be sent from" default=""/>
# <UDF name="S3_ACCESS_KEY" label="Your object storage access key" />
# <UDF name="S3_SECRET_KEY" label="Your object storage secret key" />
# <UDF name="S3_HOST_BASE" label="Your object storage host base" oneof="us-east-1.linodeobjects.com,eu-central-1.linodeobjects.com,ap-south-1.linodeobjects.com" default="eu-central-1.linodeobjects.com"/>
# <UDF name="S3_LOCATION" label="Your object storage host base" oneof="US" default="US"/>
# <UDF name="TOKEN" label="Your linode personal access token (must have account,images, object storage, linodes, ips,stackscript" />
# <UDF name="NO_AUTOSCALERS" label="The number of autoscalers (if applicable)" oneof="1,2,3,4,5" default="1"/>

/bin/mkdir ~/.ssh
/bin/echo "${SSH}" >> ~/.ssh/authorized_keys

/bin/sed -i 's/#*PasswordAuthentication [a-zA-Z]*/PasswordAuthentication no/' /etc/ssh/sshd_config

systemctl restart sshd
service ssh restart

/usr/bin/apt -qq -y install git

cd /root

/usr/bin/git clone https://github.com/agile-deployer/agile-infrastructure-build-client-scripts.git

cd agile-infrastructure-build-client-scripts

/bin/sh HardcoreADTWrapper.sh
