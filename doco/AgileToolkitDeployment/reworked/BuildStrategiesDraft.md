There are three basic ways you can build a deployment from the Agile Deployment Toolkit:

# 1. The Full Build
# 2. The Expedited Buikd
# 3. The Hardcore Build

## THE FULL BUILD

To perform a full build, you need to spin up a secured build machine on your cloudhosting provider. You can do this by using the script: [OverrideScript](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/OverrideScript.sh) and pasting it into the user data area of the VPS machine you are provisioning through your hosting provider's gui system. You need to set the variables:

**BUILDMACHINE_USER**   
**BUILDMACHINE_PASSWORD**  
**BUILDMACHINE_SSH_PORT**  
**LAPTOP_IP**
**SSH**

before pasting it into the user data area of your VPS machine.

Once the machine has provisioned, you can ssh onto it from your latop using the command:

**ssh -p ${BUILD_MACHINE_SSH_PORT} ${BUILDMACHINE_USER}@<build-machine-ip>**
<enter> ${BUILDMACHINE_PASSWORD}
  
The Full Build involves manually running a script and entering values at the command line. The inputs you give have limited saniy checking on them and is good if you really don't understand how this toolkit works.  Its also good if you want to see what configuration of variables is produced for a particular build configuration which you can review by looking in the 
  
  **${BUILD_HOME}/buildconfiguration**  directory of your deployed buildmachine.

To perform the full build you need to run:
  
  **${BUILD_HOME}/AgileDeploymentToolkit.sh** on your build machine and then answer the questions.
  
## THE EXPEDITED BUILD
 
  To perform a full build, you need to spin up a secured build machine on your cloudhosting provider. You can do this by using the script: [OverrideScript](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/OverrideScript.sh) and pasting it into the user data area of the VPS machine you are provisioning through your hosting provider's gui system. You need to set the variables:

**BUILDMACHINE_USER**   
**BUILDMACHINE_PASSWORD**  
**BUILDMACHINE_SSH_PORT**  
**LAPTOP_IP**
**SSH**

before pasting it into the user data area of your VPS machine.

Once the machine has provisioned, you can ssh onto it from your latop using the command:

**ssh -p ${BUILD_MACHINE_SSH_PORT} ${BUILDMACHINE_USER}@<build-machine-ip>**
<enter> ${BUILDMACHINE_PASSWORD}
  
The Expedited Build involves manually editing a template of your choosing and manually running a shell script to deploy from that template.

## THE HARDCORE BUILD
  
  1. On your laptop clone the build client scripts for example (or from your fork):
  
  2. **git clone https://github.com/agile-deployer/agile-infrastructure-build-client-scripts.git**
  
  3. **cd agile-infrastructure-build-client-scripts**
  
  4. **/bin/sh ./helperscripts/GenerateOverrideTemplate.sh** and answer the questions as it asks them 
  
  5. **/bin/sh ./helperscripts/GenerateHardcoreUserDataScript.sh** and answer the questions as it asks them
  
  6. **cd ${BUILD_HOME}/userdatascripts** and find the script that you have just generated
  
  7. Review the script and update the variables at the top of the script:
  
  **BUILDMACHINE_USER**  
**BUILDMACHINE_PASSWORD**  
**BUILDMACHINE_SSH_PORT**  
**LAPTOP_IP**  
**SSH**
  
  8. Once you are happy that all the variables are correct copy it in its entirety and paste it into the user-data of a new VPS machine with your cloud provider
  
  9. **ssh** onto the build machine that you spun up in 8. and do as **"sudo su"** and give your **BUILDMACHINE_PASSWORD**
  
  10. **cd agile-infrastructure-build-client-scripts/logs**
  
  11. **tail -f build*out** to get the build progress
