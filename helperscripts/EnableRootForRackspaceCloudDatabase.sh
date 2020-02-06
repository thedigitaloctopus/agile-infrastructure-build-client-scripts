#!/bin/bash
# Enable root dbaas user access
# User Alterable variables
# Author: Adam Bull
# Date: Monday, November 30 2015
# Company: Rackspace UK Server Hosting

# ACCOUNTID forms part of your control panel login; https://mycloud.rackspace.co.uk/cloud/1001111/database#rax%3Adatabase%2CcloudDatabases%2CLON/321738d5-1b20-4b0f-ad43-ded24f4b3655

/bin/echo "Enter your Account (DDI) this is the number which forms part of your control panel login e.g. https://mycloud.rackspace.co.uk/cloud/1001111/"
read ACCOUNTID

/bin/echo "Enter your Database ID, this is the number which forms part of your control panel login when browsing the database instance e.g. https://mycloud.rackspace.co.uk/cloud/1001111/database#rax%3Adatabase%2CcloudDatabases%2CLON/242738d5-1b20-4b0f-ad43-ded24f4b3655"
read DATABASEID

/bin/echo "Enter what Region your database is in i.e. lon, dfw, ord, iad, syd, etc"
read REGION

/bin/echo "Enter your customer username login (visible from account settings page)"
read USERNAME

/bin/echo "Enter your customer apikey (visible from account settings page)"
read APIKEY

/bin/echo "$USERNAME $APIKEY"


TOKEN=`curl https://identity.api.rackspacecloud.com/v2.0/tokens -X POST -d '{ "auth":{"RAX-KSKEY:apiKeyCredentials": { "username":"'$USERNAME'", "apiKey": "'$APIKEY'" }} }' -H "Content-type: application/json" |  python -mjson.tool | grep -A5 token | grep id | cut -d '"' -f4`

/bin/echo "Enabling root access for instance $DATABASEID...see below for credentials"
# Enable the root user for instance id
/usr/bin/curl -X POST -i \
    -H "X-Auth-Token: $TOKEN" \
    -H 'Content-Type: application/json' \
    "https://$REGION.databases.api.rackspacecloud.com/v1.0/$ACCOUNTID/instances/$DATABASEID/root"

# Confirm root user added
/usr/bin/curl -i \
    -H "X-Auth-Token: $TOKEN" \
    -H 'Content-Type: application/json' \
    "https://$REGION.databases.api.rackspacecloud.com/v1.0/$ACCOUNTID/instances/$DATABASEID/root"
