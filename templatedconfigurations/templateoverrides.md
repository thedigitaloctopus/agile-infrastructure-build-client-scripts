# Digital Ocean

To use template overrides with digital ocean you need to:

1. Take a copy of [Override Script](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/digitalocean/OverrideScript.sh)
2. In your text editor populate the enironment variables in your copy. Override any additional variables that you want to by adding them to your copy and pay attention to the template specification [Template Specification](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md)
3. Go through the process of starting up a (small) droplet, add your SSH key to it and paste your script from 2 in full into the "user data" area of your droplet creation process
4. Allow the droplet to build and then SSH onto the droplet
5. Go to /root/agile-infrastructure-build-client-scripts/logs and tail the logs to see how the build is progressing. 
6. After some minutes, you website should be online.

--------------------------------------------------------------

# Exoscale


--------------------------------------------------------------

# Linode

1. The default Stack Script is available on Linode
2. Populate the Stack Script with values according to the [template spec](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md) and your needs
3. Start up a linode using your Populated Stack Script
4. Allow the linode to start up and then SSH onto it
5. Go to /root/agile-infrastructure-build-client-scripts/logs and tail the logs to see how the build is going
6. After some minutes, if there are no problems your website should be online. 
