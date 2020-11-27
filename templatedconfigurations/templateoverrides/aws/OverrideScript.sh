#!/bin/bash

###################################################################################################################################################################
#To use this file, review every variable and set it appropriately, then copy it to your userdata area when you create your build EC2 Instance
#you can refer to the specification for the ADT templating system to review this parameters which is located at: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md
#To make your build possible fill in all these environment variables and paste this entire (updated) file into the userdata are of your build client machine. 
####################################################################################################################################################################
/bin/echo "
export SSH="" #paste your public key here
export BUILDOS="debian" #one of ubuntu|debian
export BUILDOS_VERSION="10" #one of 20.04|10
export DEFAULT_USER="debian" # - this should be "ubuntu" if you are deploying ubuntu and "admin" if you are deploying debian
export CLOUDHOST="exoscale"  #Always exoscale
export REGION_ID=""  #The region ID for your deployment - for region 
export BUILD_IDENTIFIER="" #Unique string to identify your build
export DNS_USERNAME=""  #Your DNS provider username (for cloudflare it is the email address for your account)
export DNS_SECURITY_KEY=""  #Your DNS API key, for example, Global API key from cloudflare
export DNS_CHOICE="cloudflare" #Your DNS provider
export WEBSITE_DISPLAY_NAME="" #Display name for example "My Blogging Website"
export WEBSITE_NAME=""  #The core of WEBSITE_URL, for example, if WEBSITE_URL=ok.nuocial.org.uk, WEBSITE_NAME="nuocial"
export WEBSITE_URL=""  #the URL of the website registered with your DNS provider
export SELECTED_TEMPLATE="" #Select a template number (1-10) to build you can review available template descriptions to decide which you want to deploy here: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/tree/master/templatedconfigurations/templates/digitalocean 
export SYSTEM_EMAIL_USERNAME="" #optional - the SMTP username for your SMTP provider
export SYSTEM_EMAIL_PASSWORD="" #optional - the SMTP password for your SMTP provider
export SYSTEM_EMAIL_PROVIDER="" #optional - a value between 1 and 3 for your SMTP provider 1:Sendpulse 2:Gmail 3:SES
export SYSTEM_TOEMAIL_ADDRESS="" #optional - email adddress to send system emails from
export SYSTEM_FROMEMAIL_ADDRESS="" #optional - email address to send system emails to
export S3_ACCESS_KEY="" #IAM AWS S3 Access Key
export S3_SECRET_KEY="" #IAM AWS S3 Secret Key
export S3_HOST_BASE=""  #Host base for your exoscale object storage  one of: sos-ch-gva-2.exo.io, sos-ch-dk-2.exo.io, sos-de-fra-1.exo.io, sos-de-muc-1.exo.io, sos-at-vie-1.exo.io, sos-bg-sof-1
export S3_LOCATION="US" #Always set to US for exoscale
export ACCESS_KEY=""   #IAM compute access key for your AWS account
export SECRET_KEY=""   #IAM compute secret key for your AWS account
export NO_AUTOSCALERS="" #Number of autoscalers (1-5)
#The values above are the values that I override by default. If, for example, you wanted to override the size of your webserver machines you could 
#simply add an export statement beneath the additional overrides section below 
# and define it for your provider based on the template specification. Similarly for any of the other variables that you find in 
#the template. You need to be aware of how the variables play with each other, which needs to be set with which, for example. Running the 
#full AgileDeploymentToolkit script and setting the configuration you desire will give you an env dump upon successful completion in the 
#${BUILD_HOME}/buildcompletion directory which will show you which variables need to be set for the particular configuration you desire. 
####ADDITIONAL OVERRIDES
#export WS_SIZE=""
" > /root/Environment.env

. /root/Environment.env

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
