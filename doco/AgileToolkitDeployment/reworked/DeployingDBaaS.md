#### IMPORTANT: Don't necessarily expect your DB dump files to automatically import from one DBaaS provider to another without first manually verifying it first. Each DBaaS provider may put things in the dump files which only work correctly within the configuration of their system. 

#### NOTE: The "database layer" is still deployed with or on your cloudhost VPS when you use DBaaS. It is functionally redundent in terms of application operation but, it is how the "backup" part of the architecture works, so the DB layer is still deployed so that the backup process runs and completes successfully and gives you backups as usual of your DB even though you are using DBaaS. Probably your DBaaS provider has its own mechanism for backups also, but, when we deploy using the Agile Deployment Toolkit, we depend on our bespoke backup and archiving mechanism, so it is essential that the backups still take place for the toolkit to function correctly. Whilst we do take backups in a specific way which the toolkit depends on for its operation, you can take independent additional backups (which is recommended in important systems) using the backup process provided by your "managed database" service provider.  

#### Recommendation. You should only ever use DBaaS direct to the managed database itself and within a private network of your cloudhost provider. This means, however, that you are tied to only using cloudhosts with a managed DB service offering if you want to use a managed DB service rather than running and configuring your own. I have provided a way, though, if you are prepared for a performance hit and also a little bit of configuration work where if your cloudhost of choice doesn't provide a managed database service, you can set up an SSH tunnel to any managed database provider of your choice. If you go into the code, it should be clear how this is working, but, I describe it here briefly.

----------------------------------------------------------------------

AWS or "Amazon Webservices". If you want to have your database service with Amazon, there's some steps to go through.

Before you run the Agile Deployment Toolkit build scripts, what you need to do, is get your database instance up and running with Amazon, so assuming you have a valid and active account with Amazon here are the steps.

1) Select the RDS service.
2) Using standard mode and NOT easy mode, decide what type of database you are deploying, MySQl, Postgres and so on and select it.
3) Set the size and so on of your database and review all the settings of your database.
4) Set the username, password and name of your database. Make a note of them as you will need them for the agile deployment script.
5) Set the availability zone and port of the database (if you forget this, you can modify it post deployment). 
6) Grant security access to the security group that our webservers belong to (AgileDeploymentToolkitSecurityGroup) and set a VPC which is accessible by this security group. If there is no "AgileDeploymentToolkitSecurityGroup" create a new one with that precise name, "AgileDeploymentToolkitSecurityGroup".
7) Deploy the database instance, it will take a bit of time.
8) Once the 'endpoint' becomes available, make a note of it, minus the colon and port number at the end of it.
9) Once the amazon database is all set for you, run the agile deployment toolkit and use the credentials and so on that you have set up as parameters to the script when appropriate.

##### ESSENTIAL- Make sure you set the DB port in the Agile Deployment Scripts configuration process to be the same as the port you chose when you deployed your RDS instance with Amazon. 

--------------------------------------------------------------------------




