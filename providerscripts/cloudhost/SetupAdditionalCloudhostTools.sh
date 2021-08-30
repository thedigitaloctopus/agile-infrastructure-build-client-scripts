if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
    :
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
    /bin/mkdir -p /root/.config/exoscale

    ACCESS_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/ACCESS_KEY`"
    SECRET_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/SECRET_KEY`"

    /bin/echo "defaultaccount = \"${CLOUDHOST_EMAIL_ADDRESS}\"
[[accounts]]
  account = \"${CLOUDHOST_EMAIL_ADDRESS}\"
  endpoint = \"https://api.exoscale.com/v1\"
  environment = \"\"
  key = \"${ACCESS_KEY}\"
  name = \"${CLOUDHOST_EMAIL_ADDRESS}\"
  secret = \"${SECRET_KEY}\""> /root/.config/exoscale/exoscale.toml
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
    :
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
    :
fi

if ( [ "${CLOUDHOST}" = "aws" ] )
then
    :
fi
  
  
