There are three classes of build. Virgin builds, baseline builds and temporal builds (hourly, daily, weekly and so on)

Virgin builds and baseline builds only run in development mode and do not make any automated backups. Instead, when your application is built, you have to manually make a baseline of it which you can do by running these scripts, one for your webroot and one for your database.

**${BUILD_HOME}/helperscripts/PerformWebsiteBaseline.sh** 

**${BUILD_HOME}/helperscripts/PerformDatabaseBaseline.sh**

Once your baseline is made, you can use these scripts to create a temporal backup of your webroot and database

**${BUILD_HOME}/helperscripts/PerformWebsiteBackup.sh** 

**${BUILD_HOME}/helperscripts/PerformDatabaseBackup.sh**

Picking the temporal periodicity which you want to make a backup for.

**NOTE** if the setting **DISABLE_HOURLY_BACKUPS** is set to "1", then, hourly backups will not be made if you run this script and you will need to make (and deploy) from daily backups.

You can use any either of these scripts at any time from your build machine to make a backup. If **SUPERSAFE_BACKUPS** is set to "1", then, a backup is made to your S3 datastore as well as your github repository. 

If you have made a temporal backup from your baseline machines in development mode, then, shutdown your development machines and redeploy in production mode from your temporal backups to "go live" with your application.

**NOTE** if your baseline is to be used by 3rd parties by making the repository public ensure that there's no senstive credentials either in the database dump or the webroot sourcecode. Believe it or not, there are bots and people who trawl git repos for such oversights. 

You can find a more detail explanation of the backup and baseline process here: 

[Backup and Basseline](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/doco/AgileToolkitDeployment/BaselinesAndBackups.md)
