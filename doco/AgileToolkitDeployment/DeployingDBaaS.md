#### IMPORTANT: Don't necessarily expect your DB dump files to automatically import from one DBaaS provider to another without first manually verifying it first. Each DBaaS provider may put things in the dump files which only work correctly within the configuration of their system. 

#### NOTE: The "database layer" is still deployed with or on your cloudhost VPS when you use DBaaS. It is functionally redundent in terms of application operation but, it is how the "backup" part of the architecture works, so the DB layer is still deployed so that the backup process runs and completes successfully and gives you backups as usual of your DB even though you are using DBaaS. Probably your DBaaS provider has its own mechanism for backups also, but, when we deploy using the Agile Deployment Toolkit, we depend on our bespoke backup and archiving mechanism, so it is essential that the backups still take place for the toolkit to function correctly. Whilst we do take backups in a specific way which the toolkit depends on for its operation, you can take independent additional backups (which is recommended in important systems) using the backup process provided by your "managed database" service provider.  

#### Recommendation. You should only ever use DBaaS direct to the managed database itself and within a private network of your cloudhost provider. This means, however, that you are tied to only using cloudhosts with a managed DB service offering if you want to use a managed DB service rather than running and configuring your own. 

----------------------------------------------------------------------

#### RDS GUI BASED DATABASE DEPLOYMENT ON AWS

Before you run the Agile Deployment Toolkit build scripts, what you need to do, is get your database instance up and running with Amazon, so assuming you have a valid and active account with Amazon here are the steps.

1. Navigate to the RDS service offering page

2. Select "Standard create"

3. Select which database you want, "mysql", "mariadb" or "postgres"

4. Select if you want "dev/test" or full production mode

5. Give some credentials for your new database (Note these must be unique in the ADT's code base, because if you use the username "admin" for example, that will hose the search and replace that we do later on on your codebase). So something like, "adminXYZ123" would be OK because it is likely unique.So, give a unique database identifier, username and password.
	
6. Pick the size of machine you want for your database (be aware of costs).

7. Configure your storage (how many GBs)

8. Enable or disable autoscaling for your database.

9. Select whether you want a standby instance or not

10. Select the same VPC as your EC2 instances are running in or will be running in

11. Select the default-vpc subnet group for your VPC selected in 10.

12. Select "no" for publicly accessible

13. If you don't have a security group create one with the precise name "AgileDeploymentToolkitSecurityGroup" and that will place your database in the same VPC security group as your webservers when they are built, thereby giving them access to your database.

14. Pick your availability zone

15. Select password authentication.

16. Make a note of your database username, database password and database port. Once the database has initiated, make a note of the database endpoint (minus the port number if it is part of it) and use these credentials/variables as part of your build process whether it is a full build, an expedited build or a hardcore build. 

17)  
    a) For the full build, you can enter your database details when promppted for as part of the build process.  
    
    b) For an expedited build you will need to set the following parameters in your template  
       
       DATABASE_INSTALLATION_TYPE="DBaaS"  
       DATABASE_DBaaS_INSTALLATION_TYPE=""  
       DBaaS_HOSTNAME=""  
       DBaaS_USERNAME=""  
       DBaaS_PASSWORD=""   
       DBaaS_DBNAME=""  
       DB_PORT=""  
    
    c) For a hardcore build you will need to set the following parameters in your user data script  
    
       DATABASE_INSTALLATION_TYPE="DBaaS"  
       DATABASE_DBaaS_INSTALLATION_TYPE=""  
       DBaaS_HOSTNAME=""  
       DBaaS_USERNAME=""  
       DBaaS_PASSWORD=""  
       DBaaS_DBNAME=""  
       DB_PORT=""  

Here's an example of what these values looked like in a template of a test build I was making:

       export DBaaS_HOSTNAME="adtdatabase1.crvxjfddo74b.eu-west-1.rds.amazonaws.com"
       export DBaaS_USERNAME="adtuser"
       export DBaaS_PASSWORD="12oighvcgh7HJghsPoe"
       export DBaaS_DBNAME="adtdemodb"
       export DATABASE_DBaaS_INSTALLATION_TYPE="MySQL"
       export DBaaSDBSECURITYGROUP="AgileDeploymentToolkitSecurityGroup"
       export DB_PORT="2035"

##### ESSENTIAL- Make sure you set the DB port in the configuration process to be the same as the port you chose when you deployed your RDS instance with Amazon. 

--------------------------------------------------------------------------




