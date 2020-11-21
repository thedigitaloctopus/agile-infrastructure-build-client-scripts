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
