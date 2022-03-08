There are three classes of build. Virgin builds, baseline builds and temporal builds (hourly, daily, weekly and so on)

Virgin builds and baseline builds only run in development mode and do not make any automated backups. Instead, when your application is built, you have to manually make a baseline of it which you can do by running these scripts on your build machine, one for your webroot and one for your database.

**${BUILD_HOME}/helperscripts/PerformWebsiteBaseline.sh** 

**${BUILD_HOME}/helperscripts/PerformDatabaseBaseline.sh**

Once your baseline is made, you can use these scripts to create a temporal backup of your webroot and database

**${BUILD_HOME}/helperscripts/PerformWebsiteBackup.sh** 

**${BUILD_HOME}/helperscripts/PerformDatabaseBackup.sh**

Picking the temporal periodicity which you want to make a backup for.

**NOTE** 

if the setting **DISABLE_HOURLY_BACKUPS** is set to "1", then, hourly backups will not be made if you run this script and you will need to make (and deploy) from daily backups. The reason for disabling hourly backups is that its something that you might want to do with some providers if you find that your hourly backups (to your git provider) are racking up the costs as it is considered "data out". 

You can use any off these scripts at any time from your build machine to make a backup or a baseline.  
If **SUPERSAFE_BACKUPS** is set to "1", then, a second backup is made to your S3 datastore as well as to your GitHub repository.  

If you have made a temporal backup from your baseline machines in development mode, then, shutdown your development machines and redeploy in production mode from your temporal backups to "go live" with your application.  

**NOTE** if your baseline is to be used by 3rd parties by making the repository public so that they can deploy from it, ensure that there's no senstive credentials either in the database dump or the webroot sourcecode. Believe it or not, there are bots and people who trawl git repos for such oversights and once sensitve credentials are gleaned, they intend to use them as an attack vector, obviously. 

You can find a more detail explanation of the backup and baseline process here: 

[Backup and Basseline](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/doco/AgileToolkitDeployment/BaselinesAndBackups.md)
