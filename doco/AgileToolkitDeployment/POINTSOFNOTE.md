1 All the DNS A records are deleted as part of the initial build process. If a 3rd party (script maybe) or yourself navigates to your live URL whilst all A records are deleted they/you will be served an NXRecord which basically means that there is no record for that domain.
THE NXRecord seems to be cached and it may cause an issue with SSL certificate issuance. In this case, you will see an error message with NXRecord in the message body and the build process will terminate. The solution is to wait for the caching to clear so that the NXRecord is no longer being served and restart the build process. Under normal operation, this should not happen. 


3 Once your application is live and deployed in production mode, you can increase and decrease the minimum number of webservers by accessing the file

/home/X...X/autoscaler/PerformScaling.sh on the AUTOSCALER machine. 

In there you can modify the parameter NO_WEBSERVERS to be what you want it to be. 
PLEASE NOTE: If you are in development mode, then, autoscaling does not function and you can only have 1 webserver active
Importantly, there's two scripts which are called from the crontab on the autoscaler to scale up and scale down. These run in the morning for the scale up and in the evening for the scale down, although, of course, you can configure them differently. Also, by modifying the parameters to these scripts, you can determine how many webservers are deployed based on the operational requirements of your application.

4 If you are using cloudflare as your DNS Service provider, you need to, at a minimum, switch on 'Full SSL' and also, you need to create a page rule which directs all calls to http://www.website.com to https://www.website.com. This way, you can be sure that all your requests are being issued securly. 

5 With applications like wordpress or drupal, your SMTP credentials are stored in /var/www/wordpresssmtp and /var/www/drupalsmtp  respectively. You can set your SMTP server active according to these credentials as required by you application. 

6 Remember if you change from deploying to one DNS service and choose another, you will have to change the nameservers with the service you bought your domain names. This is called a Nameserver update and has a propagation delay of up to 48 hrs before your webproperty will be accessible through the new nameservers. 

7 Advised best practice is to rotate your ssh keys. The simplest way to do that with this toolkit is simply to set aside a maintenance window, take your deployment down and redeploy, possibly to a different cloudhost. 

8 When you are deploying an application from a baseline it can take some time for the assets to be uploaded to your datastore provider. If you terminate a deployment before the assets have been transfered, then that is obviously an issue. So, when you deploy from a baseline, you have to give ample time for your assets to be uploaded to the datastore for cross deployment asset persistence. 

9 If you want to customise the configuration of your webserver, you can easily do it by altering the scripts in

Agile-Infrastructure-Webserver-Scripts/providerscripts/webserver/configuration/*

10 If you want to change the number of webservers that are run by default, you can change the NO_WEBSERVERS variable in
Agile-Infrastructure-Autoscaler-Scripts/autoscaler/PerformScaling.sh. Always rememeber that there are cron scripts which 
configure how many webservers are running for different times of day and you can alter those to manage your compute provisions. 

11 To alter your test database configuration, you can modify the file:

 Agile-Infrastructure-Database-Scripts/providerscripts/database/singledb/mariadb/InitialiseMariaDB.sh for Maria DB
 
 and the file
 
 Agile-Infrastructure-Database-Scripts/providerscripts/database/singledb/postgres/InitialisePostgresDB.sh for Postgres
 
12 If you want to monitor your application uptime, I recommend uptime robot www.uptimerobot.com
 You may have to whitelist the uptimerobot ips if you have a firewall, they can be found here: https://uptimerobot.com/locations

 13. If you are using s3fs for your shared storage, then, if you delete the buckets using the cloudhost providers gui system there tends to be a period of time when buckets of the same name cannot be created again. If you run the scripts during this period with the same bucket name as a bucket that you have recently deleted, you will get unpredictable behaviour. 
