#!/bin/sh
###########################################################################################
# Author : Peter Winter
# Date   : 16/07/2016
# Description : This script constructs the repository url for the infrastructure repository
###########################################################################################
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
############################################################################################
############################################################################################
#set -x

repository_provider="${1}"
APPLICATION_REPOSITORY_OWNER="${2}"
APPLICATION_BASELINE_SOURCECODE_REPOSITORY="${3}"

if ( [ "${repository_provider}" = "bitbucket" ] )
then
    if ( [ "${INFRASTRUCTURE_REPOSITORY_PASSWORD}" = "none" ] )
    then
        /bin/echo "https://${INFRASTRUCTURE_REPOSITORY_USERNAME}@bitbucket.org/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}.git"
    else
        /bin/echo "https://${INFRASTRUCTURE_REPOSITORY_USERNAME}:${INFRASTRUCTURE_REPOSITORY_PASSWORD}@bitbucket.org/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}.git"
    fi
fi
if ( [ "${repository_provider}" = "github" ] )
then
    if ( [ "${INFRASTRUCTURE_REPOSITORY_PASSWORD}" = "none" ] )
    then
        /bin/echo "https://${INFRASTRUCTURE_REPOSITORY_USERNAME}@github.com/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}.git"
    else
        /bin/echo "https://${INFRASTRUCTURE_REPOSITORY_USERNAME}:${INFRASTRUCTURE_REPOSITORY_PASSWORD}@github.com/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}.git"
    fi
fi
if ( [ "${repository_provider}" = "gitlab" ] )
then
    if ( [ "${INFRASTRUCTURE_REPOSITORY_PASSWORD}" = "none" ] )
    then
        /bin/echo "https://${INFRASTRUCTURE_REPOSITORY_USERNAME}@gitlab.com/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}.git"
    else
        /bin/echo "https://${INFRASTRUCTURE_REPOSITORY_USERNAME}:${INFRASTRUCTURE_REPOSITORY_PASSWORD}@gitlab.com/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}.git"
    fi
fi

