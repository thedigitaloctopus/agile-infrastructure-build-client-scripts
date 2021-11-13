### DEVELOPMENT MODE

In development mode, there are three machine types a single webserver and a single database server and a build machine upon which the server build is started.
Its possible for the build machine to be your own laptop if you are running some version of linux, but it is **not recommended because it will make configuration changed to your machine**. If you want to, you can run a dedicated Ubuntu or Debian Linux off a usb stick (for example) to perform your builds on, this would save you a bit of money because you won't need to be running a (small) build machine in the cloud. 
The webserver and the database share a configuration directory using s3fs or if you are on AWS, Elastic File System. 
The webserver has its IP address registered with a DNS system and both machines are firewalled and can be connected to from the build machine only through SSH and with the appropriate SSH keys.

### PRODUCTION MODE

In production mode, there is four machine types: there is are autoscaler machines, there are webserver machines, there is a database server and there's a build machine upon which the build is initiated.
The autoscaler machine monitors the webservers for responsiveness and is responsible for initiating (and performing) the build of new servers according to scaling criteria (statically defined).
The webservers have their ip addresses registered with a DNS system and load balancing between them performed using round robin. 
The Database server is resposible for runnng the database system. The Database system can use DBaaS managed databases but it still needs to run in such a scenario.
All machines can only be connect to through SSH and are firewalled off in all other regards. There is a configuration directory shared between all machines using S3FS or EFS if you are on AWS.

On both the development mode and production mode application backups can be made from the webservers and the database machines. 
Cron is used to schedule system processes on all machines and there is a defined process for application development workflow starting in development mode and working up towards full production deployments with multiple webservers.
Applications can be deployed from baselines or from temporal backups depending on your needs. Temporal backups should always be private to your organisation where as baselines can be made public **(with appropriate care taken not to have sensitive credentials in the codebase/SQL dump)** and yes by 3rd parties, possibly for a fiscal price. 
