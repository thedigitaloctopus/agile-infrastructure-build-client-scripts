#!/bin/sh

actioned="0"
if ( [ -f /etc/ssh/ssh_config ] && [ "`/bin/cat /etc/ssh/ssh_config | /bin/grep 'ServerAliveInterval 240'`" = "" ] )
then
    /bin/echo "ServerAliveInterval 240" >> /etc/ssh/ssh_config
    /bin/echo "ServerAliveCountMax 5" >> /etc/ssh/ssh_config
    actioned="1"  
fi

if ( [ -f /etc/ssh/sshd_config ] && [ "`/bin/cat /etc/ssh/sshd_config | /bin/grep 'ClientAliveInterval 60'`" = "" ] )
then
    /bin/echo "ClientAliveInterval 60
TCPKeepAlive yes
ClientAliveCountMax 10000" >> /etc/ssh/sshd_config
    /usr/sbin/service sshd restart
    actioned="1"
fi

BUILDOS="ubuntu" #########STACK
BUILDOS_VERSION="20.04" #########STACK
CLOUDHOST="linode" #############STACK
BUILD_IDENTIFIER="nuocial" ####STACK
DNS_USERNAME=""  #MANDATORY
DNS_SECURITY_KEY=""   #MANDATORY
DNS_CHOICE="cloudflare"
WEBSITE_DISPLAY_NAME="" ###STACK
WEBSITE_NAME="" #STACK
WEBSITE_URL=""  #STACK
SELECTED_TEMPLATE="1" ##############STACK
SYSTEM_EMAIL_USERNAME="1" ####STACK
SYSTEM_EMAIL_PASSWORD="1" ####STACK
SYSTEM_EMAIL_PROVIDER="1" ###STACK
SYSTEM_TOEMAIL_ADDRESS="1" ####STACK
SYSTEM_FROMEMAIL_ADDRESS="1" ####STACK
S3_ACCESS_KEY="1" ####STACK
S3_SECRET_KEY="1" ####STACK
S3_HOST_BASE="1" ####STACK
S3_LOCATION="1" ####STACK
TOKEN="1" ####STACK
NO_AUTOSCALERS="1" #####STACK

if ( [ ! -d /usr/local/go ] )
then
    ${BUILD_HOME}/installscripts/InstallGo.sh ${BUILDOS}
fi

export GOROOT=/usr/local/go
export GOPATH=$HOME
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

if ( [ ! -f /usr/bin/lego ] )
then
    ${BUILD_HOME}/installscripts/InstallLego.sh ${BUILDOS}
fi 

DOMAIN_URL="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F':' '{print $NF}' | /usr/bin/awk -F'.' '{$1="";print}' | /bin/sed 's/^ //' | /bin/sed 's/ /./g'`"

if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
then

    #For production
    command="CLOUDFLARE_EMAIL="${DNS_USERNAME}" CLOUDFLARE_API_KEY="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
fi

/bin/sh HardcoreAgileDeploymentToolkit.sh
