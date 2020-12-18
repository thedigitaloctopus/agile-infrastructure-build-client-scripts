#!/bin/bash

###################################################################################################################################################################
#To use this file, review every variable and set it appropriately, then copy it to your userdata area when you create your build EC2 Instance
#you can refer to the specification for the ADT templating system to review this parameters which is located at: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md
#To make your build possible fill in all these environment variables and paste this entire (updated) file into the userdata are of your build client machine. 
####################################################################################################################################################################
/bin/echo "
#BASE OVERRIDES
export SSH=\"\" #paste your public key here
export BUILDOS=\"debian\" #one of ubuntu|debian
export BUILDOS_VERSION=\"10\" #one of 20.04|10
export DEFAULT_USER=\"admin\" # - this should be "ubuntu" if you are deploying BUILDOS ubuntu and "admin" if you are deploying BUILDOS debian
export CLOUDHOST=\"aws\"  #Always exoscale
export REGION_ID=\"\"  #The region ID for your deployment - for region one of: eu-north-1, ap-south-1, eu-west-3, eu-west-2, eu-west-1, ap-northeast-2, ap-northeast-1, sa-east-1, ca-central-1, ap-southeast-1, ap-southeast-2, eu-central-1, us-east-1, us-east-2, us-west-1, us-west-2
export BUILD_IDENTIFIER=\"\" #Unique string to identify your build
export ACCESS_KEY=\"\"   #IAM compute access key for your AWS account
export SECRET_KEY=\"\"   #IAM compute secret key for your AWS account
export S3_ACCESS_KEY=\"\" #IAM AWS S3 Access Key
export S3_SECRET_KEY=\"\" #IAM AWS S3 Secret Key
export S3_HOST_BASE=\"\"  #Host base for your exoscale object storage, for example (see regions above), "s3.eu-west-1.amazonaws.com"
export S3_LOCATION=\"EU\" #US or EU or AP
export DNS_USERNAME=\"\"  #Your DNS provider username (for cloudflare it is the email address for your account)
export DNS_SECURITY_KEY=\"\"  #Your DNS API key, for example, Global API key from cloudflare
export DNS_CHOICE=\"cloudflare\" #Your DNS provider
export WEBSITE_DISPLAY_NAME=\"\" #Display name for example "My Blogging Website"
export WEBSITE_NAME=\"\"  #The core of WEBSITE_URL, for example, if WEBSITE_URL=ok.nuocial.org.uk, WEBSITE_NAME="nuocial"
export WEBSITE_URL=\"\"  #the URL of the website registered with your DNS provider
export SELECTED_TEMPLATE=\"3\" #Select a template number (1-10) to build you can review available template descriptions to decide which you want to deploy here: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/tree/master/templatedconfigurations/templates/digitalocean/templatemenu.md 
export NO_AUTOSCALERS=\"1\" #Number of autoscalers (1-5)
export SUBNET_ID=\"\" # The subnet id for your EC2 instances
export OSTYPE=\"\" # ami identifier for your build os type. If BUILDOS ubuntu, look here: https://cloud-images.ubuntu.com/locator/ec2/ for BUILDOS debian run this command: /usr/bin/aws ec2 describe-images --owners 379101102735 | /usr/bin/jq '.Images[] | .ImageId + " " + .Name' | /bin/grep stretch | /bin/grep "2019\|2020\|2021\|2022\|2023" | /bin/grep x86_64 | /bin/sed 's/\"//g'
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

systemctl restart sshd
service ssh restart

/usr/bin/apt -qq -y install git

cd /root

/usr/bin/git clone https://github.com/agile-deployer/agile-infrastructure-build-client-scripts.git

cd agile-infrastructure-build-client-scripts

/bin/sh HardcoreADTWrapper.sh
