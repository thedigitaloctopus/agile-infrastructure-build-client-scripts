## CONFIGURING YOUR BUILD MACHINE

The authentication process for the Agile Deployment Toolkit works as follows. You can use the templare override script to get your machine up.   

So, I will make it clear by using the template override script as an example for how to authenticate to your servers and build machine.  


-------------------------
### ESSENTIAL  

The very first thing that you must do is to make a copy of the template override script on your laptop. You can do this either by cloning the repository fully and editing it in place or simply copy and paste the script to your laptop and edit your copy. The template override script id found here:

[OverrideScript](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/OverrideScript.sh)

In your copy, then, change the values of the  

##### BUILDMACHINE_USER  
##### BUILDMACHINE_PASSWORD  
##### BUILDMACHINE_SSH_PORT  
##### LAPTOP_IP
##### SSH (the public key part of an asymmetric key pair that are available on your laptop)

which you are going to populate and pass to your build machines userdata or init script depending on your providers nomenclature. 

-------------------------

With that done, here is a more detailed review of the protocol for authentication and interaction to the servers that this build kit will build for you:  

1. Change the variables above to suit you in your template override script (make sure you paste an up to date ssh public key into the first variable (export SSH="") as well).  

2. Paste the whole of your fully populated template override script into the user data of a VPS machine that you have provisioned with your provider and spin it up.  
3. After a couple of minutes, you will be able to SSH onto your build machine using a command such as:  

**ssh -p 1035 agile-deployer@<ip-address-of-build-machine>**

   You won't be able to authenticate using password based authentication, it will have to be public/private key pairs.  
	
4. Once you are onto your build machine, you will be logged in as agile-deployer. To access your scripts you will need to be root, so, you need to **"sudo su"** and enter the **BUILDMACHINE_PASSWORD**  

5. You will then be root  

6. **cd /home/${BUILDMACHINE_USER}/agile-deployment**. If you are using a hardcore build, your build process will be proceeding automatically, if you are using an expedited build, you will need to run **ExpeditedAgileDeploymentToolkit.sh** and if you are running a full build, you need to run **AgileDeploymentToolkit.sh**

7. When you do an /bin/ls from here, you will see a directory helperscripts which you can cd into  

8. Assuming that the build process has completed correctly which you can find out by looking in ${BUILD_HOME}/logs, you can then use the helperscripts to ssh onto the server machines. The scripts are:  
	
	**ConnectToAutoscaler.sh**
	**ConnectToWebserver.sh**
	**ConnectToDatabase.sh**
	
if you run these scripts they will try to connect to whichever type of machine it is written for.  

9. If you look into what your helperscript is doing, you will see it is connecting with a reasonably complex user name. This is effectively your root user and should be treated as such. Standard root logins are disabled and you have to connect with this user, so, this username and its SSH key pair MUST be kept secure to keep your server machines safe. Once you are onto your webserver, for example, you can go to  

	**${HOME}/.ssh** and find a script **"Super.sh"**. If you run this script, **"/bin/sh Super.sh"**  
	
it will switch you to the root user. By using this technique it helps because the username (if you keep it secure) for your servers is not well known, whereas if you have the username as root, it is well known. A username which is not well known is another factor which an assailant will need to know to break into your server estate.

**NOTE: You should be able to see how essential it is to keep the username and private key used by your helperscripts when they connect to your server secure. Those values are essetially root access to your servers with which an assailant can do anything he likes with your setup.**
