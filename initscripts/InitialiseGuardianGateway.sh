#!/bin/bash
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2016
# Description : This script will set whether to use the Guardian Gateway or not
########################################################################################
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
#########################################################################################
#########################################################################################
#set -x

if ( [ "${PREVIOUS_BUILD_CONFIG}" = "0" ] )
then

    status "######################################################"
    status "Would you like to install the Guardian Gateway system?"
    status "######################################################"
    status "Please enter (Y|y) to install the Guardian Gateway system"
    read response
    
    if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
    then
        GATEWAY_GUARDIAN="1"
    else
        GATEWAY_GUARDIAN="0"
    fi
fi
