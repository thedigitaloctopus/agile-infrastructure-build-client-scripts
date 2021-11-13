**NOTE:** If you use the backup service from your cloudhost as well as regular and supersafe backups from this toolkit, you will have application backups in 3 places, your git provider, your datastore and your backup with your cloudhost. This should be pretty solid as a backup strategy. You don't have to use your cloudhost's backup service, it might cost £, but, if you want to go to the extreme with your backups, you can.

## BACKUP AND BASELINE PROCESSES:  

#### Baseline processes

To baseline an application follow these steps

1. Deploy a virgin copy of your chosen CMS system and develop your application

2. SSH onto the build machine that you deployed your virgin CMS application from originally

   ##### ssh -p <ssh_port> <user_name>@<build_machine_ip>
	
   You need to the following variables from your userdata override script that you used to deploy your virgin CMS to be able to ssh onto your build machine:
	
	##### export BUILDCLIENT_USER="user_name"  
	##### export BUILDCLIENT_PASSWORD="password"  
	##### export BUILDCLIENT_SSH_PORT="ssh_port"  
	
3. You will have been authenticated by using the SSH keys associated with your build machine and then issue the command

   ##### sudo su  
   	
   and enter the password **BUILD_CLIENT_PASSWORD** for your user to assume root privilege  
	
4. Generate a baseline by manually creating repositories with your (application) git provider with the following nomenclature

  #####  [baseline_name]-webroot-sourcecode-baseline  
  #####  [baseline_name]-db-baseline  
	
5. Once your repositories are created in step 4 above, 

    ##### cd ${BUILD_HOME/helperscripts
	 
    ##### sh PerformWebsiteBaseline.sh
	 
	 enter **[baseline_name]** for the identifier, all other question should be self explanatory
	 
	 the system will then create the baselined sourcecode for your website in your git provider's repository. 
	 
	 check in your git repository that your baselined sourcecode has been generated correctly
	 
    ##### sh PerformDatabaseBaseline.sh
	 
	 enter **[baseline_name]** for the identifier, all other questions should be self explanatory
	 
	 the system will then create a baseline of your database in the git provider's repository
	 
	 check in your git repository that the baseline is stored correctly
	 
-----------------------------------------------------------------------------------------------------

##### DEPLOYING FROM A BASELINE

Obviously to deploy from a baseline you need a pair of baselined repositories as described above. Presuming that:

When youi are deploying from a baseline using the Expedited or the Full Build just answering the questions should keep you on track.

If you are deploying from a baseline using the hardcore build method, then, you need to be interested in the following parameters:

**BUILD_CHOICE="1"** Setting this to 1 informs the toolkit that you are using a baseline  
**BUILD_ARCHIVE_CHOICE="baseline"** This also needs to be set (for different reasons) to "baseline"  
**export BASELINE_DB_REPOSITORY="[identifier]-db-baseline"** This needs to be set to the name of your database baseline repository  
**export APPLICATION_BASELINE_SOURCECODE_REPOSITORY="[identifier]-webroot-sourcecode-baseline"** This needs to be set to the name of your website baseline repository  
**export DIRECTORIES_TO_MOUNT="wp-content.uploads"** You need to mention which assets directory need to be mounted from the object store (the example here is wordpress)  
**export APPLICATION_IDENTIFIER="2"**  This needs to be set to 1 for joomla, 2 for wordpress, 3 for drupal or 4 for moodle  
**export SELECTED_TEMPLATE="3"** This need to be set to 2 for joomla 3 for wordpress 4 for drupal and 5 for moodle  
	
You can refer to the specification for more detail.

------------------------------------------------------------------------------------------------------

##### BACKUP PERIODICITY

The backup periodicity is as follows:

##### hourly, daily, weekly, monthly, bimonthly, shutdown, manual and all

What this means is that backups of the webroot and your database will be automatically taken at these different periodicities.

You can make a backup on from the build machine by runining the backup scripts from the build machine: 

**${BUILD_HOME}/helperscripts/PerformWebsiteBackup.sh**

**${BUILD_HOME}/helperscripts/PerformDatabaseBackup.sh**

There is a special periodicity available on the build machine which is "all" and when you select this, it will make a backup for all time based periodicities. 

---------------------------------------------------------------------------------------------------------

##### HOW BACKUPS ARE MADE FROM CRON

The backups are created by calling the script

**${HOME}/git/Backup.sh** from cron.  

You pass in the build periodicity **"HOURLY", "DAILY", "WEEKLY", "MONTHLY", "BIMONTHLY", "SHUTDOWN" or "MANUAL"** and the **BUILD_IDENTIFIER** and that will then create a backup (including the necessary repository) with your git provider.  
Similarly for the database machine as well. 

---------------------------------------------------------------------------------------------------------

##### MANUAL and SHUTDOWN BACKUPS

There are two special periodicities, "manual and shutdown".

The manual periodicity is such that you can use it if you were ever to need to generate an adhoc manual backup of your webroot and database from the command line. This gives you a way of creating an adhoc backup at any time you need without overwriting any of your standard time based periodicities. 

The shutdown periodicity is a special case such that if a webserver is being shutdown either through an autoscaling event or as part of a manual shutdown of the webservers, a backup is taken of the webroot of the webserver and labelled as the latest shutdown backup. This is just so there is a record of the state of that webserver at the time it was shutdown. 

-----------------------------------------------------------------------------------------------------------

##### SWITCH OFF HOURLY BACKUPS

When I was using AWS I noticed I was racking up quite a bill due to my writing of hourly backups to an external git provider. It wasn't cripplingly high cost, although I am very poor, so I had to take note. So, what I did was to provide an option to switch off hourly backups. Now I don't know whether I was getting a bill because of how things were configured or whether it was just considered "data out" and therefore billable. With all the other providers I didn't have this problem, but, this is there just to let you know that there is a configuration switch such that you can switch off hourly backups if you need to and save a few quid. Your base periodicity will then be daily or once every 24 hours which should be 24 times less expensive. 

------------------------------------------------------------------------------------------------------------

##### DEPLOYING FROM A BACKUP
	
	To deploy from a backup, you can answer the questions appropriately during an expedited or full build, but, if you are using an hardcore build, then, you need to set the following parameters:

**APPLICATION="wordpress"** - This needs to be either joomla, wordpress, drupal or moodle  
**BUILD_CHOICE="3"** - set this to 2 for hourly, 3 for daily, 4 for weekly, 5 for monthly, 6 for bimonthly  
**BUILD_ARCHIVE_CHOICE="daily"** this can be "hourly", "daily", "weekly", "monthly", or  "bimonthly"  
**DIRECTORIES_TO_MOUNT="wp-content.uploads"** Set here which directories to mount (this example is wordpress)  
**PRODUCTION="1"** set this to 1 for production 0 for development  
**DEVELOPMENT="0"** set this to 1 for development and 0 for production  
**NUMBER_WS="1"** This says how many webservers you want to build to start off with. Once built the autoscaling mechanism will kick in if you are in production and will adjust the number of webservers accordingly.  
**APPLICATION_IDENTIFIER="2"** 1 for joomla, 2 for wordpress, 3 for drupal, 4 for moodle  
**SELECTED_TEMPLATE="3"** the template number available for your cloudhost that you are basing your build on and overriding with these values.  
**NO_AUTOSCALERS="2"** The numnber of autoscalers to deploy. This means faster upscaling and downscaling and is also more resilient in case of failures.  

-------------------------------------------------------------------------------------------------------------

#####  THE ASSETS ARE STORED IN THE CLOUD AND ARE THEREFORE NOT PART OF THE BACKUPS BUT ARE PART OF THE BASELINES
	
Its normal to set PERSIST_ASSETS_TO_CLOUD to 0 for baselines and virgin builds. This is because the cloud is only used to offload assets.
So ordinarily if your application users are going to be generating assets you want them to be stored in your datastore and distributed from there using a CND (see elsewhere in this doco). Note, if your assets are stored in the cloud i.e. PERSIST_ASSETS_TO_CLOUD is set to 1, then, it is the only place where those assets are stored, there aren't any backups, so if you were to delete the assets by mistake, for example, it might hose your application. Its just a bucket with assets in it at the end of the day, so its not hard to make backups if you want to. 

-------------------------------------------------------------------------------------------------------------

###### SUPERSAFE BACKUPS

The authoritative backups that are made for your application are stored in git repositories. However, if you switch on "super safe backups", then, a copy of your backups will also be written to your datastore. This gives you two sets of backups one in your git repositories and one in your datastore. This is common advise, backup and backup again. In other words, under normal operation within a week of running your website, you will have 2 hourly backups, one with your git provider and one in your datastore, you will have 2 daily backups, one with your git provider and one with your datastore and you will have 2 weekly backups, one with your git provider and one with your datastore. This is quite a few backups which you can fall back on and, of course, the weekly backups will be a week old but losing a weeks worth is better than losing it entirely. 
