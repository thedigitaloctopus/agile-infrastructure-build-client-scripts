There are three basic ways you can build a deployment from the Agile Deployment Toolkit:

1. The Full Build
2. The Expedited Buikd
3. The Hardcore Build

#### THE FULL BUILD

To perform a full build, you need to spin up a secured build machine on your cloudhosting provider. You can do this by using the script: [OverrideScript](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/OverrideScript.sh) and pasting it into the user data area of the VPS machine you are provisioning through your hosting provider's gui system. You need to set the variables:

**BUILDMACHINE_USER, BUILDMACHINE_PASSWORD,BUILDMACHINE_SSH_PORT,LAPTOP_IP**

before pasting it into the user data area of your VPS machine.

Once the machine has provisioned, you can ssh onto it from your latop using the command:

ssh -p ${BUILD_MACHINE_SSH_PORT} ${BUILDMACHINE_USER}@<build-machine-ip>
<enter> ${BUILDMACHINE_PASSWORD}
  
The Full Build involves manually running a script and entering values at the command line. The inputs you give have limited saniy checking on them and is good if you really don't understand how this toolkit works.  Its also good if you want to see what configuration of variables is produced for a particular build configuration which you can review by looking in the ${BUILD_HOME}/buildconfiguration directory of your deployed buildmachine.

To perform the full build you need to run:
  
  **${BUILD_HOME}/AgileDeploymentToolkit.sh** on your build machine and then answer the questions.
  
#### THE EXPEDITED BUILD
 
  
The Expedited Build involves manually editing a template of your choosing and manually running a shell script to deploy from that template.

The Hardcore build involves manually editing an override script or generating one using the ${BUILD_HOME}/helperscripts/GenerateOverrideScript.sh
