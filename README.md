# README #

### INTRODUCTION

##### ASSOCIATED WEBSITE: [Code Breakers](www.codebreakers.uk)

This toolkit automates the deployment of LEMP/LAMP stacks with built in scalability for various CMS systems (currently Wordpress, Joomla, Moodle, Drupal) starting with nothing and building out from there. This is close to being a PAAS solution meaning that purely through parameter configuration, you can have a fully deployed application infrastructure that can scale with consistent security practices built in. A disadvantage of fully PAAS solutions is a lack of operational control and features. Using this solution, you have, what is effectively a PAAS solution but, with total control of your servers and databases if you choose to have or need to have. For my needs this was the best of both worlds because through automation, I avoid the repeated work of server configuration and at the same time retain full control over my deployed environment. This solution is extensible and reusable meaning developers can easily extend (and share their work) for their use cases. As examples of how it is extensible, if you wanted to extend the toolkit to support another cloudhost, for example, Rackspace or Google Cloud, you are free to do that in a manner which is easy to follow. The scripts can look quite involved at their core, but, you shouldn't need to touch any of that and the parts of the code you need to work with are abstracted out. Clearly, there's a plethora of deploymemt options out there if you want a CMS system, and, this is another one. It should fit you well if you want full access to the Linux VPS systems that your application is running on and if you don't want to necessarily be bothered with manual software installs and configurations. That said, anyone who wants to learn about server configuration could deploy (and study/modify) the way these servers work and so might be useful to students. An advantage of this approach is that it can have strong and consistent security practices baked in. There's many combinations of test scenarios with this software. I am one developer, I have tested it as well as I can, but, will have to rely on feedback. If you find any problems please report them using the forum on www.codebreakers.uk, thanks in advance. The aim of this toolkit it to provide a consistent way to deploy the same customised CMS application multiple times for example to town A, town B and so on. The exact same process (although with possibly a different configuration) should be used to deploy for town B as it is for town A.

-----------------------

### CORE OBJECTIVE:

To provide a way of deploying server systems using nothing but parameterised scripting, from scratch, in such a way that a customer can either use the servers for development or production whilst retaining full access to their server systems and in particular anybody wanting to learn how to deploy CMS systems on VPS server machines can have a sample configuration to work with. 

------------------------

### THE CORE:

With the core of the Agile Deployment Toolkit, it will make use of a set of services and providers. I elected to use Digital Ocean, Exoscale, Linode, Vultr and AWS to deploy on or as deployment options, but, the toolkit can be forked and extended to support other providers also, such as say Google Cloud or Rackspace. The system is fully configurable by you and if you wish to change default configurations for, for example, Apache, NGINX or MariaDB, then you will need to fork the respoitories, alter your copy of the scripts and have them deploy according to your configuration requirements. A useful thing to be aware of if you are changing these scripts is you can check them syntactically with using "/bin/sed -n <script.sh>" before you redeploy only to find you had a syntax error during deployment. 

The full set of services that are supported by the core of the toolkit and which you can extend in your forks is:

1. For VPS services, one of - Digital Ocean, Linode, Exoscale, Vultr, AWS
2. For Email services, one of - Amazon SES, Gmail or Sendpulse
3. For Git based services, one of - Bitbucket, Github or Gitlab
4. For DNS services, one of - Cloudflare, Digital Ocean, Exoscale, Linode, Vult, or AWS Route 53 (note, Cloudflare has additional security features which are absent from naked dns services which is why it is probably best practice to use CLoudflare even if there is some extra hassle to set it up which you can find out about here: [Cloudflare DNS](https://community.cloudflare.com/t/step-1-adding-your-domain-to-cloudflare/64309)
5. For object store services, one of - Digital Ocean Spaces, Exoscale Object Store, Linode Object Store, Vultr Object Store or Amazon S3
6. These providers AWS, Exoscale and Digital Ocean currently support managed DB systems but other providers are projected to make offerings of managed DB solutions as well in the near future. If you can't use a managed database solution with your chosen provider, you might want to look into "Several Nines" which supports (for example, Vultr and Linode). I haven't tried "Several Nines", but, if you try it and it works OK, I would like to hear about it.


------------------------------

### ULTIMATE MOTIVATION

My ultimate motivation is to have developers "develop" applications as a kind of extenstion to this toolkit in the same way that, for example, people who use Joomla develop extensions for Joomla. My ultimate aim is to be able to have multiple deployers point this toolkit at a public - (beware of sensitive credentials if you make your application baseline public) full featured and functional CMS application codebase and have this toolkit deploy that application into the live repeatedly (for different domain names and customers) without having to do anything other than alter the configuration parameters for these scripts (and of course setting up accounts with a VPS provider and so on). In this way, a consistent way of deploying a baselined application (you can find out more about how to create a baselined application in the tutorials and/or documentation) multiple times. In other words, there is intended to be a (full featured) applications directory in the same way as in, Wordpress or Joomla you have a plugins or an extensions directory. Ultimate ultimate aim would be to have a library of applications of various function which can be reviewed and described such that someone new to the toolkit could come along and have, for example, a fully functioing social network (developed by someone else and reviewed and tested) up and running within 10s of minutes. Having full featured reusable application deployment like this would be an accelerator and because there is no lock in, for example, you are not tied to "Vendor B's social networking service" to run your application on, you can take your application codebase away with you and deploy it somewhere else. That's the value add which I am aiming for by developing this toolkit. 

--------------------------------

### BUILD METHODS

There are three types of build method you can employ to get a functioning application. These are the quick (hardcore) build, the expedited build and the full build. There's pluses and minuses to all of them. The Quick build you need to understand how the toolkit is working by studying the spec to find out what each parameter of your startup script is doing. The Expedited build shortcuts the full build process such that you have to deploy (and secure) a build machine VPS **NEVER DEPLOY THIS TOOLKIT ON YOUR OWN DAY TO DAY LAPTOP RUNNING LINUX AS IT WILL MAKE CHANGES TO YOUR GLOBAL CONFIGURATION SETTINGS AND INSTALL SOFTWARE YOU MIGHT NOT WANT OTHERWISE** and then, clone the toolkit and provide a limited set of parameters to the ExpeditedAgileDeploymenToolkit.sh script. The final way is the full build where you will need to understand the toolkit the least but it means that you will be prompted for every parameter that the toolkit needs. For me I tend to use the hardcore method, but to begin with you might want to fire up (and secure) a dedicated build machine with your VPS provider and run the full build with an eye to the [specification](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md) of course. 

#### QUICK START

To get started as quickly as possible before going into more depth, you can use one of these methods: [Template Overrides](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides.md)


#### THE EXPEDITED BUILD

##### YOU MUST USE A DEDICATED BUILD MACHINE 

If you feel confident with what is needed you can run the Expedited Build Process on your build machine. This can be done by running this script:  

##### ${BUILD_HOME}/ExpeditedAgileDeploymentToolkit.sh

and following the same process as the full build documented below:

#### THE FULL BUILD

##### YOU MUST USE A DEDICATED BUILD MACHINE 

AGAIN, IMPORTANT: you must use a dedicated linux machine for your build processes as the build will add and remove software which you may not want to happen if you are using your linux machine for other purposes.  

So, to run this toolkit kit, you need a vanilla (but secured) Ubuntu server 20.04 or later or a (vanilla but secured) debian 10 server or up. 
Maybe more flavours of linux will be supported later but at the moment it is just Debian and Ubuntu. So, spin up a vanilla instance of Ubuntu or Debian with your favourite cloudhost and then, having made sure it is secure, ssh onto it (if you are on windows, using putty - making sure putty is not set to drop long lasting connections) and start the build process for your deployment.  

If you don't want to pay for a dedicated build machine in the cloud, you could setup a dedicated USB image of Ubuntu or Debian which has persistent storage and use your local machine for running your builds directly from the usb stick. It is advised that you use an OS image dedicated for this process. 
I personally use MX Linux https://mxlinux.org/ if I want to run my build processes from a USB on my local laptop. 

You need to clone this toolkit kit onto your new build machine which is most likely on the same cloud provider as you will be depolying your webservers to.  

Then you can start the process by running:

##### ${BUILD_HOME}/AgileDeploymentToolkit.sh 

Where ${BUILD_HOME} is the directory where you placed the build scripts.  

Because you have a dedicated 'build machine' in the cloud which doesn't have any other purpose, you can run this build script as root on that machine. I know it's lazy like that, but, by having a dedicated machine it makes it OK.  

The build process is guided and it is essential to put in sane information when prompted for it to succeed. The build scripts do as much checking for erroneous inputs as they can, but not everything can be checked and validated and erroneous inputs will have unexpected behaviours downstream in the build process. The build script will deploy various server types to your selected cloudhost and when completed, you will be able to navigate to you application through your browser.  

Currently, these repos are private, but, will be made public. Whilst they are private, you will need to request read access to the   

##### Agile Infrastructure Webserver Scripts,  
##### Agile Infrastructure Autoscaler Scripts,  
##### Agile Infrastructure Database Scripts  

Edit: (They have now been made public)

Here are two instructional or demo videos for how to set up your build server and how to run an example build process. I think you will definitely want to watch these videos before you run a build of your own.  

[Agile Deployment Toolkit Build Machine Setup Example](https://www.youtube.com/watch?v=ONp_QuPxcsc)  

[Sample Build Process Agile Deployment Toolkit](https://www.youtube.com/watch?v=mXpIRB_7O_M&t=80s)  

-----

### THE CONCLUSION

The idea is for people who want a CMS application or a website of some sort, their systems usually have basically the same requirements, a database, a webserver, loadbalacing and enough disk space for the assets to be stored for their application. I use the DNS systems to facilitate load balancing between the webserves which they do in a round robin fashion. I structured the scripts in such a way that they are easy to maintain and extend and that's part of what this is about. Providing a deployment framework which automates a lot of the grunt work and still gives the deployer full access to customise their servers. You don't have to learn anything except how to run the scripts so it has a lower experience threshold than some other automated solutions. At the same time, you can get in there and easily tune your servers exactly as you want them. 

That's a mile high view. I should say that I would consider this to be beta because there's a proliferation of test scenarios depending upon what combination of software you are testing for. There's lots of different combinations lets say and whilst I have done my best I would be grateful for any feedback regarding any unnoticed configuration anomalies. 
