#### BUILD STRATEGIES (ABRIDGED SUMMARY)

What will happen during a **full build** (with the AgileDeploymentToolkit) script is that:

1. You will provision a vanilla VPS system by populating the 5 or 6 necessary variables only in the [Build Machine](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/OverrideScript.sh) script and pasting it into the user data of a VPS machine that you are provisioning with your cloudhost.

2. You will then ssh onto the machine (using your private key that matches the public key you set in 1. and as well as the ssh port and username).

3. You will do a "sudo su" on your build machine using the password from 1. 

4. You will cd into the agile-infrastructure-build-client-scripts and you will run /bin/sh ./AgileDeploymentToolkit.sh

5. You will answer all the questions (correctly) and the build will run

6. At the end of the build the environment that was used will be stored in a file:

**${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}**

Which you can use next time to build from without answering all the questions or you can take a separate copy of and replace 

**${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}** 

with any time you want to do the same build again. 

-------------------

During an **Expedited build** you will follow the same procedure as above, but, you will answer less questions and you will run the script **"ExpeditedAgileDeploymentToolkit.sh"** instead.

--------------------

During a **hardcore build**, you have a couple of options

For Option 1, you can:

1. Take a copy of [Template Override](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/OverrideScript.sh) and follow the instructions contained with it to setup manual overrides.

2. Paste your updated script into the user-data of a new VPS machine with your cloudhost. (The variables you have added must be correct and sane according to the [specification](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md).

For Option 2, you can: 

1. On your laptop clone the build client scripts for example (or from your fork):

2. **git clone https://github.com/agile-deployer/agile-infrastructure-build-client-scripts.git**

3. **cd agile-infrastructure-build-client-scripts**

4. **/bin/sh ./helperscripts/GenerateOverrideTemplate.sh** and answer the questions as it asks them

5. **/bin/sh ./helperscripts/GenerateHardcoreUserDataScript.sh** and answer the questions as it asks them

6. **cd ${BUILD_HOME}/userdatascripts** and copy the script that has been generated and post it into the user-data of a new VPS machine. 
