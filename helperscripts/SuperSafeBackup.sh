#!/bin/sh
####################################################################################################################
# Description: This script will store the sourcecode in a datastore of your choice
# This is useful for 'backing up' your sourcecode. It simply calls the script to store the code in a datastore for
# each of the different code areas of the project.
# Date: 07-11-16
# Author : Peter Winter
#####################################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

if ( [ ! -f  ./SuperSafeBackupToDatastore.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

BUILD_HOME="`/bin/cat ../buildconfiguration/buildhome`"
${BUILD_HOME}/helperscripts/SuperSafeBackupToDatastore.sh "XXX" "YYY" "agile-infrastructure-database-scripts"
${BUILD_HOME}/helperscripts/SuperSafeBackupToDatastore.sh "XXX" "YYY" "agile-infrastructure-webserver-scripts"
${BUILD_HOME}/helperscripts/SuperSafeBackupToDatastore.sh "XXX" "YYY" "agile-infrastructure-autoscaler-scripts"
