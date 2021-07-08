#!/bin/bash

###################################################################################################################################################################
#To use this file, review every variable and set it appropriately, then copy it to your userdata area when you create your build client machine
#you can refer to the specification for the ADT templating system to review this parameters which is located at: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md
#To make your build possible fill in all these environment variables and paste this entire (updated) file into the userdata are of your build client machine. 
#All of these variables need to be set correctly for the build to work. You will need to obtain these values from exoscale and cloudflare:
#S3_ACCESS_KEY - "Your exoscale object storage  access key"
#S3_SECRET_KEY - "Your exoscale object storage secret key"
#ACCESS_KEY - "Your exoscale compute storage access key"
#SECRET_KEY - "Your exoscale compute  secret key"
#DNS_USERNAME - "Your cloudflare email address"
#DNS_SECURITY_KEY - "Your cloudflare global API key"
#The rest you can generate or set locally yourself, but, all these variables must be set correctly before you add this script to the user data of your compute instance
####################################################################################################################################################################/bin/echo "
#BASE OVERRIDES
export SSH=\"\" #paste your public key here
export BUILDOS=\"debian\" #one of ubuntu|debian
export BUILDOS_VERSION=\"10\" #one of 20.04|10
export DEFAULT_USER=\"debian\" # - this should be "ubuntu" if you are deploying ubuntu and "debian" if you are deploying debian
export CLOUDHOST=\"exoscale\"  #Always exoscale
export REGION_ID=\"\"  #The region ID for your deployment - for region ch-gva-2 regionid = "1128bd56-b4d9-4ac6-a7b9-c715b187ce11", for region ch-dk-2 regionid = "91e5e9e4-c9ed-4b76-bee4-427004b3baf9", for region at-vie-1 regionid = "4da1b188-dcd6-4ff5-b7fd-bde984055548", for region de-fra-1 regionid = "35eb7739-d19e-45f7-a581-4687c54d6d02", for region bg-sof-1 regionid = "70e5f8b1-0b2c-4457-a5e0-88bcf1f3db68", for region de-muc-1 regionid = "85664334-0fd5-47bd-94a1-b4f40b1d2eb7"
export BUILD_IDENTIFIER=\"\" #Unique string to identify your build
export ACCESS_KEY=\"\"   #IAM compute access key for your exoscale account
export SECRET_KEY=\"\"   #IAM compute secret key for your exoscale account
export S3_ACCESS_KEY=\"\" #IAM Exoscale Object Storage SOS Access Key
export S3_SECRET_KEY=\"\" #IAM Exoscale Object Storage SOS Secret Key
export S3_HOST_BASE=\"\"  #Host base for your exoscale object storage  one of: sos-ch-gva-2.exo.io, sos-ch-dk-2.exo.io, sos-de-fra-1.exo.io, sos-de-muc-1.exo.io, sos-at-vie-1.exo.io, sos-bg-sof-1
export S3_LOCATION=\"US\" #Always set to US for exoscale
export DNS_USERNAME=\"\"  #Your DNS provider username (for cloudflare it is the email address for your account)
export DNS_SECURITY_KEY=\"\"  #Your DNS API key, for example, Global API key from cloudflare
export DNS_CHOICE=\"cloudflare\" #Your DNS provider
export WEBSITE_DISPLAY_NAME=\"\" #Display name for example "My Blogging Website"
export WEBSITE_NAME=\"\"  #The core of WEBSITE_URL, for example, if WEBSITE_URL=ok.nuocial.org.uk, WEBSITE_NAME="nuocial"
export WEBSITE_URL=\"\"  #the URL of the website registered with your DNS provider
export SELECTED_TEMPLATE=\"5\" #Select a template number (1-10) to build you can review available template descriptions to decide which you want to deploy here: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/tree/master/templatedconfigurations/templates/digitalocean/templatemenu.md 
#The values above are the values that I override by default. If, for example, you wanted to override the size of your webserver machines you could 
#simply add an export statement beneath the additional overrides section below 
# and define it for your provider based on the template specification. Similarly for any of the other variables that you find in 
#the template. You need to be aware of how the variables play with each other, which needs to be set with which, for example. Running the 
#full AgileDeploymentToolkit script and setting the configuration you desire will give you an env dump upon successful completion in the 
#${BUILD_HOME}/buildcompletion directory which will show you which variables need to be set for the particular configuration you desire. 
####ADDITIONAL OVERRIDES
#export WS_SIZE=\"\"
" > /root/Environment.env

. /root/Environment.env

/bin/mkdir ~/.ssh
/bin/echo "${SSH}" >> ~/.ssh/authorized_keys

/bin/sed -i 's/#*PasswordAuthentication [a-zA-Z]*/PasswordAuthentication no/' /etc/ssh/sshd_config
/bin/sed -i 's/^*PasswordAuthentication [a-zA-Z]*/PasswordAuthentication no/' /etc/ssh/sshd_config

systemctl restart sshd
service ssh restart

/usr/bin/apt -qq -y update
/usr/bin/apt -qq -y install git

cd /root

/usr/bin/git clone https://github.com/agile-deployer/agile-infrastructure-build-client-scripts.git

cd agile-infrastructure-build-client-scripts

/bin/sh HardcoreADTWrapper.sh
