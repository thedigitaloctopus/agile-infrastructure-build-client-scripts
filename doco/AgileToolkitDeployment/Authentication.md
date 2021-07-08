#### AUTHENTICATION

The authentication process for the Agile Deployment Toolkit works as follows.  

First of all, there's one of two options, you will either be following a build process where you provision and secure your own build machine and use, for example, the AgileDeploymentToolkit.sh script to build your servers.  

Or, you might be using the template override script method in which case the script that you pass to the user data part of your build machine will define username password and port for your build client machine as well as the SSH public key. You can find the template override scripts here:  
  
https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/tree/master/templatedconfigurations/templateoverrides  

So, I will make it clear by using the template override script as an example for how to authenticate to your servers and build machine.  

### ESSENTIAL  

The very first thing that you must do is change the values of the  

##### BUILDCLIENT_USER  
##### BUILDCLIENT_PASSWORD  
##### BUILD_CLIENT_SSH_PORT  

in your template override script which you are going to populate and pass to your build machines userdata.  

Your build machine is secured using private keys but if you want access root on it, you will need your BUILDCLIENT_USER and BUILDCLIENT_PASSWORD when you issue the command "sudo su"  

These variables, therefore should not be well known and you need to set them in your template override script to values that suit you.  

### ESSENTIAL  

With that done, here is the protocol for authentication to the servers that this build kit will build for you:  

1. Change the three variables above to suit you in your template override script (make sure you paste an up to date ssh public key into the first variable (export SSH="") as well).  

2. Paste the whole of your fully populated template override script into the user data of a VPS machine that you have provisioned with your provider and spin it up.  

3. After a couple of minutes, you will be able to SSH onto your build machine using a command such as:   ssh -p 1035 agile-deployer@<ip-address-of-build-machine>  

   You won't be able to authenticate using password based authentication, it will have to be public/private key pairs.  
	
4. Once you are onto your build machine, you will be logged in as agile-deployer. To access your scripts you will need to be root, so, you need to "sudo su" and enter the BUILDCLIENT_PASSWORD  

5. You will then be root  

6. cd /home/${BUILDCLIENT_USER}/agile-deployment*  

7. When you do an /bin/ls from here, you will see a directory helperscripts which you can cd into  

8. Assuming that the build process has completed correctly which you can find out by looking in ${BUILD_HOME}/logs, you can then use the helperscripts to ssh onto the server machines. The scripts are: ConnectToAutoscaler.sh ConnectToWebserver.sh ConnectToDatabase.sh if you run these scripts they will try to connect to whichever type of machine it is written for.  

9. If you look into what your helperscript is doing, you will see it is connecting with a reasonably complex user name. This is effectively your root user and should be treated as such. Standard root logins are disabled and you have to connect with this user, so, this username and its SSH key pair MUST be kept secure to keep your server machines safe. Once you are onto your webserver, for example, you can goto ${HOME}/.ssh and find a script "Super.sh". If you run this script, "/bin/sh Super.sh" it will switch you to the root user. By using this technique it helps because the username (if you keep it secure) for your servers is not well known, whereas if you have the username as root, it is well known. A username which is not well known is another factor which an assailant will need to know to break into your server estate.

NOTE: You should be able to see how essential it is to keep the username and private key used by your helperscripts when they connect to your server secure. Those values are essetially root access to your servers with which an assailant can do anything he likes with your setup.
