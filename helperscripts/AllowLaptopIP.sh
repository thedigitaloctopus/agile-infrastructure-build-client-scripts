#!/bin/sh

if ( [ ! -f  ./AllowLaptopIP.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr 5)AWS. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
    CLOUDHOST="digitalocean"
    token_to_match="*autoscaler*"
elif ( [ "${response}" = "2" ] )
then
    CLOUDHOST="exoscale"
    token_to_match="autoscaler"
elif ( [ "${response}" = "3" ] )
then
    CLOUDHOST="linode"
    token_to_match="*autoscaler*"
elif ( [ "${response}" = "4" ] )
then
    CLOUDHOST="vultr"
    token_to_match="*autoscaler*"
elif ( [ "${response}" = "5" ] )
then
    CLOUDHOST="aws"
    token_to_match="*autoscaler*"
else
    /bin/echo "Unrecognised  cloudhost. Exiting ...."
    exit
fi

export BUILD_HOME="`/bin/pwd | /bin/sed 's/\/helper.*//g'`"

/bin/echo "What is the build identifier you want to allow access for?"
/bin/echo "You have these builds to choose from: "
/bin/ls ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} | /bin/grep -v 'credentials'
/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

/bin/echo "Please enter the IP address you wish to add access for. You can find the ip address of your laptop using: www.whatsmyip.com"
read ip


/usr/bin/s3cmd --force get s3://authip-${BUILD_IDENTIFIER}/authorised-ips.dat

if ( [ ! ./authorised-ips.dat ] )
then
    /bin/echo "Failed to get a list of authorised ips, you might have to look into a manual update"
    exit
fi

/bin/echo ${ip} >> ./authorised-ips.dat

/usr/bin/s3cmd put ./authorised-ips.dat s3://authip-${BUILD_IDENTIFIER}

/bin/touch  ./FIREWALL-EVENT

/usr/bin/s3cmd put ./FIREWALL-EVENT s3://authip-${BUILD_IDENTIFIER}

/bin/rm ./authorised-ips.dat ./FIREWALL-EVENT
