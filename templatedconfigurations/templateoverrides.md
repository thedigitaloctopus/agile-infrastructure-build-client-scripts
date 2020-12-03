# Digital Ocean

To use template overrides with digital ocean you need to:

1. Take a copy of [Override Script](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/digitalocean/OverrideScript.sh)
2. In your text editor populate the enironment variables in your copy. Override any additional template variables for the template you select from : [Templates](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templates/digitalocean) by adding them to your copy and pay attention to the template specification [Template Specification](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md)
3. Go through the process of starting up a (small) droplet, add your SSH key to it and paste your script from 2 in full into the "user data" area of your droplet creation process
4. Allow the droplet to start and then SSH onto the droplet
5. Go to /root/agile-infrastructure-build-client-scripts/logs and tail the logs to see how the build is progressing. 
6. After some minutes, you website should be online.

--------------------------------------------------------------

# Exoscale

1. Take a copy of [Override Script](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/exoscale/OverrideScript.sh)
2. In your text editor populate the enironment variables in your copy. Override any additional template variables (you can choose one of the templates located at: [Templates](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templates/exoscale) by adding them to your copy and pay attention to the template specification [Template Specification](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md)
3. Go through the process of starting up a (small) Compute instance in your chosen region, add your SSH key to it and add your script from 2 to the machine's "user data"
4. Allow the compute instance to start and then SSH onto it (presuming you added your SSH public key to it)
5. Go to /root/agile-infrastructure-build-client-scripts/logs and tail the logs to see how the build is progressing. 
6. After some minutes, you website should be online.

--------------------------------------------------------------

# Linode

You can find more explicit instructions for linode here: [Linode Explicit](https://www.codeshed.uk/home/agile-deployment-toolkit/demonstrations/template-override-method-demo/explicit-instructions-linode)
1. Make a stack script by copying: https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/linode/OverrideScript.sh
2. Populate the Stack Script with values according to the [template spec](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md) and your needs. You can override any variables from the template you select from [Templates](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templates/linode) as you choose in your Stack Script. 
3. Start up a linode using your Populated Stack Script
4. Allow the linode to start up and then SSH onto it
5. Go to /root/agile-infrastructure-build-client-scripts/logs and tail the logs to see how the build is going
6. After some minutes, if there are no problems your website should be online. 

---------------------

# Vultr

1. Take a copy of [Override Script](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/exoscale/OverrideScript.sh)
2. In your text editor populate the enironment variables in your copy. Override any additional variables in the template you select from: [Templates](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templates/vultr) by adding them to your copy and pay attention to the template specification [Template Specification](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md)
3. Go through the process of starting up a (small) Compute instance in your chosen region, add your SSH key to it and add your script from 2 to the machine as you define its configuration
4. Allow the compute instance to start and then SSH onto it (presuming you added your SSH public key to it)
5. Go to /root/agile-infrastructure-build-client-scripts/logs and tail the logs to see how the build is progressing. 
6. After some minutes, you website should be online.

--------------------------

# AWS

1. Take a copy of [Override Script](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/aws/OverrideScript.sh)
2. In your text editor populate the enironment variables in your copy. Override any additional variables that you want to from the template you select from: [Templates](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templates/aws) by adding them to your copy and pay attention to the template specification [Template Specification](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md)
3. Go through the process of starting up a (small) EC2 Compute instance in your chosen region, add your SSH key to it and add your script from 2 to its userdata area at the bottom of the "Advanced Details" area of the "Configure instance" tab
4. Allow the compute instance to start and then SSH onto it (presuming you added your SSH public key to it)
5. Go to /root/agile-infrastructure-build-client-scripts/logs and tail the logs to see how the build is progressing. 
6. After some minutes, you website should be online.

