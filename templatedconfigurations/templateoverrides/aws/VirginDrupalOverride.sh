#!/bin/bash

###################################################################################################################################################################
#To use this file, review every variable and set it appropriately, then copy it to your userdata area when you create your build EC2 Instance
#you can refer to the specification for the ADT templating system to review this parameters which is located at: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md
#To make your build possible fill in all these environment variables and paste this entire (updated) file into the userdata are of your build client machine. 
#All of these variables need to be set correctly for the build to work. You will need to obtain these values from AWS and cloudflare:
#S3_ACCESS_KEY - "Your AWS object storage key"
#S3_SECRET_KEY - "Your AWS object storage secret key"
#ACCESS_KEY - "Your AWS compute access key"
#SECRET_KEY - "You AWS compute secret key"
#DNS_USERNAME - "Your cloudflare email address"
#DNS_SECURITY_KEY - "Your cloudflare global API key"
#The rest you can generate or set locally yourself, but, all these variables must be set correctly before you add this script to the user data of your compute instance
####################################################################################################################################################################
#****ESSENTIAL****: (sometimes) there is a caching problem when drupal is installed and so you will sometimes see an error message when you first try to access 
# the live site. Therefore when running this script, you must tail the build output log...
#
#    tail -f /root/agile-infrastructure-build-client-scripts/logs/build*out*
#
#and follow the instructions at the end of it to clear the cache AFTER you have installed drupal through the gui system. 
#The caching problem is internmittent, so you may not see it, but, in most tests I have done it is there. The process you are asked to perform at the end of the build 
#process will truncate the caching tables in the database and clear the error message. 
####################################################################################################################################################################/bin/echo "
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
export SELECTED_TEMPLATE=\"4\" #Select a template number (1-10) to build you can review available template descriptions to decide which you want to deploy here: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/tree/master/templatedconfigurations/templates/digitalocean/templatemenu.md 
export SUBNET_ID=\"\" # The subnet id for your EC2 instances
export OS_TYPE=\"\" # ami identifier for your build os type. If BUILDOS ubuntu, look here: https://cloud-images.ubuntu.com/locator/ec2/ for BUILDOS debian run this command: /usr/bin/aws ec2 describe-images --owners 379101102735 | /usr/bin/jq '.Images[] | .ImageId + " " + .Name' | /bin/grep buster | /bin/grep "2019\|2020\|2021\|2022\|2023" | /bin/grep x86_64 | /bin/sed 's/\"//g'
#The values above are the values that I override by default. If, for example, you wanted to override the size of your webserver machines you could 
#simply add an export statement beneath the additional overrides section below 
# and define it for your provider based on the template specification. Similarly for any of the other variables that you find in 
#the template. You need to be aware of how the variables play with each other, which needs to be set with which, for example. Running the 
#full AgileDeploymentToolkit script and setting the configuration you desire will give you an env dump upon successful completion in the 
#${BUILD_HOME}/buildcompletion directory which will show you which variables need to be set for the particular configuration you desire. 
####ADDITIONAL OVERRIDES
export DRUPAL_VERSION=\"9.1.2\"
export APPLICATION_BASELINE_SOURCECODE_REPOSITORY=\"DRUPAL:9.1.2\"
" > /root/Environment.env

. /root/Environment.env

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
/bin/sed -i 's/^*PasswordAuthentication [a-zA-Z]*/PasswordAuthentication no/' /etc/ssh/sshd_config

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
