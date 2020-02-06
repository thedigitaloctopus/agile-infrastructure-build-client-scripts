#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date : 10/04/2016
# Description: Commits specified file and pushes to origin
#####################################################################################
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
######################################################################################
######################################################################################
#set -x

status () {
    /bin/echo "$1" | /usr/bin/tee /dev/fd/3
}

status "Please Enter the full path to the source code you want to upload to a repository"
read SOURCECODE_PATH

cd ${SOURCECODE_PATH}

if ( [ "${APPLICATION_REPOSITORY_USERNAME}" = "" ] || [ "${APPLICATION_REPOSITORY_PASSWORD}" = "" ] || [ "${APPLICATION_REPOSITORY_OWNER}" = "" ] )
then
    status "Please enter your repository username"
    read APPLICATION_REPOSITORY_USERNAME
    status "Please enter your repository password (blank for no password)"
    read APPLICATION_REPOSITORY_PASSWORD
    status "Please enter your repository owner"
    read APPLICATION_REPOSITORY_OWNER
fi

/bin/rm -r .git
/usr/bin/git init
/usr/bin/git add .
/usr/bin/git commit -m "Update"

if ( [ "${repository_provider}" = "bitbucket" ] )
then
    if ( [ "${APPLICATION_REPOSITORY_PASSWORD}" = "" ] )
    then
        /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}@bitbucket.org/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_REPOSITORY_NAME}.git
    else
        /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@bitbucket.org/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_REPOSITORY_NAME}.git
    fi
fi
if ( [ "${repository_provider}" = "github" ] )
then
    if ( [ "${APPLICATION_REPOSITORY_PASSWORD}" = "" ] )
    then
        /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}@github.com/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_REPOSITORY_NAME}.git
    else
        /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@github.com/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_REPOSITORY_NAME}.git
    fi
fi
if ( [ "${repository_provider}" = "gitlab" ] )
then
    if ( [ "${APPLICATION_REPOSITORY_PASSWORD}" = "" ] )
    then
        /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}@gitlab.com/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_REPOSITORY_NAME}.git
    else
        /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@gitlab.com/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_REPOSITORY_NAME}.git
    fi
fi
/usr/bin/git push -u origin master
