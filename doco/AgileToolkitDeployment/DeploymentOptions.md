##### THIS INFORMATION IS OUT OF DATE, IT'S SOMETHING I RECORDED/WROTE DURING THE DEVELOPMENT PROCESS WHICH MAY STILL BE USEFUL TO LOOK 
##### THROUGH IF YOU ARE UNSURE


Here I will go through how to deploy the toolkit and also the options you can select and what they mean.
This is out of date in the sense that the scripts have changed since I generated this output, but it will give you a general
flavour of how to make a deployment.

The first thing is you need to work out what provider accounts you need to have set up. 

You need a cloudhost, a DNS provider, a git repository provider, a datastore provider

You need to choose one of each of the following:

1) So, your current choices are Cloudhost: Digital Ocean, Exoscale, Linode, Vultr
2) DNS provider: Cloudflare, Rackspace
3) Git repository provider: bitbucket, github, gitlab
4) A datastore provider currently: amazon s3, digital ocean spaces and exoscale object storage

You will have to follow the documentation for each provider on how to set up and secure an account with them
More providers will eventually be added in the future. It is basically unlimited how many different provders
can be supported as long as they provider a public api and so on so if you have a favourite provider why not
look in the code and implement support for it if it is not in the supported set you see here.

First of all cd to ${BUILD_HOME}

then you can run the Agile Deployment Script. You do this as follows

/bin/sh AgileDeploymentScript.sh

Here, then are the messages and options which you are then presented with:

1) Hi Mate and welcome. First of all let's figure out what timezone you are in
Please type in one of the following to make a selection:
Africa America Antarctica Arctic Asia Atlantic Australia Europe Indian Pacific UTC

So, you just type in the continent where your are located, so, for example, 

Europe

2) OK, now let's figure out what city you are in...
Press the <enter> key to continue>

3) You then get a whole list of cities. Scan the list and find the city nearest to where you are. 

4) 
##################################################################################################
#####PLEASE ENTER A UNIQUE BUILD IDENTIFIER FOR THIS BUILD                                   #####
#####SO THAT THE UNIQUE CONFIGURATION SETTINGS CAN BE STORED                                 #####
##################################################################################################
Enter Build Identifier please:

So, here, you enter a unique identifier for your build. You won't be able to have another unique build with the same 
identifier, basically.

So, for example, you might enter:

testbuild1

5) Which version of GNU/linux are you running this build script on?
Currently we support 1)Ubuntu (and derivatives)
Please enter the number of the style of GNU/linux you are running

Enter 1 for ubuntu

1

6) 
##################################################################################################
#####PLEASE SELECT YOUR CLOUDHOSTING PROVIDER.                                               #####
#####CURRENTLY, WE SUPPORT 1) DIGITAL OCEAN www.digitalocean.com                             #####
#####                      2) EXOSCALE      www.exoscale.ch                                  #####
#####                      3) LINODE        www.linode.com                                   #####
#####                      4) VULTR         www.vultr.com                                   #####
##################################################################################################
Enter 1: for Digital Ocean 2: For Exoscale 3: for Linode 4: for Vultr

Select which of the supported cloudhosts you are deploying to, so, for example, if it is linode, type

3

7)
The steps for each provider might vary slightly, but should be obvious in this case, here are the steps for linode

#####################################################################################################
##### This provider requires a root password to your account to be able to proceed. This will   #####
##### only be used during the build process and then set inactive. SSH keys will then be used   #####
#####################################################################################################
Linode root Password (at least 8 characters):

So, just enter and remember a password. This is mostly for use through the LISH console in case of emergency
and is disabled during normal operation

s7jd8r"ydonh

8) Basically, the toolkit is set up to be configured to support various custom application types. So, it is 
necessary to select the type of application you are installing. The type of application that you select here
will determine the customisations which are applied later on in the build process.

##################################################################################################
# We have some preconfigured applications which you may wish to deploy. If so, please select one #
# You can add your own custom built applications here as you require                             #
##################################################################################################
The currently installed applications are 0) None and 1) Basic Social Network
Please enter 0: to not install an application (This should be the case if you are installing a virgin copy of an Application
or 1: a basic social network (repository provider Bitbucket, repositories 'socialnet-webroot-sourcecode-baseline' and 'socialnet-db-baseline')

So, we are installing the basic social network application so, enter 1

1

9) What language is the application written in? Currently we support:
1) Just HTML/JAVASCRIPT 2) PHP
Please enter 1) or 2) to select

This is a PHP application so, we need to select 2. In the future we may support Java and so on and if you are
simpy deploying some HTML code, then you don't need to install PHP. In this case, then, enter:

2

10) 
##################################################################################################
#####PLEASE ENTER A DISPLAY NAME FOR YOUR APPLICATION/WEBSITE                                #####
#####For example: \'Local Volunteers\'                                                       #####
##################################################################################################
Enter Display Name:

The Marionettes

11) 
##################################################################################################
#####PLEASE ENTER FULL URL (including subdomain) FOR YOUR WEBSITE                            #####
#####For example: www.mycommunity.org.uk                                                     #####
##################################################################################################
Enter Website URL:
slough.marionettes.community

12) 
#####################################################################################################
#####WHICH IN-MEMORY CACHE WOULD YOU LIKE TO DEPLOY WITH YOUR APPLICATION/WEBSITE?              #####
#####WE CURRENTLY SUPPORT 0: None (filesystem caching) 1: Redis 2: Memcached 3) apcu            #####
#####################################################################################################
PLEASE MAKE YOU CHOICE FOR IN-MEMORY CACHING(0|1|2|3)

Select the type of caching you want to be deployed for selection within you application, if any.
In this case, we will deploy redis, so enter 

1

13) 
#####################################################################################################
#####WHICH WEBSERVER WOULD YOU LIKE TO DEPLOY TO?                                               #####
#####WE CURRENTLY SUPPORT 1: Nginx 2: Apache 3: Lighttpd                                        #####
#####################################################################################################

Select which webserver you are deploying to:

1

14) 
#####################################################################################################
#####WHICH WEB DNS PROVIDERTECHNOLOGY WOULD YOU LIKE TO USE?                                    #####
#####WE CURRENTLY SUPPORT 1: Cloudflare 2: Rackspace                                            #####
#####################################################################################################

Select which DNS Service you will be using

2

15) 
Please enter your Rackspace username
petercw123
We also need the API key for your rackspace account. You can either request this from the domain owner or if you are the domain owner
You can find it by authenticating to your rackspace account, clicking on your name at the top right and then clicking on 'Account Settings'
And you should find the API key there and copy and paste it below
Please input your rackspace API key
1hgd7ehdfh3738dhe73ndehyehwjru4jd
Please enter the three letter identifier for the region you wish to deploy to from the following list
Dallas - DFW, Chicago - ORD, Virginia IAD, London LON, Sydney SYD, Hong Kon HKG
LON
Plese input the username that you use for your git application repository
Peter Winter
Plese input the email that you use for your git application repository
thespecialglasses@yahoo.com

16) 
###############################################################################################################################
##### YOUR (OR ANOTHER PERSON'S) Application SOURCECODE NEEDS TO BE KEPT IN A REPOSITORY WHERE THE REPOSITORY             #####
##### NAME HAS THE FORMAT <UNIQUE_IDENTIFIER>-WEBROOT-SOURCECODE-BASELINE.  IF THIS IS THE CASE OR YOU HAVE               #####
##### ACCESS TO SOMEONE ELSE'S Application REPOSITORY, THEN PLEASE SELECT THE PROVIDER WHERE THIS REPOSITORY IS           #####
##### CUURENTLY WE SUPPORT BITBUCKET (www.bitbucket.org) GITHUB (www.github.org) and GITLAB (www.gitlab.com)              #####
##### IF YOU DON'T HAVE AN APPLICATION/WEBSITE TO DEPLOY FROM YOUR REPOSITORY YET, THEN YOU CAN FIND INFORMATION          #####
##### AT :                                                                                                                #####
##### /root/agile-infrastructure-build-client/DevelopmentEnvironent/HowToDevelopAndDeployAWebsite.txt				                 #####
##### IF YOU ARE DEPLOYING SOMEONE ELSE'S APPLICATION/WEBSITE, THEN YOU NEED TO MAKE SURE YOU HAVE READ ACCESS            #####
##### SO, PLEASE ENTER YOUR CHOICE OF REPOSITORY PROVIDER FOR YOUR Application                                            #####
###############################################################################################################################
1)BITBUCKET 2)GITHUB 3)GITLAB
PLEASE SELECT: (1|2|3)

1

17)
###########################################################################################################
##### YOU NEED TO KNOW THE USERNAME OF THE PERSON (PROBABLY YOU) WHO OWNS THE Application REPOSITORY  #####
##### FOR EXAMPLE, IF THE Application REPOSITORY IS HOSTED ON GITHUB, AND IS CALLED THESPECIALGLASSES #####
##### THEN, YOU NEED TO ENTER THE USERNAME OF THE PERSON WHO OWNS THE REPOSITORY HERE                 #####
##### SO, ON GITHUB, THE URL TO THE REPOSITORY WILL LOOK SOMETHING LIKE:                              #####
##### https://github.com/petercw123/thespecialglasses AND SO, THE USERNAME YOU WOULD ENTER HERE WOULD #####
##### BE: petercw123.                                                                                 #####
##### SO, PLEASE NAVIGATE TO THE REPOSITORY OF THE Application YOU WISH TO DEPLOY, FIND THE USERNAME  #####
##### AND ENTER IT HERE.                                                                              #####
###########################################################################################################
PLEASE ENTER THE OWNER OF YOUR Application IN bitbucket HERE:                #####
petercw

18) 
###############################################################################################################
##### NOW YOU NEED TO ENTER **YOUR** PERSONAL CREDENTIALS FOR bitbucket HERE:    #####
##### IF YOU AUTHENTICATE TO YOUR PROVIDER USING AN AUTHORISATION TOKEN, THEN PLEASE ENTER THE AUTH       #####
##### TOKEN AS THE PASSWORD. CHEERS                                                                             #####
###############################################################################################################
YOUR bitbucket USERNAME:
petercw
YOUR bitbucket PASSWORD:
123sdfxerf$5623

19) It is expected that the infrastructure will reside in bitbucket for the forseeable future, but in case of future
alterations, it is parameterised. So, enter the username of the infrastructure owner on bitbucket
The person who is the owner of the infrastructure will have to grant you read access to the infrastructure repositories

##################################################################################################################
##### PLEASE CHOOSE THE REPOSITORY PROVIDER WHERE THE INFRASTRUCTURE SYSTEM SCRIPTS ARE KEPT                 #####
##### CURRENTLY, THE SYSTEM SCRIPTS ARE KEPT IN BITBUCKET AND YOU WILL NEED TO REQUEST READ ACCESS TO THEM   #####
##### FROM THE OWNER. SO, SEARCH FOR THE FOLLOWING REPOSITORIES, CURRENTLY STORED AND LIKELY TO REMAIN STORED#####
##### ON BITBUCKET                                                                                           #####
##### Agile Infrastructure Database Scripts                                                              #####
##### Agile Infrastructure Webserver Scripts                                                             #####
##### Agile Infrastructure Autoscaler Scripts                                                            #####
##################################################################################################################
PLEASE CONFIRM THAT YOU HAVE FOUND AND HAVE READ ACCESS FROM YOUR ACCOUNT TO THESE 5 BITBUCKET REPOSITORIES  #####
PLEASE ENTER (y|Y) TO CONFIRM
Y

20)
##################################################################################################################
##### PLEASE ENTER THE USERNAME OF THE PERSON WHO OWNS THE DECOUPLED INFRASTRUCTURE REPOSITORIES             #####
##### IF THE URL TO THE REPOSITORY IS:                                                                       #####
##### https://bitbucket.org/metalhollic/agile-infrastructure-webserver-scripts                           #####
##### THEN THE USERNAME YOU WOULD WANT TO ENTER HERE WOULD BE metalhollic                                    #####
##### PLEASE ENTER THE USERNAME OF THE PERSON WHO OWNS THE INFRASTRUCTURE REPOSITORIES                       #####
##################################################################################################################
INFRASRUCTURE REPOSITORIES OWNER USERNAME:

infrastructureprovider

21) So, you will have to have a bitbucket account and enter the credentials of **your** bitbucket account
###############################################################################################################
##### PLEASE ENTER **YOUR** CREDENTIALS FOR THE DECOUPLED INFRASTRUCTURE REPOSITORY PROVIDER              #####
##### IF YOU AUTHENTICATE TO YOUR PROVIDER USING AN AUTHORISATION TOKEN, THEN PLEASE ENTER THE AUTH       #####
##### TOKEN AS THE PASSWORD. CHEERS (in most cases you can get your auth token from your provider dashboard####
###############################################################################################################
YOUR bitbucket USERNAME:
infrastructuredeveloper
YOUR bitbucket PASSWORD:
12Sd^7sd232"2

22) 
Would you like to install a database
Please enter (Y|y) to install a database
Y
Would you like to install a 1) single database instance?
Please Enter 1 or 2
1
Which database type would you like to install?
At the moment, we support 1) MYSQL (Maria DB) 2) PostgreSQ
1

23) 
################################################################################################################
##### WE NEED TO SELECT A REGION TO DEPLOY OUR INFRASTRUCTURE IN                                           #####
################################################################################################################
PLEASE SELECT FROM THE FOLLOWING LIST OF REGIONS TO DEPLOY. SELECT A REGION BY TYPING ITs SLUG
shinagawa1 atlanta dallas fremont newark london singapore tokyo frankfurt

london

24)
##################################################################################################################################
##### WE NEED TO SELECT A SIZE FOR THE MACHINES WHICH TO RUN OUR DATABASE SERVER (please be aware of cost of larger machines)#####
##################################################################################################################################
PLEASE SELECT FROM THE FOLLOWING LIST OF SIZES TO DEPLOY FOR YOUR DATABASE. SELECT A SIZE BY TYPING ITs SLUG
2048 4096 8192 12288 24576 49152 65536 81920 122880

2048

25)
###############################################################################################################################
##### WE NEED TO SELECT A SIZE FOR THE MACHINES WHICH TO RUN OUR WEBSERVER SERVER (please be aware of cost of larger machines)#####
###############################################################################################################################
PLEASE SELECT FROM THE FOLLOWING LIST OF SIZES TO DEPLOY FOR YOUR WEBSERVER. SELECT A SIZE BY TYPING ITs SLUG
2048 4096 8192 12288 24576 49152 65536 81920 122880


27)
########################################################################################################################################
##### WE NEED TO SELECT A SIZE MACHINES ON WHICH TO RUN OUR AUTOSCALER (please be aware of cost of larger machines)#####
########################################################################################################################################
PLEASE SELECT FROM THE FOLLOWING LIST OF SIZES TO DEPLOY FOR YOUR AUTOSCALER. SELECT A SIZE BY TYPING ITs SLUG
2048 4096 8192 12288 24576 49152 65536 81920 122880

2048

28)
########################################################################################################################################
##### WE NEED TO SELECT A SIZE MACHINES ON WHICH TO RUN OUR MAILSERVER (please be aware of cost of larger machines)#####
########################################################################################################################################
************************************************
* MAIL SERVER MUST HAVE AT LEAST 2gb OF MEMORY *
************************************************
2048 4096 8192 12288 24576 49152 65536 81920 122880

2048

29)
#####################################################################################################
#####WHICH DATASTORE WOULD YOU LIKE TO USE - STORES THINGS LIKE Application IMAGES ETC.         #####
#####WE CURRENTLY SUPPORT  1: Amazon S3 2: Google Cloud                                         #####
#####################################################################################################
PLEASE MAKE YOU CHOICE OF DATASTORE (1),(2)

1

30) Super safe backups - it's recommended that you set these to switched on

################################################################################################
#####SUPER SAFE BACKUPS ARE ADDITIONAL BACKUPS TO THOSE MADE TO YOUR REPOSITORY PROVIDER  ######
################################################################################################
Do you wish to have super safe backups of your webroot to your datastore of choice?
(Y/N)
Y
Do you wish to have super safe backups of your database to your datastore of choice?
(Y/N)
Y

31) Development will disable things like autoscaling and give you a basic set of machines to develop on
When you are deploying for real, obviously, this needs to be set to production
Are you deploying for 1)Development or 2)Production?
Please enter: 1 or 2

1

32) Select if you want to install a virgin application, a baseline of an application you have developed and customised or a backup
of an application you have been actively using already

######################################################################################################################################
##### WE NEED TO SELECT A BUILD TO DEPLOY. WE HAVE 6 CHOICES. SOME OF THEM ARE BACKUP BUILDS WHICH WILL ONLY BE DEPLOYABLE IF YOU#####
##### HAVE BUILD/DEPLOYED THIS EXACT APPLICATION/WEBSITE BEFORE. IN THE FIRST INSTANCE, THEN, FOR A NEW APPLICATION/WEBSITE      #####
##### YOU WILL HAVE TO BUILD FROM THE VIRGIN BUILD, OPTION 1, WHICH IS A BASELINE PROVIDED BY THE WEBMASTER WHO BUILT IT         #####
######################################################################################################################################

Please select, would you like to build from a :

0) Virgin Build (If you want a fresh (virgin) install of an Application, select this option)

1) Baseline Build (The application developer should provide a baseline of his application. You can install it by selecting this option)

2) Hourly  (Build the website based on the daily backup. These backups are taken once and hour and will be the most recent to build from

3) Daily  (Build the website based on the daily backup. Daily backups occur overnight (GMT)

4) Weekly (Build the website based on the weekly backup. Useful if you had a problem on the site and you need to roll back to a previous version)

5) Monthly (Build the website based on the monthly backup)

6) Bi-Monthly (Build the website based on the bi-monthly backup)
########################################################################################################################################
YOU NEED TO POINT ME TO A REPOSITORY WITH THE SOURCECODE FOR AN APPLICATION OF TYPE:  BASIC SOCIAL NETWORK
PLEASE ENTER THE NUMBER OF THE BUILD CHOICE YOU WISH TO SELECT. YOU NEED TO MAKE SURE YOU HAVE READ ACCESS TO ANY ASSOCIATED REPOSITORIES

1

You previously chose to build an application of type:  BASIC SOCIAL NETWORK
As you are choosing to build from a baseline build, please enter the URL to the repository in BitBucket where your sourcecode is stored for your application
You can find this by navigate to your repository and copying and pasting the repository name from the URL
For example: socialnetwork-webroot-sourcecode-baseline
socialnetwork-webroot-sourcecode-baseline

Thanks ... Now please input the repository URL of your database code repository
For example socialnetwork-db-baseline
socialnetwork-db-baseline

32) ***IMPORTANT****

If you have already been running the site you are deploying, you may see the following message:

===============================================================================================================================
Hi Mate, there's some assets in your datastore for this website. They are probably from a previous build
You have selected a baseline or a virgin build which means existing assets will be deleted. If you wish to preserve these assets
Please go to your datastore provider and make sure there is either an hourly,daily,weekly,monthly or bimonthly
backup of them. If there isn't, you can make a manual backup using the tools of your datastore provider
THESE IMAGES WILL BE DELETED, IT IS STRONGLY ADVISED THAT YOU CHECK IN YOUR DATASTORE THAT YOU HAVE A BACKUP OF THEM
FAILURE TO HAVE A BACKUP WILL MEAN THAT APPLICATION MEDIA THAT HAS BEEN GENERATED THROUGH SITE USAGE WILL BE IRREVOCABLY LOST
THIS WOULD RENDER YOUR CURRENT SITE NON FUNCTIONAL. IF YOU ARE OK WITH THE SITE slough.marionettes.community BEING TRASHED, THEN, NO WORRIES
IF IT'S NOT CLEAR BASICALLY, A VIRGIN OR A BASELINE DEPLOYMENT IS OVERWRITING THE ASSETS OF AN EXISTING AND POSSIBLY LIVE SITE
WHICH NEEDS TO BE FLAGGED UP TO YOU AS THE PERSON WHO INITIATED THE DEPLOYMENT
Press the Enter key once you have taken the appropriate steps, if any
===============================================================================================================================

If you accept this message, then because you are building a new baseline of a site you have previously already deployed, it will wipe
the assets from the datastore. The are backed up, but make certain that you have backups available or else your previous deployment
may be ruined should you wish to make use of it again. Even if you do have backups, you will have to manually restore them to the 
live repository to be able to get back to a previous deployment of the application, so it's not really recommended.

34)
We need to have a smtp service for emails generated by the deployed application as well as system emails from the infrastructure to you, the webmaster .
It is therefore necessary to provide an email address which can be used both to send emails from the application and also to send system messages to
So, please enter the email address where you wish system messages to be sent
fred@email.com
We also need to set up an SMTP provider to send the system status emails through
If you don't have an account with one of the supported smtp server providers, please set one up first
Which SMTP provider are you registered with?
Currently, we support 1) SMTP Pulse (www.sendpulse.com) 2) Google (gmail)
There's a little trick of aesthetics here. Gmail is free, but mails will be sent with an email address like fred@gmail.com
SMTP pulse, for example is not free, but you can register your postmaster@yourdomain.com from your postfix deployment and mails will be personalised to your domain then
2
Please enter 1) The Address you would like system emails to be sent from
fred3204@gmail.com
Please enter your email address for your SMTP provider
fred3204@gmail.com
Please enter your password for your SMTP provider
xxxxxxx

35) Some checks will then be made to ensure that you don't already have an autoscaler, webserver, database or mailserver running

===============================================================================================================================================

Once you have configured a build, the next time you deploy using the same build identifier, it will ask you if you wish to use the same settings
If that's OK, just enter Y and it will use the same settings as before. If there's just a couple of settings you want to change, then you can 
directly edit, in this case: ${BUILD_HOME}/buildconfiguration/linode/testbuild1-credentials and altered the settings yu require.
Then redeploy, accept the settings as before and there you go, a shortcut.

Cheers

Peter
