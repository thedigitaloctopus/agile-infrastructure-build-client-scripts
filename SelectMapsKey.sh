#!/bin/sh
######################################################################################################################
# Description: This is the script which asks which of the supported cloud host providers the user wishes to deploy to.
# Author: Peter Winter
# Date: 17/01/2017
######################################################################################################################
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
######################################################################################################
#set -x

#Give the user the choice of which of the supported cloudhosts they want to build to - could be as many as you like, it's
#just a matter of adding support

status ""
status ""
status "##################################################################################################"
status "First off, does you application need a maps api key?"
status "If so, enter it here or for easy use if you need to manually configure your application"
status "or if the application is automatically configured, it can obtain the key to use for your mapping from what you enter here"
status "##################################################################################################"
status "Enter your maps API Key (google maps, bing maps etc):"
read choice

MAPS_API_KEY="${choice}"
