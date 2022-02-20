### DEVELOPMENT MODE

In development mode, there are three machine types a single webserver and a single database server and a build machine upon which the server build is started.
Its possible for the build machine to be your own laptop if you are running some version of linux, but it is  
  
  **not recommended because it will make configuration changes to your machine**.  
    
  
If you want to, you can run a dedicated "Ubuntu" or "Debian" Linux off a usb stick on your laptop to perform your builds on and have that USB as your "build usb", this would save you a bit of money because you won't need to be running a (small) build machine in the cloud all the time.  
The webserver and the database share their configurations using s3fs or if you are on AWS, Elastic File System (EFS).  

### PRODUCTION MODE

In production mode, there is four machine types: there is are autoscaler machines, there are webserver machines, there is a database server and there's a build machine upon which the build is initiated.
The autoscaler machine monitors the webservers for responsiveness and is responsible for initiating (and performing) the build of new servers according to scaling criteria (statically defined).
The webservers have their ip addresses registered with a DNS system and load balancing between them performed using round robin. 
The Database server is resposible for runnng the database system. The Database system can use DBaaS managed databases but it still needs to run in such a scenario.
All machines can only be connect to through SSH and are firewalled off in all other regards. There is a configuration directory shared between all machines using S3FS or EFS if you are on AWS.

### FIREWALLING  

The firewalling by default works as follows, there are two layers to the firewalling, the cloudhost's native firewall and the ufw firewall running on the machines themselves:

All machines allow SSH connections from your build machine and between each other only.  
Only webservers and autoscaler can connect to the database port (2035 by default)  
If you are using a managed database, either only machines in your private network can connect to the managed DB or the specific ip addresses of your webservers/database machine.  
If you are using Cloudflare, only Cloudflare ip addresses [Cloudflare IPs](https://www.cloudflare.com/en-gb/ips/) can connect to your webserver. Direct connections are not allowed to your webserver, only connections through the "Cloudflare Proxy". If you are not using Cloudflare, then, connections to ports 443 and 80 are allowed from anywhere. Cloudflare does provide some attractive features such as your being able to use "zero trust acccess control" to prevent direct access to anything that you don't explicitly allow. The similar solution I have provided for naked DNS systems is the Gateway Guardian (which uses basic auth) and possibly there is the idea of using a registration server.  

### ADDITIONAL THOUGHTS  

On both the development mode and production mode application backups can be made from the webservers and the database machines. 
Cron is used to schedule system processes on all machines and there is a defined process for application development workflow starting in development mode and working up towards full production deployments with multiple webservers.
Applications can be deployed from baselines or from temporal backups depending on your needs. Temporal backups should always be private to your organisation where as baselines can be made public **(with appropriate care taken not to have sensitive credentials in the codebase/SQL dump)** and yes by 3rd parties, possibly for a fiscal price.  
