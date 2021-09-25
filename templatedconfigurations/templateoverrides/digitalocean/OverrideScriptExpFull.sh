#!/bin/bash

/bin/mkdir /root/logs

OUT_FILE="webserver-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>/root/logs/${OUT_FILE}
ERR_FILE="webserver-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>/root/logs/${ERR_FILE}
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
export BUILDCLIENT_USER="agile-user"
export BUILDCLIENT_PASSWORD="Jhygbdhbg21sghf"
export BUILDCLIENT_SSH_PORT="1035"
export BACKUP_PASSWORD="hdbfrhejsb38"


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

/usr/sbin/ufw allow ${BUILDCLIENT_SSH_PORT}/tcp 

cd /home/${BUILDCLIENT_USER}

if ( [ "${INFRASTRUCTURE_REPOSITORY_OWNER}" != "" ] )
then
    /usr/bin/git clone https://github.com/${INFRASTRUCTURE_REPOSITORY_OWNER}/agile-infrastructure-build-client-scripts.git
else
    /usr/bin/git clone https://github.com/agile-deployer/agile-infrastructure-build-client-scripts.git
fi

cd agile-infrastructure-build-client-scripts
