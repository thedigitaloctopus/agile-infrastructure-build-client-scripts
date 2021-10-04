### APPLICATION DEVELOPMENT WORKFLOW

1. Choose your cloudhost and use the toolkit to deploy a virgin copy of your chosen CMS, Joomla, Wordpress, Moodle or Drupal. 
2. You can now build your application. Whilst you are building it you will want to create baselines of it. You can create (as per your desire), baselines of your application webroot and application database using the scripts. 

    **${BUILD_HOME}/helperscripts/PerformWebsiteBaseline.sh**  
and  
    **${BUILD_HOME}/helperscripts/PerformDatabaseBaseline.sh** 
    
    NOTE: It is essential that your APPLICATION_IDENTIFIER is set to 0 when you are making a baseline. You can modify it by executing the following scripts on your webserver machine and the database machine from the build machine:
    
    **cd ${BUILD_HOME}/helperscripts/** 
    **./ExecuteOnWebserver.sh "/home/${SERVER_USERNAME}/providerscripts/utilities/StoreConfigValue.sh \"APPLICATIONIDENTIFIER\" \"0\""**
    
    Alternatively, you can simply use "ConnectToWebserver.sh" and "ConnectToDatabase.sh" and change the value of "APPLICATIONIDENTIFIER" to "0" in the files:
    
    **/home/${SERVER_USERNAME}/.ssh/webserver_configuration_settings.dat**
    
    and  
    
    **/home/${SERVER_USERNAME}/.ssh/database_configuration_settings.dat**

 3. Once you get to the point were your application is ready, you can make a final baseline and also make the initial backups which is how you will deploy the "live" sites. To create the backups that are used to deploy the live site, run the scripts:

    **${BUILD_HOME}/helperscripts/PerformWebsiteBackup.sh**  
and  
    **${BUILD_HOME}/helperscripts/PerformDatabaseBackup.sh**  
    
    You will need to chose "ALL" as your selection for the periodicities for which you are making backups. This will create backups for the periodicities: **HOURLY DAILY WEEKLY MONTHLY BIMONTHLY** and it will take quite some time, but, you can be sure then that you can build from any periodicity without a problem. 
    
    **NOTE:** It is essential that your APPLICATION_IDENTIFIER is set when you are making a backup.  
    
    The APPLICATIONIDENTIFIER should be set to 1 if your application is Joomla based  
    The APPLICATIONIDENTIFIER should be set to 2 if your application is Wordpress based  
    The APPLICATIONIDENTIFIER should be set to 3 if your application is Drupal based  
    The APPLICATIONIDENTIFIER should be set to 4 if your application is Moodle based  

    You can modify it by executing the following scripts on your webserver machine and the database machine from the build machine:
    
    **cd ${BUILD_HOME}/helperscripts/** 
    **./ExecuteOnWebserver.sh "/home/${SERVER_USERNAME}/providerscripts/utilities/StoreConfigValue.sh \"APPLICATIONIDENTIFIER\" \"0\""**
    
    Alternatively, you can simply use "ConnectToWebserver.sh" and "ConnectToDatabase.sh" and change the value of "APPLICATIONIDENTIFIER" to "0" in the files:
    
    **/home/${SERVER_USERNAME}/.ssh/webserver_configuration_settings.dat**
    
    and  
    
    **/home/${SERVER_USERNAME}/.ssh/database_configuration_settings.dat**
    
4. Once your backups are made in 3, take the site off line (as most likely you built it from a baseline) by shutting down your development mode servers and redeploy from one of the backups you have made in full production mode. The system will then take backups at each periodicity. If you need to update plugins and extensions in your "live" application, the recommendation is to perform the upgrades at night as there is a period of (up to) 5 minutes when the websevers will be out of sync, also, you don't want to update your application during scaling events and so on. 

**NOTE:** you can also make special "manual" backups which means you can take a backup at any time and it will be stored in a repository marked, "manual". 
