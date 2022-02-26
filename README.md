# README #

##### ASSOCIATED WEBSITE: [Code Breakers](https://www.codebreakers.uk)

#### OVERVIEW:

To provide a way of deploying server systems using nothing but parameterised scripting, from scratch, in such a way that a customer can either use the servers for development or production whilst retaining full access to and control of their server systems. As it goes, this is a simple solution meaning it doesn't use anything fancy, just linux shell scripting. 

----------------------------

#### INTRODUCTION

I've developed a unique deployment solution for use when deploying some of the major CMS systems including Joomla and Wordpress. The objective is to be able to deploy large scale social networks or other application types in a consistent and repeatable way. The major innovation is to have a kind of "JAD" (Joomla Applications Directory) as well as "JED" (Joomla Extension Directory). In other words, whole applications meeting particular busines needs, can be developed and baselined by the very best developers and "taken off the shelf" as whole, ready to use applications, by third party "application deployers" so that an application deployer can have a prepackaged application immediately ready for use out of the box. My core idea is to set up a directory (with reviews and so on) of "off the shelf" applications ready to be used (and possibly paid for) by customers. The toolkit itself will take a little bit of time investment by application deloyers, but, with a little bit of effort its a tameable beast and repeatable and consistent processes can be developed for application deployments. You know how they used to have "plug and play" devices, I am kind of trying to get to "deploy and play applications". Where it could be a boon for CMS extension developers would be if a provider could get their extensions built into a popular baselined application then, they could increase their userbase that way. This is in beta until I get more feedback from other developers about any issues. You could call what I have built here a DMS, or a "Deployment Management System". I avoid the repeated work of server configuration and at the same time retain full control over my deployed environment. This solution is extensible and reusable meaning developers can easily extend (and share their work) for their use cases. As examples of how it is extensible, if you wanted to extend the toolkit to support another cloudhost, for example, Rackspace or Google Cloud, you are free to do that in a manner which is easy to follow. The scripts can look quite involved at their core, but, you shouldn't need to touch any of that and the parts of the code you need to work with to extend the codebase are abstracted out and simple. As I mentioned, this toolkit will require a time investment to get the full benefits of it. Its like a CMS system in that you have to learn the CMS but once you do you have a power-tool to build highly complex websites and from there-on in you are quids in. Also, I am not an expert in all areas of server deployment, for example, I don't know the intricacies of APACHE or NGINX so I am hoping for what I have done to be reviewed by those who are to help make it as good as it can be.

--------------------

#### FINANCES

Always take close note of how any particular configuration you are deploying with this toolkit is being billed by your provider(s) so that you don't get any unexpected costs. For example, some provider's bill for data out (to, for example, GitHub when webroot sourcecode is being updated which happens regularly by default) and some providers don't. So, in such a circumstance there will be a different cost profile for different providers. In short keep an eye on your costs when you first make a deployment until it is clear to you how that particular deployment will be billed.  

-----------------------------------

#### FEEDBACK

If you find any issues with this toolkit, please open an issue under "issues" on this repository (as the lead repository of this toolkit) and I would be keen to investigate as there's quite a broad set of test cases for this toolkit. 

------------------------------------

#### GETTING STARTED

Detailed tutorials for this toolkit arranged by provider are available [here](https://www.codebreakers.uk/tutorials)

------------------------

#### THE CORE:

With the core of the Agile Deployment Toolkit, it will make use of a set of services and providers. I elected to use Digital Ocean, Exoscale, Linode, Vultr and AWS to deploy on or as deployment options, but, the toolkit is designed to be forked and extended to support other providers. The system is fully configurable by you and if you wish to change default configurations that are provided for, for example, Apache, NGINX or MariaDB, then you will need to fork the respoitories, alter your copy of the scripts and have them deploy according to your configuration requirements. A useful thing to be aware of if you are changing these scripts is you can check them syntactically with using "**/bin/sed -n <script.sh>**" before you redeploy only to find you had a syntax error during deployment. 

The full set of services that are supported by the core of the toolkit and which you can extend in your forks is:

1. For VPS services, one of - Digital Ocean, Linode, Exoscale, Vultr, AWS
2. For Email services, one of - Amazon SES, Mailjet or Sendpulse
3. For Git based services, one of - Bitbucket, Github or Gitlab
4. For DNS services, one of - Cloudflare, Digital Ocean, Exoscale, Linode, Vultr (note, Cloudflare has additional security features which are absent from naked dns services which is why it is probably best practice to use Cloudflare even if there is some extra hassle to set it up which you can find out about here: [Cloudflare DNS](https://community.cloudflare.com/t/step-1-adding-your-domain-to-cloudflare/64309)
5. For object store services, one of - Digital Ocean Spaces, Exoscale Object Store, Linode Object Store, Vultr Object Store or Amazon S3
6. These providers AWS, Exoscale and Digital Ocean currently support managed DB systems but other providers are projected to make offerings of managed DB solutions as well in the near future. If you can't use a managed database solution with your chosen provider, you might want to look into "Several Nines" which supports (for example, Vultr and Linode). I haven't tried "Several Nines", but, if you try it and it works OK, I would like to hear about it.

--------------------------------

#### BUILD METHODS OVERVIEW

There are three types of build method you can employ to get a functioning application. These are the hardcore build, the expedited build and the full build. There's pluses and minuses to all of them. The quick build and the expedited build you need to understand how the toolkit is working by studying the spec to find out what each parameter of your startup script is doing and making direct template modifications. The Expedited build shortcuts the full build process such that you have to deploy (and secure) a build machine VPS and then, clone the toolkit and provide a limited set of parameters to the **ExpeditedAgileDeploymenToolkit.sh** script. The final way is the full build where you will need to understand the toolkit the least but it means that you will be prompted for every parameter that the toolkit needs. For me I tend to use the expedited method, but to begin with you **might** want to fire up (and secure) a dedicated build machine with your VPS provider and run the full build with an eye to the [specification](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md) of course. 

You need a dedicated build machine in the cloud **DO NOT DEPLOY THIS ON YOU DAY TO DAY LAPTOP AS IT WILL MAKE CHANGES TO THE MACHINES CONFIGURATION** which you might not want.  If you don't want to pay for a dedicated build machine in the cloud, you could setup a dedicated USB image of Ubuntu or Debian which has persistent storage and use your local machine for running your builds directly from the usb stick. It is advised that you use an OS image dedicated for this process. 
I personally use MX Linux https://mxlinux.org/ if I want to run my build processes from a USB on my local laptop. 

There are four repositories associated with this toolkit, this one, and the one's listed below. These repos are private, but, will be made public. Whilst they are private, you will need to request read access to the   

##### [Agile Infrastructure Autoscaler Scripts](https://github.com/agile-deployer/agile-infrastructure-autoscaler-scripts)  
##### [Agile Infrastructure Webserver Scripts](https://github.com/agile-deployer/agile-infrastructure-webserver-scripts)
##### [Agile Infrastructure Database Scripts](https://github.com/agile-deployer/agile-infrastructure-database-scripts) 

Edit: (They have now been made public, obviously)

-----

#### THE CONCLUSION

The idea is for people who want a CMS application or a website of some sort, their systems usually have basically the same requirements, a database, a webserver, loadbalacing of some sort and enough disk space for the assets to be stored for their application. I use the DNS systems to facilitate load balancing between the webservers which they do in a round robin fashion. I structured the scripts in such a way that they are easy to maintain and extend and that's part of what this is about. Providing a deployment framework which automates a lot of the grunt work and still gives the deployer full access to customise their servers. You don't have to learn anything except how to run the scripts so it has a lower experience threshold than some other automated solutions. At the same time, you can get in there and easily tune your servers exactly as you want them. 

That's a mile high view. I should say that I would consider this to be beta because there's a proliferation of test scenarios depending upon what combination of software you are testing for. There's lots of different combinations lets say and whilst I have done my best I would be grateful for any feedback regarding any unnoticed configuration anomalies. 
