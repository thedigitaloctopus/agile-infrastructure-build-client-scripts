if ( [ "${CLOUDHOST}" = "aws" ] )
then
    status ""
    status ""
    status "############################################################################################################"
    status "AWS makes use of subnets. As such we need to select a subnet to use. Please answer the following questions:"
    status "Note: The subnet needs to be in the same VPC as the security group that you set for your EC2 instances"
    status "############################################################################################################"
    status ""

    security_group_id="`/usr/bin/aws ec2 describe-security-groups | /usr/bin/jq '.SecurityGroups[] | .GroupName + " " + .GroupId' | /bin/grep AgileDeploymentToolkitSecurityGroup | /bin/sed 's/\"//g' | /usr/bin/awk '{print $NF}'`"

    if ( [ "${security_group_id}" = "" ] )
    then
         status "I couldn't find a security group to use for your servers. I need to know which VPC you want to use"
         status "Here is a list of VPCs that are available please copy and paste to the prompt the VPC you want to use"
         /usr/bin/aws ec2 describe-vpcs | /usr/bin/jq '.Vpcs[] | .VpcId' | /bin/sed 's/\"//g' >&3
         read vpc_id
         /usr/bin/aws ec2 create-security-group --description "This is the security group for your agile deployment toolkit" --group-name "AgileDeploymentToolkitSecurityGroup" --vpc-id=${vpc_id}
         if ( [ "$?" != "0" ] )
         then
             status "Couldn't create the Security Group"
             exit
         fi
    else
         vpc_id="`/usr/bin/aws ec2 describe-security-groups --group-ids ${security_group_id} | /usr/bin/jq '.SecurityGroups[] | .VpcId' | /bin/sed 's/\"//g'`"
    fi

    export SUBNET_ID="`/bin/grep "SUBNET_ID" ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} | /usr/bin/awk -F'=' '{print $NF}' | /usr/bin/tr -d '"'`"
    if ( [ "${SUBNET_ID}" != "" ] )
    then
        status "Found a Subnet ID which is set to : ${SUBNET_ID}"
        status "Is this correct (Y|N)?"
        read answer
        if ( [ "${answer}" = "N" ] || [ "${answer}" = "n" ] )
        then
            status "Please enter a subnet ID to use. Your available regions and subnets are:"
            status "REGIONS         SUBNETS         VPC"
            /usr/bin/aws ec2 describe-subnets | /usr/bin/jq '.Subnets[] | .AvailabilityZone + " " + .SubnetId + " " + .VpcId'  | /bin/grep ${vpc_id} | /bin/grep ${REGION_ID} >&3
            read subnet_id
            export SUBNET_ID=${subnet_id}
        fi
    else
        status "Please enter a subnet ID to use. Your available regions and subnets are:"
        status "REGIONS        SUBNETS           VPC"
        /usr/bin/aws ec2 describe-subnets | /usr/bin/jq '.Subnets[] | .AvailabilityZone + " " + .SubnetId + " " + .VpcId' | /bin/grep ${vpc_id} | /bin/grep ${REGION_ID} >&3
        read subnet_id        
        export SUBNET_ID=${subnet_id}
    fi

    /bin/sed -i '/SUBNET_ID=/d' ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
    /bin/echo "export SUBNET_ID=\"${SUBNET_ID}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
fi
