## BACKUP AND BASSELINE PROCESSES:  

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

  #####  <baseline_name>-webroot-sourcecode-baseline  
  #####  <baseline_name>-db-baseline  
	
5. Once your repositories are created in step 4 above, 

    ##### cd ${BUILD_HOME/helperscripts
	 
    ##### sh PerformWebsiteBaseline.sh
	 
	 enter **<baseline_name>** for the identifier, all other question should be self explanatory
	 
	 the system will then create the baselined sourcecode for your website in your git provider's repository. 
	 
	 check in your git repository that your baselined sourcecode has been generated correctly
	 
    ##### sh PerformDatabaseBaseine.sh
	 
	 enter **<baseline_name>** for the identifier, all other questions should be self explanatory
	 
	 the system will then create a baseline of your database in the git provider's repository
	 
	 check in your git repository that the baseline is stored correctly
	 
-----------------------------------------------------------------------------------------------------

##### DEPLOYING FROM A BASELINE

------------------------------------------------------------------------------------------------------

##### EXPLAINING BACKUP PERIODICITY

The backup periodicity is as follows:

##### hourly, daily, weekly, monthly, bimonthly and shutdown

What this means is that backups of the webroot and your database will be automatically taken at these different periodicities.

---------------------------------------------------------------------------------------------------------

##### EXPLANATION OF HOW BACKUPS ARE MADE FROM CRON

The backups are created by calling the script

${HOME}/git/Backup.sh from cron. You pass in the build periodicity "HOURLY", "DAILY", "WEEKLY", "MONTHLY", "BIMONTHLY" and the BUILD_IDENTIFIER and that will then create a backup (including the necessary repository) with your git provider. Similarly for the database machine as well. 

---------------------------------------------------------------------------------------------------------

##### EXPLAIN MANUAL and SHUTDOWN BACKUPS

There are two special periodicities, "manual and shutdown".

The manual periodicity is such that you can use it if you were ever to need to generate an adhoc manual backup of your webroot and database from the command line. This gives you a way of creating an adhoc backup at any time you need without overwriting any of your standard time based periodicities. 

The shutdown periodicity is a special case such that if a webserver is being shutdown either through an autoscaling event or as part of a manual shutdown of the webservers, a backup is taken of the webroot of the webserver and labelled as the latest shutdown backup. This is just so there is a record of the state of that webserver at the time it was shutdown. 

-----------------------------------------------------------------------------------------------------------

##### EXPLAIN SWITCH OFF HOURLY BACKUPS

When I was using AWS I noticed I was racking up quite a bill due to my writing of hourly backups to an external git provider. It wasn't cripplingly high cost, although I am very poor, so I had to take note. So, what I did was to provide an option to switch off hourly backups. Now I don't know whether I was getting a bill because of how things were configured or whether it was just considered "data out" and therefore billable. With all the other providers I didn't have this problem, but, this is there just to let you know that there is a configuration switch such that you can switch off hourly backups if you need to and save a few quid. Your base periodicity will then be daily or once every 24 hours which should be 24 times less expensive. 

------------------------------------------------------------------------------------------------------------

##### DEPLOYING FROM A BACKUP

-------------------------------------------------------------------------------------------------------------

##### EXPLAIN HOW THE ASSETS ARE STORED IN THE CLOUD AND ARE THEREFORE NOT PART OF THE BACKUPS BUT ARE PART OF THE BASELINES

-------------------------------------------------------------------------------------------------------------

###### EXPLAIN SUPERSAFE BACKUPS

The authoritative backups that are made for your application are stored in git repositories. However, if you switch on "super safe backups", then, a copy of your backups will also be written to your datastore. This gives you two sets of backups one in your git repositories and one in your datastore. This is common advise, backup and backup again. In other words, under normal operation within a week of running your website, you will have 2 hourly backups, one with your git provider and one in your datastore, you will have 2 daily backups, one with your git provider and one with your datastore and you will have 2 weekly backups, one with your git provider and one with your datastore. This is quite a few backups which you can fall back on and, of course, the weekly backups will be a week old but losing a weeks worth is better than losing it entirely. 