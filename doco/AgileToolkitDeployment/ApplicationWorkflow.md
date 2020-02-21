IMPORTANT: When you are setting credentials for your application db during the DBaaS deployment process, make sure that the names/valuies you choose do not appear within you applications sourcecode. For example, a DB username like "admin" will likely appear in your application's sourcecode and when we do our credential switch for you during application redeployment, you will likely get unexpected substitutions going on within you application. This only applies to DBaaS installations when it is up to you to define credentials in most cases. For regular DB installs, we generate DB credentials for you, as you know. 

Application Workflow

1. It is expected that in the first instance, you will deploy some sort of virgin application, maybe a CMS such as Joomla or Wordpress.

In this case it is expected that you will deploy in development mode with only one webserver and that you will be able to develop and customise your application until your heart is content. Once you have completed your application and you are ready to release it it is expected then that you will create a baseline of it in your git repository.

2. To create a baseline of your application, ssh onto your development webserver using the helper scripts on the build client machine.

You should do a "sudo su" and you can find the "SERVERUSERPASSWORD" in the directory ${HOME}/.ssh to use to authenticate when promoted by sudo.

Once you have sudo'd, you can go to ${HOME}/providerscripts/git and there you will find a script CreateWebrootBaseline.sh.
Make sure the HOME environment variable is set to "/home/${SERVER_USER} and then run the CreateWebrootBaseline.sh script
As described go to your git repo provider and create a repository of the format <unique-name>-webroot-sourcecode-baseline
As prompted by the script, enter the <unique-name> in order to create a baseline of your webroot.

3. Now we have to do the same thing for the database. So, ssh onto the Database server using the helper scripts from the build client machine. You should do a "sudo su" and you can find the "SERVERUSERPASSWORD" in the directory ${HOME}/.ssh to use to authenticate when promoted by sudo.

Once you have sudo'd, you can go to ${HOME}/providerscripts/git and there you will find a script CreateDBBaseline.sh.
Make sure the HOME environment variable is set to "/home/${SERVER_USER} and then run the CreateDBBaseline.sh script
As described go to your git repo provider and create a repository of the format <unique-name>-db-baseline
As prompted by the script, enter the <unique-name> in order to create a baseline of your webroot.

4. Any cusotmisations you need done to your specific application, you can do by placing scripts in Agile-Infrastructure-Webserver-Scripts/applicationscripts/ and you will find a sample cusomisation in the socialnetwork directory, you can make a similar one for your application. The same customisation can be performed on the database server also Agile-Infrastructure-Database-Scripts/applicationscripts and again there is a socialnetwork example of how to customise your application. By customising your application, you can change the branding so that it should be possible to deploy the same application simply with different branding such as display name and so on. 

5. OK, so you should be all set with your baseline repos and scripts and so on. So, you can deploy the application for real by running the build client script AgileDeploymentToolkit.sh and selecting to deploy from a baseline and pointing the scripts to the respective repositories you previously baselined to. 

NOTE, if you have deployed this particular application before to a particular URL it can take some considerable time for the baseline to deploy because it may have to clear out the assets from the datastore from the previous deployment which is slow. If we could just rename buckets and be done with it, it would be fast, but renaming buckets isn't possible with most S3 compliant datastores, with others it might be. To accelerate the process of deploying from a baseline, if you have a lot of assets in the associated datastore from a previous build, you can manually trash those using the GUI, the build process will be much quicker then. 

6. It is expected that once a virgin application has been installed, customised and baselined and an hourly backup has been made that all future deployments of that particular application will be from hourly backups. In the case when we want to have a separate distinct instance, say you want a social network for town A and the same social network for town B, then all you have to do is redeploy from the baseline you made for town A. There's an option to switch off hourly backups (to your git repo) at deployment time because depending on your providers pricing model, it can increase costs copying "out to the internet" data on a regular basis. In the case where hourly backups are disabled because of costing concerns, your daily backups will be the next most regular periodicity of backup. Supersafe backups make backups to S3 repositories as well, so, if you really need to make hourly backups but don't want the heavy costs (in some cases), you can switch off hourly backups (to your git repo) and switch on supersafe backups which will make hourly backups to your datastore still. When you deploy from a backup, it will deploy from your datastore rather than from a git repo. Also, if your application sourcecode or database for some reason becomes "too big" for your git repo (which is quite possible) then, backups to your git repo will fail and in this case, you will have to have super safe backups enabled. The advice is to always have super safe backups enabled and to treat the git based backups as either discretionary (in the case of hourly backups) or impossible (in the case where the application code or database extends beyond the limits of the git repo).  

NOTE : It is better to have your datastore endpoint in the same datacentre as your compute instances. For example, if most of your customers are in England you might want to choose (if you are using digital ocean) the lon1 datacentre but the "spaces" object store service is not available in lon1 from DO, so, you have to use "ams3" for your datastore. So, you are better off having your compute instances and your datastore (spaces) service endpoint both in ams3 even though lon1 is nearer to your customers. 
