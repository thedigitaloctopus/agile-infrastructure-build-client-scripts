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
   	
   and enter the password BUILD_CLIENT_PASSWORD for your user to assume root privilege  
	
4. Generate a baseline by manually creating repositories with your (application) git provider with the following nomenclature

  #####  <baseline_name>-webroot-sourcecode-baseline  
  #####  <baseline_name>-db-baseline  
	
5. Once your repositories are created in step 4 above, 

    ##### cd ${BUILD_HOME/helperscripts
	 
    ##### sh PerformWebsiteBaseline.sh
	 
	 enter <baseline_name> for the identifier, all other question should be self explanatory
	 
	 the system will then create the baselined sourcecode for your website in your git provider's repository. 
	 
	 check in your git repository that your baselined sourcecode has been generated correctly
	 
    ##### sh PerformDatabaseBaseine
	 
	 enter <baseline_name> for the identifier, all other questions should be self explanatory
	 
	 the system will then create a baseline of your database in the git provider's repository
	 
	 check in your git repository that the baseline is stored correctly
	 
-----------------------------------------------------------------------------------------------------

DEPLOYING FROM A BASELINE

EXPLAINING BACKUP PERIODICITY

EXPLAIN CALL BACKUPS FROM CRON

EXPLAIN SHUTDOWN BACKUPS

EXPLAIN SWITCH OFF HOURLY BACKUPS

DEPLOYING FROM A BACKUP

EXPLAIN HOW THE ASSETS ARE STORED IN THE CLOUD AND ARE THEREFORE NOT PART OF THE BACKUPS BUT ARE PART OF THE BASELINES

EXPLAIN SUPERSAFE BACKUPS
