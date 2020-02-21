1) Let's imagine this is your first time using the Agile Deployment Toolkit. What should you do, how should you start.

Assuming that you have deployed a ubuntu or a debian instance in the cloud, you can then start to runt he build process. Of course, you don't have to run it on a cloud server, the scripts will only run on ubuntu or debian, not windows, so, you could use a usb to create an installation of a debian or ubuntu os and run this script from your latop rather than a cloud server. At the end of the day, the scripts run with sudo privileges so, just because of that alone, I know its lazy, it needs to be a dedicated machine that you use for your build processes. 
So,
a) You can install ubuntu on a USB and boot your desktop computer using that or 

b) You can spin up an Ubuntu or debian server on some cloud provider of your choice and you can access it using an ssh client like putty and use that as your 'build' machine.

NOTE: if you use putty, you will need to set the "Seconds between keep alives" to some value, such as 200. A value of 0 will not work.

In the first case, if you are windows guy, you can use a tool like Universal USB Installer. You can find it here:

https://www.pendrivelinux.com/universal-usb-installer-easy-as-1-2-3/

In the 2nd case, you can choose a cloud provider, perhaps Digital Ocean, Linode, Exoscale and so on. Having signed up for an account, you can set up a standard installation of ubuntu on the machine and you can access your build machine through an appropriate ssh client. Please ensure that if you use a server in the cloud as your build machine that it is fully and properly secured as it will contain sensitive information relating to the build process such as passwords and ssh keys. 

2) OK, so you are ubuntued and ready, what next. The next thing you need to do is make sure you have read access to the repositories that contain the source scripts for the agile deployment toolkit. These are stored in bitbucket private repositories and this won't change, unless something happens to bitbucket, of course. So, to get the repositories, you need to join bitbucket (www.github.com) and request read access to the following repositories. These may become public repositories in the furture.

Agile Infrastructure Autoscaler Scripts (private)
Agile Infrastructure Webserver Scripts (private)
Agile Infrastructure Build Client (public)
Agile Infrastructure Database Scripts (private)

3) You can then issue the following commands to perform the build process:

if git is not installed type

apt-get install git

then
***this may change depending upon which repository provider the sourcecode is with, for example, bitbucket***
git clone https://agile-deployer@github.com/agile-deployer/agile-infrastructure-build-client.git

This will grab the source code for the build client for you. Once you have the source code, you can go to ${BUILD_HOME} and issue the command

/bin/sh ${BUILD_HOME}/AgileDeploymentToolkit.sh

You then have to wait some minutes and you should get a message saying that the build is complete and you can navigate to your site.

I will then point you in the direction of the explaination:

${BUILD_HOME}/doco/AgileToolkitDeployment/DeploymentOptions.txt which will take you through each of the different options that the script will present to you.

You will need to have the following services available when the script asks for them, in other words you must have an active account with providers of

1) Cloud Services (eg. digital ocean, exoscale, linode or vultr)
2) Datastore Services (Amazon S3, Digital Ocean Spaces, Exoscale Object Store)
3) Git Services for your application (GitHub, Bitbucket, GitLab)
4) Email Services (google mail, Send Pulse, Amazon SES)

It is expected that the list of available services providers will increase with subsequent releases, giving more choice to you.

4) Once your deployment is complete (or whilst it is building) you need to setup the email addresses for your administration team.

You could use a provider such as zoho.eu to register your domain with and give people email addresses specific to your domain, but, this is a paid service.
You might alternatively prefer to roll your own email solution using a toolkit like iredmail which requires more work, but, not more money. 
