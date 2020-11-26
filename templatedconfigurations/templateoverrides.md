# Digital Ocean

To use template overrides with digital ocean you need to:

1. Take a copy of https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/digitalocean/OverrideScript.sh
2. In your text editor populate the enironment variables in your copy. Override any additional variables that you want to by adding them to your copy and pay attention to the template specification https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md
3. Go through the process of starting up a (small) droplet, add your SSH key to it and paste your script from 2 in full into the "user data" area of your droplet creation process
4. Allow the droplet to build and then SSH onto the droplet
5. Go to /root/agile-infrastructure-build-clientscripts/logs and tail the logs to see how the build is progressing. 
6. After some minutes, you website should be online.

--------------------------------------------------------------
