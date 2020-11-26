#!/bin/bash

#you can refer to the specification for the ADT templating system to review this parameters which is located at:

/bin/echo "
export SSH="" #paste your public key here
export BUILDOS="debian" #one of ubuntu|debian
export BUILDOS_VERSION="10" #one of 20.04|10
export CLOUDHOST="digitalocean"  #Always digitalocean
export REGION_ID=""  #The region ID for your deployment
export BUILD_IDENTIFIER="" #Unique string to identify your build
export DNS_USERNAME=""  #Your DNS provider username (for cloudflare it is the email address for your account)
export DNS_SECURITY_KEY=""  #Your DNS API key, for example, Global API key from cloudflare
export DNS_CHOICE="cloudflare" #Your DNS provider
export WEBSITE_DISPLAY_NAME="" #Display name for example "My Blogging Website"
export WEBSITE_NAME=""  #The core of WEBSITE_URL, for example, if WEBSITE_URL=ok.nuocial.org.uk, WEBSITE_NAME="nuocial"
export WEBSITE_URL=""  #the URL of the website registered with your DNS provider
export SELECTED_TEMPLATE="" #Select a template number to build
export SYSTEM_EMAIL_USERNAME="" #optional
export SYSTEM_EMAIL_PASSWORD="" #optional
export SYSTEM_EMAIL_PROVIDER="" #optional
export SYSTEM_TOEMAIL_ADDRESS="" #optional
export SYSTEM_FROMEMAIL_ADDRESS="" #optional
export S3_ACCESS_KEY="" #Digital Ocean Spaces Access Key
export S3_SECRET_KEY="" #Digital Ocean Spaces Secret Key
export S3_HOST_BASE=""  #Host base for your digital ocean spaces
export S3_LOCATION="US" #Always set to US for digitalocean
export TOKEN="" #Your personal acccess token
export NO_AUTOSCALERS="" #Number of autoscalers

#The values above are the values that I override by default. If, for example, you wanted to override the size of your webserver machines you could 
#simply add an export statement beneath the additional overrides section below 
# and define it for your provider based on the template specification. Similarly for any of the other variables that you find in 
#the template. You need to be aware of how the variables play with each other, which needs to be set with which, for example. Running the 
#full AgileDeploymentToolkit script and setting the configuration you desire will give you an env dump upon successful completion in the 
#${BUILD_HOME}/buildcompletion directory which will show you which variables need to be set for the particular configuration you desire. 
####ADDITIONAL OVERRIDES
export WS_SIZE=""
" > /root/Environment.env

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
