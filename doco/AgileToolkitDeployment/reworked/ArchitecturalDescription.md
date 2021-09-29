#### DEVELOPMENT MODE

In development mode, there are three machine types a single webserver and a single database server and a build machine upon which the server build is started.
The webserver and the database share a configuration directory using s3fs. 
The webserver has its IP address registered with a DNS system both machines are firewalled and can be connected to from the build machine only through SSH.

### PRODUCTION MODE

In production mode, there is four machine types: there is are autoscaler machines, there are webserver machines, there is a database server and there's a build machine upon which the build is initiated.
The autoscaler machine monitors the webservers for responsiveness and is responsible for initiating (and performing) the build of new servers according to scaling criteria (statically defined).
The webservers have their ip addresses registered with a DNS system and load balancing between them performed using round robin. 
The Database server is resposible for runnng the database system.
All machines can only be connect to through SSH and are firewalled off in all other regards. There is a configuration directory shared between all machines using S3FS.

On both the development mode and production mode application backups can be made from the webservers and the database machines. ]
Cron is used to schedule system processes on all machines and there is a defined process for application development workflow starting in development mode and working up towards full production deployments with multiple webservers.
The Database Server also supports Managed Database systems where you can use a Managed Database behind your Database server. 
