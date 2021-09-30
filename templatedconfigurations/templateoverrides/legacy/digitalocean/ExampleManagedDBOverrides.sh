#!/bin/bash

###################################################################################################################################################################
#To use this file, review every variable and set it appropriately, then copy it to your userdata area when you create your build droplet
#you can refer to the specification for the ADT templating system to review this parameters which is located at: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md
#To make your build possible fill in all these environment variables and paste this entire (updated) file into the userdata are of your build client droplet. 
#THIS SCRIPT IS AN EXAMPLE OF HOW TO DEPLOY FOR A MANAGED DATABASE FOR WORDPRESS ON DIGITALOCEAN. I DRAW YOUR ATTENTION TO THE ADDITIONAL OVERRIDES.
#THE SELECTED_TEMPLATE PARAMETER SELECTS FOR WORDPRESS
####################################################################################################################################################################
/bin/echo "
#BASE OVERRIDES
export SSH=\"\" #paste your public key here
export BUILDOS=\"debian\" #one of ubuntu|debian
export BUILDOS_VERSION=\"10\" #one of 20.04|10
export CLOUDHOST=\"digitalocean\"  #Always digitalocean
export REGION_ID=\"lon1\"  #The region ID for your deployment - one of "nyc1","sfo1","nyc2","ams2","sgp1","lon1","nyc3","ams3","fra1","tor1","sfo2","blr1","sfo3"
export BUILD_IDENTIFIER=\"nuocial\" #Unique string to identify your build
export S3_ACCESS_KEY=\"\" #Digital Ocean Spaces Access Key
export S3_SECRET_KEY=\"\" #Digital Ocean Spaces Secret Key
export S3_HOST_BASE=\"ams3.digitaloceanspaces.com\"  #Host base for your digital ocean spaces  one of: nyc3.digitaloceanspaces.com, ams3.digitaloceanspaces.com, sfo2.digitaloceanspaces.com, sgp1.digitaloceanspaces.com, fra1.digitaloceanspaces.com
export S3_LOCATION=\"US\" #Always set to US for digitalocean
export TOKEN=\"\" #Your personal acccess token
export DNS_USERNAME=\"\"  #Your DNS provider username (for cloudflare it is the email address for your account)
export DNS_SECURITY_KEY=\"\"  #Your DNS API key, for example, Global API key from cloudflare
export DNS_CHOICE=\"cloudflare\" #Your DNS provider
export WEBSITE_DISPLAY_NAME=\"Nuocial\" #Display name for example "My Blogging Website"
export WEBSITE_NAME=\"nuocial\"  #The core of WEBSITE_URL, for example, if WEBSITE_URL=ok.nuocial.org.uk, WEBSITE_NAME="nuocial"
export WEBSITE_URL=\"ok.nuocial.org.uk\"  #the URL of the website registered with your DNS provider
export SELECTED_TEMPLATE=\"3\" #Select a template number (1-10) to build you can review available template descriptions to decide which you want to deploy here: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/tree/master/templatedconfigurations/templates/digitalocean/templatemenu.md 
export NO_AUTOSCALERS=\"1\" #Number of autoscalers (1-5)
#The values above are the values that I override by default. If, for example, you wanted to override the size of your webserver machines you could 
#simply add an export statement beneath the additional overrides section below 
# and define it for your provider based on the template specification. Similarly for any of the other variables that you find in 
#the template. You need to be aware of how the variables play with each other, which needs to be set with which, for example. Running the 
#full AgileDeploymentToolkit script and setting the configuration you desire will give you an env dump upon successful completion in the 
#${BUILD_HOME}/buildcompletion directory which will show you which variables need to be set for the particular configuration you desire. 
####ADDITIONAL OVERRIDES
#export WS_SIZE=\"\"
export PHP_VERSION=\"8.0\"
export DBaaS_HOSTNAME=\"private-db-mysql-lon1-123763-do-user-219393-0.b.db.ondigitalocean.com\" #replace with your own value
export DBaaS_USERNAME=\"doadmin\" #replace with your own value
export DBaaS_PASSWORD=\"huuef73fhsfww2\"  #Replace with your own value
export DBaaS_DBNAME=\"defaultdb\"
export DATABASE_DBaaS_INSTALLATION_TYPE=\"Maria\"
export DATABASE_INSTALLATION_TYPE=\"DBaaS\"
export DB_PORT=\"25060\" #replace with your own value
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
