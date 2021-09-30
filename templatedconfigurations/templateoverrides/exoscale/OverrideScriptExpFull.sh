#!/bin/bash

/bin/mkdir /root/logs

OUT_FILE="webserver-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>/root/logs/${OUT_FILE}
ERR_FILE="webserver-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>/root/logs/${ERR_FILE}

###############################################################################################
# SET THESE FOR YOUR BUILD CLIENT MACHINE
# THIS WILL NOT START A BUILD IT WILL JUST SETUP THE TOOLKIT
# USE THIS IF YOU WANT TO PERFORM AN EXPEDITED OR A FULL BUILD FROM THE COMMAND LINE
# ssh -i <ssh-private-key> -p ${BUILDCLIENT_SSH_PORT} $BUILDCLIENT_USER@<buildclientip>
# $BUILDCLIENT_USER>sudo su
# password:${BUILDCLIENT_PASSWORD}
# cd agile-infrastructure-build-client-scripts/logs
#############################################################################################################
####POPULATE THESE export VARIABLES BETWEEN THE STARS AND PASTE THIS SCIPT INTO YOUR VPS MACHINES USER-DATA #
#############################################################################################################
####################################################################################
#**********************************************************************************#
####################################################################################
export BUILDCLIENT_USER="agile-user"
export BUILDCLIENT_PASSWORD="Hjdhfb34hd£"
export BUILDCLIENT_SSH_PORT="1035"
export LAPTOP_IP=""

/bin/echo "
#BASE OVERRIDES
export SSH=\"\" #paste your public key here

#################################################################
#MODIFY THESE VALUES IF YOU ARE DEPLOYING FROM A FORKED REPOSITORY
#################################################################
#export INFRASTRUCTURE_REPOSITORY_PROVIDER=\"github\"
#export INFRASTRUCTURE_REPOSITORY_OWNER=\"adt-demos\"
#export INFRASTRUCTURE_REPOSITORY_USERNAME=\"adt-demos\"
#export INFRASTRUCTURE_REPOSITORY_PASSWORD=\"none\"

####################################################################################
#**********************************************************************************#
####################################################################################
#If you understand the way this toolkit works you can set the template you are using
#below and override any of the variables in it. For example, you can override
#the WS_SIZE default by entering:
#export WS_SIZE="50G" to override the "export WS_SIZE="10G" of the selected template.
#Alter the value SELECTED_TEMPLATE below to change which template the build will be based on
#####################################################################################
#ADDITIONAL OVERRIDES, ANYTHING NOT OVERRIDEN WILL TAKE IT'S VALUE FROM THE SELECTED_TEMPLATE VALUE
#THE TEMPLATES CAN BE FOUND at ${BUILD_HOME}/templatedconfiguration/templates/digitalocean
export SELECTED_TEMPLATE=\"1\"
#export WS_SIZE=\"50G\"
#####################################################################################

" > /root/Environment.env

. /root/Environment.env


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

/usr/bin/apt-get -qq -y update
/usr/bin/apt-get -qq -y install git
/usr/bin/apt-get -qq -y install ufw

/usr/sbin/ufw enable
/usr/sbin/ufw default deny incoming
/usr/sbin/ufw default allow outgoing
/usr/sbin/ufw allow from ${LAPTOP_IP}
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
