#!/bin/bash

SNAPSHOT_ID=${snapshot_id}
TEMPLATE_ID=$(exo vm snapshot show --output-template {{.TemplateID}} ${SNAPSHOT_ID})
BOOTMODE=$(exo vm template show --output-template {{.BootMode}} ${TEMPLATE_ID})
