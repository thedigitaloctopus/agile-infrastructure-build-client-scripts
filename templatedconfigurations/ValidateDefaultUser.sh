#!/bin/sh
###################################################################################
# Description : This will validate the default user as set in the template
# Author: Peter Winter
# Date  : 13/07/2020
###################################################################################
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
####################################################################################
####################################################################################

while ( [ "${CLOUDHOST}" = "digitalocean" ] && [ "${DEFAULT_USER}" != "root" ] )
do
    status "######################################################################################################################"
    status "Your template is located at: ${templatefile}"
    status "Your default user should be set to 'root'. The build will not complete - please update your template and press <enter>"
    status "######################################################################################################################"
    read x
    . ${templatefile}
done
while ( [ "${CLOUDHOST}" = "exoscale" ]  && [ "${BUILDOS}" = "ubuntu" ] && [ "${DEFAULT_USER}" != "ubuntu" ] )
do
    status "######################################################################################################################"
    status "Your template is located at: ${templatefile}"
    status "Your default user should be set to 'ubuntu'. The build will not complete - please update your template and press <enter>"
    status "######################################################################################################################"
    read x
    . ${templatefile}
done
while ( [ "${CLOUDHOST}" = "exoscale" ]  && [ "${BUILDOS}" = "debian" ] && [ "${DEFAULT_USER}" != "debian" ] )
do
    status "######################################################################################################################"
    status "Your template is located at: ${templatefile}"
    status "Your default user should be set to 'debian'. The build will not complete - please update your template and press <enter>"
    status "######################################################################################################################"
    read x
    . ${templatefile}
done
while ( [ "${CLOUDHOST}" = "linode" ] && [ "${DEFAULT_USER}" != "root" ] )
do
    status "######################################################################################################################"
    status "Your template is located at: ${templatefile}"
    status "Your default user should be set to 'root'. The build will not complete - please update your template and press <enter>"
    status "######################################################################################################################"
    read x
    . ${templatefile}
done
while ( [ "${CLOUDHOST}" = "vultr" ] && [ "${DEFAULT_USER}" != "root" ] )
do
    status "######################################################################################################################"
    status "Your template is located at: ${templatefile}"
    status "Your default user should be set to 'root'. The build will not complete - please update your template and press <enter>"
    status "######################################################################################################################"
    read x
    . ${templatefile}
done
while ( [ "${CLOUDHOST}" = "aws" ] && [ "${BUILDOS}" = "ubuntu" ] && [ "${DEFAULT_USER}" != "ubuntu" ] )
do
    status "######################################################################################################################"
    status "Your template is located at: ${templatefile}"
    status "Your default user should be set to 'ubuntu'. The build will not complete - please update your template and press <enter>"
    status "######################################################################################################################"
    read x
    . ${templatefile}
done
while ( [ "${CLOUDHOST}" = "aws" ]  && [ "${BUILDOS}" = "debian" ] && [ "${DEFAULT_USER}" != "admin" ] )
do
    status "######################################################################################################################"
    status "Your template is located at: ${templatefile}"
    status "Your default user should be set to 'debian'. The build will not complete - please update your template and press <enter>"
    status "######################################################################################################################"
    read x
    . ${templatefile}
done
