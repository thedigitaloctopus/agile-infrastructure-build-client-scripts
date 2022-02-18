1. All the DNS A records are deleted as part of the initial build process. If you use Cloudflare, if a 3rd party (script maybe) or yourself navigates to your live URL whilst all A records are deleted they/you will be served an NXRecord which basically means that there is no record for that domain.
THE NXRecord seems to be cached and it may cause an issue with SSL certificate issuance. In this case, you will see an error message with NXRecord in the message body and the build process will terminate. The solution is to wait for the caching to clear so that the NXRecord is no longer being served and restart the build process. Under normal operation, this should not happen.  

2. To shutdown your infrastructure it is important not to simply shutdown the machines using a provider's GUI system or the cli tools. There's a script in the **helperscripts** directory called **ShutdownInfrastructure.sh** which you must run each time you want to shut your system down. This gives the machines a chance to clean up, make backups and so on which means that your data will be consistent.

3. If you are using Cloudflare as your DNS Service provider, you need to, at a minimum, switch on 'Full SSL' and also, you need to create a page rule which directs all calls to http://www.website.com to https://www.website.com. This way, you can be sure that all your requests are being issued securly. Also, when you are in development mode, letsencrypt will issue a "testing" certificate which Cloudflare will not accept in "strict mode". If you drop it back down to "full" during development and up to "strict" once you are ready for production, this should allow you to make most efficient use of the certificate issuing process. 

4. Remember if you change from deploying to one DNS service and choose another, you will have to change the nameservers with the service you bought your domain names. This is called a Nameserver update and has a propagation delay of up to 48 hrs before your webproperty will be accessible through the new nameservers. 

5. Advised best practice is to rotate your ssh keys. The simplest way to do that with this toolkit is simply to set aside a maintenance window, take your deployment down and redeploy. 

6. If you want to customise the configuration of your webserver, you can easily do it by altering the scripts in

**Agile-Infrastructure-Webserver-Scripts/providerscripts/webserver/configuration/* **

7. If you want to change the number of webservers that are run by default, you can change the NO_WEBSERVERS variable in

**Agile-Infrastructure-Autoscaler-Scripts/autoscaler/PerformScaling.sh**

Always rememeber that there are cron scripts which configure how many webservers are running for different times of day and you can alter those to manage your compute provisions. 

8. To alter your test database configuration, you can modify the file:

**Agile-Infrastructure-Database-Scripts/providerscripts/database/singledb/mariadb/InitialiseMariaDB.sh** for Maria DB
 
 and the file
 
**Agile-Infrastructure-Database-Scripts/providerscripts/database/singledb/postgres/InitialisePostgresDB.sh** for Postgres
 
9. If you want to monitor your application uptime, I recommend uptime robot www.uptimerobot.com

10. If you are using s3fs for your shared storage, then, if you delete the buckets using the Cloudhost provider's gui system or the s3cmd tool there tends to be a period of time with some providers when buckets of the same name cannot be created again. If you run the scripts during this period and they require the same bucket name as a bucket that you have recently deleted for shared storage, you will get unpredictable behaviour. If you wait till the grace period expires, then, you will be able to complete the execution of the scripts successfully.  

11. If you make multiple builds and have, for example, "testbuild-1", "testbuild-2" and so on, you need to name them (the BUILD_IDENTIFIER), "1-testbuild", "2-testbuild" rather than "testbuild-1" and "testbuild-2", this is because in some places the "BUILD_IDENTIFIER" might get truncated and you would lose the distinction.  

12. You should only set PERSIST_ASSETS_TO_CLOUD to 0 when you are deploying from temporal backups if you are very sure that your application will have very few assets generated at runtime in most cases, you will have to set PERSIST_ASSETS_TO_CLOUD to 1. 

13. It is advised that if you are installing upgrades to your CMS for extensions and plugins and so on when the application is live with multiple webservers running that it is advisable to do the install at night. The upgrade will pick an adhoc webserver based on load balancing, within 5 minutes the system will pick up the changes on that machine and sync them to the other webservers. The syncing process runs every 5 minutes so, if you have to update a live system if you apply the update at 02:34 for example, the time period for which the servers are out of sync with the database will be short but it is possible on a heavily used site that a few error messages will be seen on occasion.

14. When you are setting credentials for your application db during the **DBaaS** deployment process, make sure that the names/values you choose do not appear within you applications sourcecode. For example, a DB username like "admin" will likely appear in your application's sourcecode and when we do our credential switch for you during application redeployment, you will likely get unexpected substitutions going on within you application. This only applies to DBaaS installations when it is up to you to define credentials in most cases. For regular DB installs, we generate DB credentials for you, as you know. During regular database deployments the credentials are automatically generated and so, I have control of that and can make them distinct or random, but, with a DBaaS deployment it is up to you to make the credentials you use unique or non-existent strings with the source code. 

15. The Agile Deployment Toolkit supports the following application database:

##### Joomla 4 using MySQL, MariaDB or Postgresql is supported  
##### Wordpress using MySQL or MariaDB is supported (Postgres needs some faff with wordpress,but you are welcome to modify the toolkit)   
##### Drupal using MySQL, MariaDB or Postgres is supported  
##### Moodle using MySQL, MariaDB or Postgres is supported

16. These builds depend on external services, if a service is down, the build may well not complete.

17. I haven't been able to figure out why, but, sometimes for the Vultr cloudhost, the Ubuntu machine's networking availability freezes for about 10 minutes during the build. For this reason its recommended to only use Debian on Vultr unless you can use Ubuntu and figure out why that is happening, I couldn't.

18. If you get problems with SSL certificate issuance during a build, it is most likely because of "rate limiting". This is most likely to occur if you are using the "hardcore" build method because the other build methods reuse previously issued certificates. 

19. Be aware of firewall rules limits which are different by provider. For example with digital ocean you can only have 50 rules per firewall and the way this is currently set up, if you wanted to have say 30 webservers running (they have at least 2 firewall rules each) you would run out of firewall rules to allocate and the system wouldn't work. So, review how many firewall rules you can have if you were planning on some huge system (which you most probably aren't. )
Vultr, for example, only allows one firewall per server with a 50 rules limit. This means you will be limited in the number of webservers you can deploy.

20. If you are building a deployment from snapshots, you should only deploy in the same region that the snapshots were taken in or from. In other words, if you need to deploy the snapshots to a different region you will have to regenerate them.

21. When you deploy using snapshots you will need to deploy using the same build machine configuration that the snapshot was built with. You can do this either by always deploying from the same build machine or by using a backup of the build machine that the snapshot was generated from by following: [Backup Build Machine](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/doco/AgileToolkitDeployment/RetrievingBuildMachineBackup.md)


