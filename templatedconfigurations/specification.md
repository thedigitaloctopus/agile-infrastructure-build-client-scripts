### APPLICATION

This can be set to one of "joomla", "wordpress", "drupal", "moodle"

---- 

### JOOMLA_VERSION

If you are deploying a virgin joomla installation, you must give the version number of joomla that you are deploying here. In such a template, you will likely want to update this version number to be the latest available.

---- 

### DRUPAL_VERSION

If you are deploying a virgin drupal installation, you must give the version number of drupal that you are deploying here. In such a template, you will likely want to update this version number to be the latest available.

---- 

### APPLICATION_BASELINE_SOURCECODE_REPOSITORY

If you are deploying a virgin application, you can set this to "JOOMLA:{latest_version}", "WORDPRESS", "DRUPAL:{latest_version}" or "MOODLE"

-----

### S3_ACCESS_KEY and S3_SECRET_KEY

These grant you access to manipulate an object store. Under the principle of least privileges, you should grant as few privileges to these keys wen you create them as possible. The DATASTORE_CHOICE setting (see below) will determine which Object Storage you are using and you will need to generate access keys appropriate to that setting. 

You can get your S3_ACCESS_KEY and S3_SECRET KEY as follows:

##### digital ocean - Login to your digital ocean account and go to the API submenu (on the left bottom) and generate "Digital Ocean Spaces Keys". This will give you an access key which you can paste into your template. The first key is the S3_ACCESS_KEY and the second key is the S3_SECRET_KEY

##### exoscale - Login to your exoscale account and go to the IAM menu (on the right) and generate a pair of API keys which have access to object storage capabilities. The first key is the S3_ACCESS_KEY and the second key is the S3_SECRET_KEY which you can post into your template.

##### linode - Login to your Linode account and go to the Object Storage menu on the right then select the Access Key menu and select "Create an Access Key" and that will generate an access key and a secret key which you can copy into your template as S3_ACCESS_KEY and S3_SECRET_KEY.

##### vultr - You need to subscribe to S3 Object Storage and this will grant you a pair of S3 access keys which you can copy and paste into your template. 

##### AWS - Under your IAM user, create a pair of keys which have S3 manipulation capabilities and paste them into your template as S3_ACCESS_KEY and S3_SECRET_KEY

-----

### S3_HOST_BASE 

This parameter is the S3 endpoint for your deployment. It should be located as near as possible to where (in the world) you plan to run your VPS systems.

##### digital ocean - Available endpoints to choose from (2020) - nyc3.digitaloceanspaces.com, ams3.digitaloceanspaces.com, sfo2.digitaloceanspaces.com, sgp1.digitaloceanspaces.com, fra1.digitaloceanspaces.com

##### exoscale - Available endpoints to choose from (2020) - sos-ch-gva-2.exo.io, sos-ch-dk-2.exo.io, sos-de-fra-1.exo.io, sos-de-muc-1.exo.io, sos-at-vie-1.exo.io, sos-bg-sof-1

##### linode - Available endpoints to choose from (2020) - us-east-1.linodeobjects.com, eu-central-1.linodeobjects.com

##### vultr - Available endpints to choose from (2020) - ewr1.vultrobjects.com, 

##### Amazon - There are lots of S3 endpoints to choose from for Amazon. Your S3 endpoint should be region specific. For example if you are in eu-west-1 in would be, s3.eu-west-1.amazonaws.com

You can set your ${S3_HOST_BASE} parameter in your template to one of these listed endpoints depending on who your object storage is hosted with (which will likely be the ssame provider as your VPS systems). 

-----

### S3_LOCATION

##### digital ocean - the location should always be set to "US" no matter where you are in the world, when I tried setting it differently, I got problems.

##### exoscale - the location should always be set to "US" no matter where you are in the world 

##### linode - the location should always be set to "US" no matter where you are in the world 

##### vultr - the location should always be set to "US" no matter where you are in the world

##### amazon - I have only used "US" and "EU" depending on whether I am deploying to the EU or the US, I am not sure what this setting would be for other parts of the world

-----

### ACCESS_KEY and SECRET_KEY 

These grant you access to compute resources with your cloud provider. Under the principle of least privileges, you should grant as few privileges to these keys wen you create them as possible.

##### digital ocean - This does not need to be set for digital ocean, instead, see TOKEN= below

##### exoscale - Login to your exoscale account and go to the IAM menu (on the right) and generate a pair of API keys which have access to compute manipulation capabilities. The first key is the ACCESS_KEY which you can paste into your template for the ACCESS_KEY variable.

linode -  @@@@@@@@@@@@@@@'

vultr - @@@@@@@@@@@@@@@@@

##### AWS - Under your IAM user, create a pair of keys which have compute manipulation capabilities and paste them into your template as ACCESS_KEY and SECRET_KEY

-----

### TOKEN

Some providers use personal access tokens rather than access keys and secret keys. In such a case, the personal access token can be stored in this variable. If the provider uses a personal access token, you can store it here, basically, othewise presume that an access key and a secret key are utilised.

##### digital ocean - Login to your digital ocean account and go to the API submenu (on the left bottom) and generate a "Digital Ocean Personal Access Token". This will give you a personal access token which you can paste into your template as the value of the TOKEN variable.

##### exoscale - exoscale does not need this see ACCESS_KEY and SECRET_KEY

##### linode - @@@@@@@@@@@@@@@

##### Vultr - @@@@@@@@@@@@@@@@

##### AWS - @@@@@@@@@@@@@@@@@

-----

### DNS_USERNAME

This will be the username for your DNS service provider

##### cloudflare - the emal address of username of your cloudflare account

##### digital ocean - not needed 

##### rackspace -     not needed

-----

### DNS_EMAIL_ADDRESS:

##### cloudflare - not needed

##### digitalocean - your digital ocean account email address

##### rackspace - your rackspace account email address

-----

### DNS_SECURITY_KEY 

This is the security key which will enable us to manipulate records as needed with your DNS provider. You can find this key as follows for each provider:

##### cloudflare - Ths is the Global API key for your cloudflare account which you can find by clicking on your profile at the top right of the screen

##### digital ocean - The access token for your digital ocean account, the same as TOKEN

##### rackspace  - The access key for your rackspace account

------

### DNS_REGION

#### cloudflare - not needed

#### digitalocean - not needed

#### rackspace - one of : DFW ORD IAD LON SYD HKG

-----

### DNS_CHOICE  

This can be set to one of three values at the time of writing (2020) - 

##### 1. "cloudflare" 
##### 2. "digitalocean" 
##### 3. "rackspace". 

It defines which of the (supported) DNS service you would like to use with your deployment.

-----

### DEFAULT_USER

When you deploy to exoscale, the default user should be set to "ubuntu" if you are deploying Ubuntu and "debian" if you are deploying to Debian.
When you deploy to AWS, the default user should be set to "ubuntu" if you are deploying Ubuntu and "admin" if you are deploying to Debian.
For all other cases, the DEFAULT_USER should be set to "root"

-----

### WEBSITE_DISPLAY_NAME

This is simply the display name of your application, for example, "My Social Network", or "My Blog" and so on. It should be descriptive of your website and likely will be similar to the core part of the WEBSITE_URL described below

-----

### WEBSITE_NAME

This HAS to be exactly the same of the core part of the URL name of your website. So, if your website is called www.nuocial.org.uk, then, this value MUST be "nuocial"

-----

###  WEBSITE_URL

This is the URL of your website. It can be any valid URL

-----

### APPLICATION_REPOSITORY_PROVIDER

This is the git service provider where your application repositories are hosted. It has to be one of "github", "bitbucket" or "gitlab". If you fill this variable with one of those three exact strings, then, that will tell us who your application code is hosted with. It may or may not be hosted with the same provider as the infrastructure code for the agile deployment toolkit

-----

### APPLICATION_REPOSITORY_OWNER

This is the username of the user who owns (or created) your application repositories with your chosen git service provider

-----

### APPLICATION_REPOSITORY_USERNAME

This is the username of the user that you are currently using to access the application repositories. For example, the repositories might be owned by userA and are kept private but, userB is granted access. In this case the APPLICATION_REPOSITORY_OWNER would be userA and the APPLICATION_REPOSITORY_USERNAME would be userB. If you are the application repository owner, then this username and the owner name above will be the same.

-----

### APPLICATION_REPOSITORY_PASSWORD

This is the password for the APPLICATION_REPOSITORY_USERNAME or the application repository user. This is the password for your user account with your git provider. If the application repositories are public (be careful not to expose sensitive credentials if you make your application repos public), then this password can be blank.

-----

### SYSTEM_EMAIL_PROVIDER

At the moment, there are three SMTP email service providers. Enter the number value, "1", "2" or "3" to select which provider you want to use for your SMTP service. If you leave these variables blank, you simply won't receive any system emails to give status updated on build progression, server intialisations and so on. You are free to leave these variables blank, as you choose.

Enter "1" - Sendpulse (www.sendpulse.com)
Enter "2" - Google (gmail)
Enter "3" - AWS SES 

-----

### SYSTEM_TOEMAIL_ADDRESS 

The email address that system emails will be sent to this can be any email address that you have access to. MAYBE, the emails get marked as spam depending on your provider. If you take them out of the spam folder, then, the system should learn they are not spam. Most likely you will want to have a dedicated email address for your system emails for your deployed application as they will likely fill up your inbox otherwise.

-----

### SYSTEM_FROMEMAIL_ADDRESS

The email address that system emails will be sent from. This should be an email address that the system emails are sent from. In your SYSTEM_TOEMAIL_ADDRESS inbox, this will be the email address that the system messages are seen to be sent from or to have originated from.

-----

### SYSTEM_EMAIL_USERNAME

This is the username of your SMTP user. For Amazon SES, for example, this will be the username generated when you enable the SES service. This is the SMTP username. 

-----

### SYSTEM_EMAIL_PASSWORD

This is the password of your SMTP user. For Amazon SES, for example, this will be the password generated when you enable the SES service. This is the SMTP password. 

----

### DIRECTORIES_TO_MOUNT

Each CMS system is likely to have directories where assets are generated from application usage and so on. Assets and media that are generated at runtime need to be immediately shared between all webservers and the way I do this is as a general solution, I mount the assets directories specific to the CMS type from a shared S3 bucket to each webserver. There is a specific solution for AWS which is the EFS system which is also supported. EFS can have up to petabytes of information and assuming you have very deep pockets, you can have petabytes of storage for you dyanmic application assets which is often a limiting factor for large scale social networks and so on, where often, asset generation is quite high with members uploading videos and images and the like. 

Joomla DIRECTORIES_TO_MOUNT="images:media" - When the CMS is joomla, this will mount /var/www/html/images and /var/www/html/media.
Wordpress DIRECTORIES_TO_MOUNT="wp-content.uploads". When the CMS is wordpress, this will mount /var/www/html/wp-content/uploads.
Drupal DIRECTORIES_TO_MOUNT="

export DIRECTORIES_TO_MOUNT="wp-content.uploads"

----- 

### PRODUCTION and DEVELOPMENT

These settings are twinned. It only makes sense for them to be in one of two configurations:

Production mode : PRODUCTION="1", DEVELOPMENT="0"
Development mode : PRODUCTION="0", DEVELOPMENY="1"

These settings must be altered as a pair. When in production, an autoscaler or autoscalers are deployed and you can set NUMBER_WS. On the autoscaler machine you can modify ${HOME}/config/scalingprofile/profile.cfg to set the number of webservers to deploy and also, in the crontab, you can set ScaleUp and ScaleDown script parameters to enable a time up and time down scaling. For example, you might scale up to 5 webservers at 7:30 AM each morning using the crontab in expectation of daily usage and scale back down to (not less than 2) for resilence at 11:30 in anticipation of a quiet night. 

-----

### NUMBER_WS

This will set the number of webservers to deploy by default. If you set this to 3, for example, then 3 webservers will be spun up by default

-----

### SUPERSAFE_WEBROOT

Ordinarily, backups are made to the git repository provider that your application sourcecode is hosted with. These can be HOURLY, DAILY, WEEKLY, MONTHLY, BIMONTHLY.
Backups that can be made to repositories have a data limit, so, if your application sourcecode ever exceeds this limit in some way, then, you will need supersafe backups which makes a backup to your S3 datastore as well as your git provider. You will likely want to have this switched on for piece of mind. You know that if anything happens to your git backups, you have second backups in your datastore. Backup and backup again. If backups can't be found in git, then, the scripts look in the datastore for them and uses backups found there instead. 

-----
### SUPERSAFE_DB

This is the same as SUPERSAFE_WEBROOT, but, for your application database files. SUPERSAFE_DB AND SUPERSAFE_WEBROOT should be set together to either on or off. If one is on, they should both be on. 

-----

### WEBSERVER_CHOICE

You have a choice of webserver that you want to deploy to. You can set this to "NGINX, "APACHE" or "LIGHTTPD". What you set this to will determine which webserver gets installed and used. 

-----

### DATABASE_INSTALLATION_TYPE

If you are installing a database on a VPS system, you have three types of database you can choose from by default. Obviously, your choice here has to be supported by your CMS system. The three choices are: "Maria", "MySQL", and "Postgres"

----

### DISABLE_HOURLY

This is just a flag to disable hourly backups which you might want to do, if your backups were incurring you costs in some way. When this is set to "1", no hourly backups are made. When it is set to "0", hourly backups are made as usual. 

-----

### SERVER_TIMEZONE_CONTINENT

This is the continent where your servers are located. You can get a list of continents by issuing the following commands:

pushd .
cd /usr/share/zoneinfo/posix && /usr/bin/find * -type f -or -type l | /usr/bin/sort | /usr/bin/awk -F'/' '{print $1}' | /usr/bin/uniq | /bin/sed ':a;N;$!ba;s/\n/ /g'
popd 

-----

### SERVER_TIMEZONE_CITY

This is the city where your servers are located. You can get a list of cities by issuing the following commands:

pushd .
cd /usr/share/zoneinfo/posix && /usr/bin/find * -type f -or -type l | /usr/bin/sort | /usr/bin/awk -F'/' '{print $2}' | /usr/bin/uniq | /bin/sed ':a;N;$!ba;s/\n/ /g'
popd 

-----

### DB_PORT

This is the port that your Database will be listening on. BE SURE that if you are using a managed database that you set this value to be the same as the port that you set when you setup the managed DB. If it is different, obviously, the scripts will not collect and things will go south. 

-----

### SSH_PORT

This is the port that the SSH daemon will be listening on for connections. You can set this as you would normally set a port. Obviously, the port you set has to be free on your server. The firewall will work with whatever setting you set and allow connections to that port. 

-----

### PERSIST_ASSETS_TO_CLOUD

This enables you to switch off the DIRECTORIES_TO_MOUNT procedure. You might want to do this if you are in development mode and you don't need to share assets between multiple webservers. If this is set to "0" it means that the assets you generate whilst you are developing are stored on the webservers local file system and not in the S3 datastore. It means that the assets can't be shared, but, there might be a performance increase if you are interested in that. 

-----

### BUILD_CHOICE

If set to "0", this means that you are installing a virgin CMS system, for example, Joomla, Wordpress, Moodle or Drupal
If set to "1", this means that you are deploying a baseline of an application you have customised (see BASELINE_DB_REPOSITORY and APPLICATION_BASELINE_SOURCECODE_REPOSITORY ) also, BUILD_ARCHIVE_CHOICE needs to be set to "baseline
If set to "2"  this means that you are deploying from an hourly backup of an application (availability dependent on DISABLE_HOURLY)
if set to "3", this means that you are deploying from a daily backup of an application
If set to "4"  this means that you are deploying from a weekly backup of an application
If set to "5"  this means that you are deploying from a monthly backup of an application
If set to "6"  this means that you are deploying from a bimonthly backup of an application

As long as you have backups in place, you can use this setting to roll back to a backup from up to two months previously, if you had some need to. 

----- 

### BASELINE_DB_REPOSITORY

When you baseline your application database, you will need to create a repository <unique_identifier>-db-baseline. From here your baseline will be pulled during installation. 
If for example, your unique identifier is "nuocialboss", then, the repository would be "nuocialboss-db-baseline" and 

BASELINE_DB_REPOSITORY would be set to "nuocialboss-db-baseline"

-----

### APPLICATION_BASELINE_SOURCECODE_REPOSITORY

When you baseline your application sourcecode, you will need to create a repository <unique_identifier>-webroot-sourcecode-baseline. From here your baseline will be pulled during installation. 

If for example, your unique identifier is "nuocialboss", then, APPLICATION_BASELINE_SOURCECODE_REPOSITORY would be "nuocialboss-webroot-sourcecode-baseline" 

-----

### BUILD_ARCHIVE_CHOICE

You need to set BUILD_ARCHIVE_CHOICE based on where you are deploying from. The settings can be as follows for each option:  

 BUILD_ARCHIVE_CHOICE="baseline"  
 BUILD_ARCHIVE_CHOICE="hourly"  
 BUILD_ARCHIVE_CHOICE="daily"  
 BUILD_ARCHIVE_CHOICE="weekly"  
 BUILD_ARCHIVE_CHOICE="monthly"  
 BUILD_ARCHIVE_CHOICE="bimonthly"

-----

### APPLICATION_LANGUAGE

You can set this to "HTML" or "PHP" based on the language you are deploying for.

------

### PHP_VERSION

If you are deploying PHP, then you can set which version of PHP you are deploying here. Ordinarily, it should be the latest available version (currently 7.4).
So, to use 7.4 you would set PHP_VERSION="7.4"

-----

export REGION=""

---------

### REGION_ID

This is the region id where you wish to deploy the servers to.

Available region ids to choose from for each provider are:

Digital Ocean: Available region IDs you can set for digital ocean are: "nyc1","sfo1","nyc2","ams2","sgp1","lon1","nyc3","ams3","fra1","tor1","sfo2","blr1","sfo3"  

Exoscale: Available region IDs you can set for exoscale are:  
                                                           for region ch-gva-2 regionid = "1128bd56-b4d9-4ac6-a7b9-c715b187ce11"  
                                                           for region ch-dk-2  regionid = "91e5e9e4-c9ed-4b76-bee4-427004b3baf9"  
                                                           for region at-vie-1 regionid = "4da1b188-dcd6-4ff5-b7fd-bde984055548"  
                                                           for region de-fra-1 regionid = "35eb7739-d19e-45f7-a581-4687c54d6d02"  
                                                           for region bg-sof-1 regionid = "70e5f8b1-0b2c-4457-a5e0-88bcf1f3db68"  
                                                           for region de-muc-1 regionid = "85664334-0fd5-47bd-94a1-b4f40b1d2eb7"
Linode: @@@@@@@@@@@@@@@@
Vultr: @@@@@@@@@@@@@@@
AWS: @@@@@@@@@@@@@@@@

----------

### DB_SIZE AS_SIZE WS_SIZE

For the Database, the autoscaler and the webserver, you can set their individual sizes using these parameters.

Available sizes to choose from are:

Digital Ocean: 512mb,1gb,2gb,4gb,8gb,16gb,32gb,48gb,64gb (there are other sizes, but, restricting to these keeps in simple for most uses)  

Exoscale: 10G,50G,200G,300G,400G  

Linode: @@@@@@@@@@@@@@@@@  

Vultr: @@@@@@@@@@@@@@@@  

AWS: @@@@@@@@@@@@@@@@@  


-------

### DB_SERVER_TYPE

For each machine size DB_SIZE it needs to have the appropriate machine type set. The following machine types correspond to the appropriate _SIZE parameter directly above

DigitalOcean: 512mb,1gb,2gb,4gb,8gb,16gb,32gb,48gb,64gb  

Exoscale:  DB_SERVER_TYPE for each machine size. If your machine is set to  

10G : "b6cd1ff5-3a2f-4e9d-a4d1-8988c1191fe8"  
50G : "b6e9d1e8-89fc-4db3-aaa4-9b4c5b1d0844"  
100G : "c6f99499-7f59-4138-9427-a09db13af2bc"  
200G : "350dc5ea-fe6d-42ba-b6c0-efb8b75617ad"  
400G : "a216b0d1-370f-4e21-a0eb-3dfc6302b564"

Linode: @@@@@@@@@@@@@@@@@@@@@@@@  

Vultr:  @@@@@@@@@@@@@@@@@@@@@@@@  

AWS  :  @@@@@@@@@@@@@@@@@@@@@@@@  


### CLOUDHOST

This is the cloudhost you are deploying to. The current choices are:

"digitalocean", "exoscale", "linode", "vultr", "aws"

You can set the cloudhost to Digital Ocean, for example by setting the CLOUDHOST variable as CLOUDHOST="digitalocean"

---------

### MACHINE_TYPE

This is just an identifier which we can check for on our servers. It can be set to

"DROPLET", "EXOSCALE", "LINODE", "VULTR", "AWS"

------------

### ALGORITHM

This is the algorithm that the ssh uses to form connections it can be set to "rsa", or, "ecdsa"

------

### USER

This is the user that the scripts is running as. It can be set, as, USER="root" and so on

--------

### CLOUDHOST_USERNAME

This is the username of the for the cloudhost, it can be set - CLOUDHOST_USERNAME="root", for example
**THIS MUST BE SET FOR ALL LINODE DEPLOYMENTS. THE BUILD WILL FAIL FOR LINODE IF A CLOUDHOST_USERNAME IS NOT SET**


-------- 

### CLOUDHOST_PASSWORD

This is the password of the for the cloudhost, it can be set - CLOUDHOST_PASSWORD="password", for example
**THIS MUST BE SET FOR ALL LINODE DEPLOYMENTS. THE BUILD WILL FAIL FOR LINODE IF A CLOUDHOST_PASSWORD IS NOT SET**

----------

### PREVIOUS_BUILD_CONFIG

When you run the AgileDeploymentToolkit.sh method of building your deployment, it will guide you through questions and answers and from that build a configuration. This configutation will be located at: ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}. This file is created right at the very end of a successful build process and not before. Once this file has been created, you can either use it to craft a template as ${BUILD_HOME}/templateconfigurations/templates/${CLOUDHOST}/${CLOUDHOST}[n].tmpl for repeated usage or you can rerun the AgileDeploymentToolkit.sh script and when promoted choose to reuse this configuration file. When a configuration from a previous build is being used, this will be set to "1" otherwise it will be set to "0". This should be set to "0" if you are building from a template using the ExpeditedAgileDeploymentToolkit process.  

------
### WSIP, WSIP_PRIVATE,DBIP,DBIP_PRIVATE,ASI,ASIP_PRIVATE,BUILD_CLIENT_IP

These are all IP addresses for the various machine types that can be used as part of the build process. None of them need to be set in the template itself. They variables are there as place holders and if a template has been used, the script will populate them with the actual values for you to review if you need to. Suffice to say, in a default template, all these values should be set to "".

------

### GIT_USER, GIT_EMAIL_ADDRESS

These are the values for the git user that your commits are made by. Obviously, I don't know what those will be, so they are set to some placeholder values in the templates I have provided, but, you can change them to your own values, of course. These values correspong to **git config --global user.name "Template User"** and  **git config --global user.email "templateuser@dummyemailX1.com"** 

-----

### APPLICATION_REPOSITORY_TOKEN

This is a gitlab and github specific token. When you have a private application repository with gitlab or github, you need to generate a private auithorisation token.
For github, you can do this by logging into your account and going to: https://github.com/settings/tokens and then generate one
    gitlab, you can do this by logging into your account with them and clicking on Profile Settings -> Access Tokens and then generating one"
The token that you generate can be placed here in your template instead of a password (for your application repositories)

-----

### INFRASTRUCTURE_REPOSITORY_PROVIDER, INFRASTRUCTURE_REPOSITORY_OWNER,INFRASTRUCTURE_REPOSITORY_USERNAME,INFRASTRUCTURE_REPOSITORY_PASSWORD

Unless I move the infrastructure repositories to bitbucket or gitlab, these values will ALWAYS need to be set as follows

INFRASTRUCTURE_REPOSITORY_PROVIDER="github"
INFRASTRUCTURE_REPOSITORY_OWNER="agile-deployer"
INFRASTRUCTURE_REPOSITORY_USERNAME="agile-deployer"
INFRASTRUCTURE_REPOSITORY_PASSWORD="none"

-----

### DATASTORE_CHOICE

This value determines who your object store provider will be (very likely the same as your compute services provider, but, doesn't have to be)
DATASTORE_CHOICE should be set to one of the following values:
 
 For Amazon S3: "amazonS3"
 For DigitalOcean spaces: "digitalocean" 
 For Exoscale Object Store: "exoscale" 
 For Linode Object Store: "linode"
 For Vultr Object Store: "vultr"
 
 -----
 
### DBaaS_HOSTNAME

If you are using a managed database this will be the hostname of your managed database, for example, tester.cdfij3fddo74b.eu-west-1.rds.amazonaws.com or of some other similar format for another provider. If there are pubic and private hostnames available, you should choose the private one.

-----

### DBaaS_USERNAME

If you are using a managed database, this will be the username that you set for your database.

------

#### DBaaS_PASSWORD

If you are using a managed database, this will be the password that you set for your database.

------

#### DBaaS_DBNAME

If you are using a managed database, this will be the name that you set for your database.

------

### DATABASE_DBaaS_INSTALLATION_TYPE

If you are using a managed database this should correspond to the type of database you are deploying and can be set to one of, "Maria", "MySQL" or "Postgres". 

------

### DEFAULT_DBaaS_OS_USER 

If you are using an SSH tunnel to a DBaaS provider, just to complicate things, sometimes linux is deployed with a different default user other than root sometimes, it is 'ubuntu'. When we are secure shelling onto your ssh tunnel cloud server, we need to make sure we get the default user name right. So, it is probably root, but check with your provider how they set up the default user. So, please input the default user for your DBaaS cloud host, probably 'root', but please check. I have seen the default user set to "root", "debian" and "ubuntu". If you are SSH tunneling you will likely need to set the default user to one of these values.

-----

### DBaaSDBSECURITYGROUP

If you are using an AWS managed database then the database will have a security group of the format: "sg-0fad5hf744c044361". You need to find the security group of your managed database and paste the sg- value here. It will not build with

-----

### DBaaS_REMOTE_SSH_PROXY_IP

If you are using an SSH tunnel, you need to set this value to the IP address of the remote machine that you are proxying through.

-----

### APPLICATION_NAME

The APPLICATION_NAME corresponds to the APPLICATION IDENTIFIER

APPLICATION IDENTIFIER       |     APPLICATION NAME
        1                    |    JOOMLA APPLICATION
        2                    |    WORDPRESS APPLICATION
        3                    |    DRUPAL APPLICATION
        4                    |    MOODLE APPLICATION
        
-----

### SSL_GENERATION_METHOD

This can be set to "AUTOMATIC" or "MANUAL". If it is set to automatic, then an attempt to provision an SSL certificate from an automated authority will be made. If it is set to manual, you will have to manually obtain and present your own certificate. 

-----

### SSL_GENERATION_SERVICE="LETSENCRYPT"

When SSL_GENERATION_METHOD="AUTOMATIC", this should be set to "LETSENCRYPT" otherwise it should be left blank

------

### MAPS_API_KEY

This is purely a convenience. If your application wordpress, joomla or whatever uses a maps solution, you can place your maps API key here for reference and you can then access it through your server file system if you need to instead of authenticating with the provider and so on. 

-----

### PHP_MODE,PHP_MAX_CHILDREN, PHP_START_SERVERS, PHP_MIN_SPARE_SERVERS,PHP_MAX_SPARE_SERVERS,PHP_PROCESS_IDLE_TIMEOUT

You can set these values according to the PHP spec. You can leave all of these blank in order to accept the default values that PHP ships with, but, if you want more control, then you can set these values here and your PHP system will be configured to use them. You need to know what you are doing to set these.

PHP_MODE, for example can be set to, "static", "dynamic" or "on demand". When you set these modes, you need to set the other parameters appropriate to that mode.  

Let me know if you think further PHP settings should be configurable like this. It's a centralised way to do it. Alter them here and all your servers will reflect your desire. 

----
 
### IN_MEMORY_CACHING, IN_MEMORY_CACHING_PORT,IN_MEMORY_CACHING_HOST, IN_MEMORY_CACHING_SECURITY_GROUP

If you are using an IN-MEMORY caching solution such as Elasticache on AWS, then, you can set your caching relevant settings here.

IN_MEMORY_CACHING can be set to "redis", or "memcache"
IN_MEMORY_CACHING_PORT is the port that the caching service is running on
IN_MEMORY_CACHING_HOST is the host that the caching service is running on
IN_MEMORY_CACHING_SECURITY_GROUP is the (where appropriate) security group that the caching service is running in.

-----

### ENABLE_EFS

If you are using AWS EFS, then, you can set this to "1" in all other cases, this should be "0"

------

### SUBNET_ID

If you are using AWS, you must set this to the subnet ID of your servers. In all other cases it should be blank. 

-----

#### AUTOSCALE_FROM_SNAPSHOTS

If you have built from snapshots, set this to "1" to have your webservers  built during a scaling event be built from your snapshots.

-----

### GENERATE_SNAPSHOTS

If you are doing a build to generate snapshots ready for future builds to deploy from, you can set GENERATE SNAPSHOTS to "1" otherwise it should be "0"

----

### SNAPSHOT_ID

The snapshot ID is the first four characters of the snapshots that you are going to build your servers from

------

### WEBSERVER_IMAGE_ID, AUTOSCALER_IMAGE_ID,DATABASE_IMAGE_ID

These are the full IDs of the images that your servers will be built off if you build using snapshots you have generated.

-----

### DRUPAL_VERSION

This is specific to the drupal application. You set it to be the version of drupal that you want to deploy which will likely be the latest version

-----

### JOOMLA_VERSION

This is specific to the joomla application. You set it to be the version of joomla that you want to deploy which will likely be the latest version
