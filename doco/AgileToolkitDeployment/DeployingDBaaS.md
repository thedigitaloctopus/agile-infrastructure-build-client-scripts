##### IMPORTANT: Don't necessarily expect your DB dump files to automatically import from one DBaaS provider to another without first manually verifying it first. Each DBaaS provider may put things in the dump files which only work correctly within the configuration of their system. 

##### NOTE: The "database layer" is still deployed with or on your cloudhost VPS when you use DBaaS. It is functionally redundent in terms of application operation but, it is how the "backup" part of the architecture works, so the DB layer is still deployed so that the backup process runs and completes successfully and gives you backups as usual of your DB even though you are using DBaaS. Probably your DBaaS provider has its own mechanism for backups also, but, when we deploy using the Agile Deployment Toolkit, we depend on our bespoke backup and archiving mechanism, so it is essential that the backups still take place for the toolkit to function correctly. Whilst we do take backups in a specific way which the toolkit depends on for its operation, you can take independent additional backups (which is recommended in important systems) using the backup process provided by your "managed database" service provider.  

###### Recommendation. You should only ever use DBaaS direct to the managed database itself and within a private network of your cloudhost provider. This means, however, that you are tied to only using cloudhosts with a managed DB service offering if you want to use a managed DB service rather than running and configuring your own. I have provided a way, though, if you are prepared for a performance hit and also a little bit of configuration work where if your cloudhost of choice doesn't provide a managed database service, you can set up an SSH tunnel to any managed database provider of your choice. If you go into the code, it should be clear how this is working, but, I describe it here briefly.

There are lots of cloud hosting providers who provide DBaaS. So, there's a few hoops to jump through, however. When you access DBaaS using a mysql client if you are doing so over the internet. The problem is that whilst the mysql obviously has usernames and passwords, the connection itself isn't encrypted and so the data you are sending to your database is visible to any would be snooper. To get around this, we have to use SSH tunnels. The way it is set up is you deploy your database of required size and so  on with your DBaaS provider. The next step, then, is to deploy a VPS cloud host server with your DBaaS provider that is in the
same region as your database. What we can then do is setup an ssh key and connect using an SSH tunnel to the cloudhost server which proxies it to the database instance. Is that clear? So, using rackspace as an example, we would start up our, for example, mariadb Instance, that is all we have to do, figure out what size we need and create it through the databases menu. We then set up our Rackspace VPS server ssh tunnelling machine (and make sure it has enough clout to deal with the encryption) with an ssh key for authentication. All we then need to do is give the ssh private key (and other required parameters) to our client scripts (on our application VPS systems, lets say Exoscale) and that enables them to set up and use the ssh tunnel to the Rackspace database instance.

So, that's how it works for rackspace. There are of course, other providers such as amazon and so on, so you can choose different providers but the process is basically the same. You can set up your database, you then setup your cloud server with an ssh key set and following that, you run your the agile deployment toolkit build scripts and there you go, you have an ssh tunnel set up to your database.

If you want to read more about ssh keys with rackspace, you can follow this link:

https://support.rackspace.com/how-to/connecting-to-a-server-using-ssh-on-linux-or-mac-os/

Simiarly, if you wish to use a different provider for your DBaaS, then you will or might need to review their documentation on SSH keys and so on, so that you set them up correctly. 

Every provider is a little different. If you want to access your database directly which is how it should be done, within the same private network with the same provider as your application VPS systems, you can do that, but be aware that because there is no SSH tunnel that if the DBaaS is over the internet. If you are accessing the DB directly without a local SSHtunnel proxy, then your communications will not be encrypted and therefore open to snooping. Whether this is acceptable or not depends on what you are doing. It is cheaper and faster, not to encrypt and go direct to the DB but in most situations, people are not prepared to risk their communications being snooped on. So, using rackspace as an example, if you want to access the DB directly from the public internet, make sure your DB has very strong passwords and so on, in the first instance. You can see more about this by reading this:

https://support.rackspace.com/how-to/connect-to-a-cloud-databases-instance/

With other service providers, it may be a little different. For example, with Amazon Web Services, what you find is that you can go direct to the database unencrypted, but what you have to do whitelist the IP address of the Security group of the machines you are connecting from in the security policy of the database. As we are connecting from possible numerous (autoscaled) ip addresses from our webservers as well as our applictions database VPS.

---------------------------------------------------------------------------------------------------------------------------------

Another example, then, might be AWS or "Amazon Webservices". If you want to have your database service with Amazon, there's some steps to go through.

Before you run the Agile Deployment Toolkit build scripts, what you need to do, is get your database instance up and running with Amazon, so assuming you have a valid and active account with Amazon here are the steps.

1) Select the RDS service.
2) Decide what type of database you are deploying, MySQl, Postgres and so on and select it.
3) Set the size and so on of your database and review all the settings of your database.
4) Set the username, password and name of your database. Make a note of them as you will need them for the agile deployment script.
5) Deploy the database instance, it will take a bit of time.
6) Grant security access to the security group that our webservers belong to
7) Once the 'endpoint' becomes available, make a note of it, minus the colon and port number at the end of it.
8) Once the amazon database is all set for you, run the agile deployment toolkit and use the credentials and so on that you have set up as parameters to the script when appropriate.

##### ESSENTIAL- Make sure you set the DB port in the Agile Deployment Scripts configuration process to be the same as the port you chose when you deployed your RDS instance with Amazon. 



