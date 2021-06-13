
status "####################################################################################"
status "Please tell me which of the supported cloudhosts you are deploying to"
status " 1. Digital Ocean (www.digitalocean.com)"
status " 2. Exoscale (www.exoscale.com)"
status " 3. Linode (www.linode.com)"
status " 4. Vultr (www.vultr.com)"
status " 5. AWS (aws.amazon.com)"
status "####################################################################################"
status "You can indicate your choice by entering a number between 1 and 5"
read response

valid="0"

while ( [ "${valid}" = "0" ] )
do
    if ( [ "${response}" != "0" ] )
    then 
        if ( [ ${response} ] && [ ${response} -eq ${response} 2>/dev/null ] )
        then
            if ( [ "${reponse}" -lt "1" ] || [ "${response}" -gt "5" ] )
            then
                valid="0"
            else
                valid="1"
            fi
        else
            valid="0"
        fi
        if ( [ "${valid}" = "0" ] )
        then
            status "That was not a valid input, please try again...."
            read response
        else
            case  ${response}  in
                1)       
                    CLOUDHOST="digitalocean"
                    ${BUILD_HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
                    ;;
                2)
                    CLOUDHOST="exoscale"
                    ${BUILD_HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
                    ;;            
                3)       
                    CLOUDHOST="linode"
		    ${BUILD_HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
                    ;;
                4)       
                    CLOUDHOST="vultr"
		    ${BUILD_HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
                    ;;
                5)       
                    CLOUDHOST="aws"
		    ${BUILD_HOME}/providerscripts/cloudhost/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
                    ;;
                *)
           esac 
       fi
    else
        status "That was not a valid input, please try again...."
        read response
    fi
done

status "Your cloudhost is set to ${CLOUDHOST}"
