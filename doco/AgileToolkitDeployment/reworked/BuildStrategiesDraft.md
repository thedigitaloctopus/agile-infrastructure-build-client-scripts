There are three basic ways you can build a deployment from the Agile Deployment Toolkit the full build, the expedited build, the hardcore build.

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
  
  **${BUILD_HOME}/buildconfiguration**  directory of your deployed buildmachine. This is useful if you wanted to create templates for a particular build configuration which I haven't generated a template for and you need to see what variables are set for use time and again in your hardcore builds. 
  
  if you look in **${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}** on your build machine once the build is complete you will see how the variables have been set and use that as a model for how you configure a new template. 
  
To perform the full build you need to run:

  **cd agile-infrastructure-build-client-scripts**
  
  **${BUILD_HOME}/AgileDeploymentToolkit.sh** on your build machine and then answer the questions.
  
  --------------------------
  
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
  
 Its also good if you want to see what configuration of variables is produced for a particular build configuration which you can review by looking in the 
  
 **${BUILD_HOME}/buildconfiguration**  directory of your deployed buildmachine. This is useful if you wanted to create templates for a particular build configuration which I haven't generated a template for and you need to see what variables are set for use time and again in your hardcore builds. 
  
 if you look in **${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}** on your build machine once the build is complete you will see how the variables have been set and use that as a model for how you configure a new template. 
  
**cd agile-infrastructure-build-client-scripts**
  
**${BUILD_HOME}/ExpeditedAgileDeploymentToolkit.sh** on your build machine and then answer the questions.
  
The expedited build will build directly from the template you select by number in the directory  
  
  **${BUILD_HOME}/templatedconfigurations/templates/${cloudhost}**
  
With the expedited method, there is no override process what you can do edit the template as it is in your repository **(making sure not to expose any sensitive credentials if your fork is public)** and then your team will simply be able to clone the repository and build off your taylored template as many times as they chose without having to worry about overrides. The Expedited build script will prompt for inputs when needed and there is some sanity checking built in.
  
This can be a useful method if you are not too sure about how the scripts work because there is a lot of built in explanation as the script runs, but, it is more involved or slower to use than the hardcore method. 

  ------------------
  
## THE HARDCORE BUILD
  
  The hardcore method provides no interaction with you once you start it running. So, you have to set everything up preflight unlike the other two methods. This is by far the quickest way and it may even be the most easy to understand, I am not sure. Below is described the steps you need to go through to launch a hardcore build using the Agile Deployment Toolkit build process. 
  
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
**SELECTED_TEMPLATE**
  
  8. Once you are happy that all the variables are correct copy it in its entirety and paste it into the user-data of a new VPS machine with your cloud provider
  
  9. **ssh** onto the build machine that you spun up in 8. and do as **"sudo su"** and give your **BUILDMACHINE_PASSWORD**
  
  10. **cd agile-infrastructure-build-client-scripts/logs**
  
  11. **tail -f build*out** to get the build progress
