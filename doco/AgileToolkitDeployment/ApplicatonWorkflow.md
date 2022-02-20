### APPLICATION DEVELOPMENT WORKFLOW

See **NOTE 1** below

1. Choose your cloudhost and use the toolkit to deploy a virgin copy of your chosen CMS, Joomla, Wordpress, Moodle or Drupal. 
2. You can now build your application. Whilst you are building it you will want to create baselines of it. You can create (as per your desire), baselines of your application webroot and application database using the scripts. 

    **${BUILD_HOME}/helperscripts/PerformWebsiteBaseline.sh**  
and  
    **${BUILD_HOME}/helperscripts/PerformDatabaseBaseline.sh** 
    
 3. Once you get to the point were your application is ready, you can make a final baseline and also make the initial backups which is how you will deploy the "live" sites. To create the backups that are used to deploy the live site, run the scripts:

    **${BUILD_HOME}/helperscripts/PerformWebsiteBackup.sh**  
and  
    **${BUILD_HOME}/helperscripts/PerformDatabaseBackup.sh**  
    
    You will need to chose "ALL" as your selection for the periodicities for which you are making backups. This will create backups for the periodicities: **HOURLY DAILY WEEKLY MONTHLY BIMONTHLY** and it will take quite some time, but, you can be sure then that you can build from any periodicity without a problem. 
      
4. Once your backups are made in 3, take the site off line (as most likely you built it from a baseline) by shutting down your development mode servers and you now have two choices. You can generate snapshots when from your temporal backup and then redeploy into production mode or you can not bother with snapshots and just make do with building your websevers from scratch each time there is a scaling event. If you want to make snapshots you need to deploy in development mode with GENERATE_SNAPSHOTS="1" 

--------------

**NOTE 1:** It is essential that your APPLICATION_IDENTIFIER is set when you are making a backup or a baseline.  
    
The APPLICATIONIDENTIFIER should be set to 1 if your application is Joomla based  
The APPLICATIONIDENTIFIER should be set to 2 if your application is Wordpress based  
The APPLICATIONIDENTIFIER should be set to 3 if your application is Drupal based  
The APPLICATIONIDENTIFIER should be set to 4 if your application is Moodle based  

If it is not set correctly you can modify it by executing the following scripts on your webserver machine and the database machine from the build machine:  
    
**cd ${BUILD_HOME}/helperscripts/**  

**./ExecuteOnWebserver.sh "/home/${SERVER_USERNAME}/providerscripts/utilities/StoreConfigValue.sh \"APPLICATIONIDENTIFIER\" \"(1|2|3|4)\""**
    
Alternatively, you can simply use "ConnectToWebserver.sh" and "ConnectToDatabase.sh" and change the value of "APPLICATIONIDENTIFIER" to "(1|2|3|4)" in the files:
    
**/home/${SERVER_USERNAME}/.ssh/webserver_configuration_settings.dat**
    
and  
    
**/home/${SERVER_USERNAME}/.ssh/database_configuration_settings.dat**

**NOTE 2:** you can also make special "manual" backups which means you can take a backup at any time and it will be stored in a repository marked, "manual". 
