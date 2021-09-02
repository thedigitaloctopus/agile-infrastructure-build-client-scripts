#!/bin/bash

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
     :
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
    SNAPSHOT_ID=${snapshot_id}
    TEMPLATE_ID=$(/usr/bin/exo vm snapshot show --output-template {{.TemplateID}} ${SNAPSHOT_ID})
    BOOTMODE=$(/usr/bin/exo vm template show --output-template {{.BootMode}} ${TEMPLATE_ID})
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
