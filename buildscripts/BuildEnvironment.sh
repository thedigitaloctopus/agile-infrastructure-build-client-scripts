#!/bin/sh
##########################################################################################
# Author: Peter Winter
# Date : 10/7/2016
# Description : Initialise the environment
##########################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
##########################################################################################
###########################################################################################
#set -x
APPLICATION_IDENTIFIER=""
APPLICATION_NAME=""
APPLICATION_BASELINE_SOURCECODE_REPOSITORY=""
APPLICATION_BASELINE_SOURCECODE_REPOSITORY_URL=""
BASELINE_DB_REPOSITORY=""
WEBSITE_URL=""
WEBSITE_NAME=""
WEBSITE_DISPLAY_NAME=""
ALGORITHM=""
DEFAULT_USER=""
MACHINE_TYPE=""
USER=""
BUILD_CLIENT_IP=""
CLOUDHOST=""
BUILD_HOME=""
SERVER_TIMEZONE_CONTINENT=""
SERVER_TIMEZONE_CITY=""
PREVIOUS_BUILD_CONFIG=""
BUILD_IDENTIFIER=""
WSIP=""
WSIP_PRIVATE=""
ASIP=""
ASIP_PRIVATE=""
DBIP=""
DBIP_PRIVATE=""
BUILD_CHOICE=""
REGION_ID=""
DB_SIZE=""
WS_SIZE=""
AS_SIZE=""
DB_SERVER_TYPE=""
WS_SERVER_TYPE=""
AS_SERVER_TYPE=""
PUBLIC_KEY_NAME="AGILE_TOOLKIT_PUBLIC_KEY"
AWSACCESS=""
AWSSECRET=""
TOKEN=""
ACCESSKEY=""
SECRETKEY=""
AUTOSCALE_FROM_SNAPSHOTS="0"
INFRASTRUCTURE_REPOSITORY_OWNER=""
INFRASTRUCTURE_REPOSITORY_USERNAME=""
INFRASTRUCTURE_REPOSITORY_PASSWORD=""
INFRASTRUCTURE_REPOSITORY_PROVIDER=""
APPLICATION_REPOSITORY_TOKEN=""
APPLICATION_REPOSITORY_PROVIDER=""
APPLICATION_REPOSITORY_USERNAME=""
APPLICATION_REPOSITORY_PASSWORD=""
APPLICATION_REPOSITORY_OWNER=""
DATASTORE_CHOICE=""
SUPERSAFE_WEBROOT="0"
SUPERSAFE_DB="0"
CLOUDHOST_USERNAME=""
CLOUDHOST_EMAIL_ADDRESS=""
CLOUDHOST_PASSWORD=""
DNS_CHOICE=""
DNS_USERNAME=""
DNS_SECURITY_KEY=""
DNS_REGION=""
DATABASE_INSTALLATION_TYPE="MARIA"
GIT_EMAIL_ADDRESS=""
GIT_USER=""
SYSTEM_EMAIL_PROVIDER=""
SYSTEM_TOEMAIL_ADDRESS=""
SYSTEM_FROMEMAIL_ADDRESS=""
SYSTEM_EMAIL_USERNAME=""
SYSTEM_EMAIL_PASSWORD=""
APPLICATION_LANGUAGE=""
BUILDOS=""
BUILDOS_VERSION=""
DEVELOPMENT="0"
PRODUCTION="0"
APPLICATION=""
BUILD_ARCHIVE_CHOICE=""
SSH_PORT="1000"
DB_PORT="1000"
SSL_GENERATION_METHOD=""
SSL_PROVIDER=""
DBaaS_HOSTNAME=""
DBaaS_USERNAME=""
DBaaS_PASSWORD=""
DBaaS_DBNAME=""
DEFAULT_DBaaS_OS_USER=""
DATABASE_DBaaS_INSTALLATION_TYPE=""
DBaaS_DBSECURITYGROUP=""
BYPASS_DB_LAYER="0"
SUBNET_ID=""
PHP_MODE=""
PHP_MAX_CHILDREN=""
PHP_START_SERVERS=""
PHP_MIN_SPARE_SERVERS=""
PHP_MAX_SPARE_SERVERS=""
PHP_PROCESS_IDLE_TIMEOUT=""
IN_MEMORY_CACHING=""
IN_MEMORY_CACHING_PORT=""
IN_MEMORY_SECURITY_GROUP=""
DISABLE_HOURLY=""
ENABLE_EFS=""
SUBNET_ID=""
AUTOSCALE_FROM_SNAPSHOTS=""
GENERATE_SNAPSHOTS=""
SNAPSHOT_ID=""
WEBSERVER_IMAGE_ID=""
AUTOSCALER_IMAGE_ID=""
DATABASE_IMAGE_ID=""
PERSIST_ASSETS_TO_CLOUD=""
ASSETS_BUCKET=""
JOOMLA_VERSION=""
DRUPAL_VERSION=""
S3_ACCESS_KEY=""
S3_SECRET_KEY=""
S3_HOST_BASE=""
S3_LOCATION=""
