IMPORTANT: Ideally, you want your managed database to be on the same private network as your webservers. That way you can connect to it without using ssh tunnels which are requied if you go out to the public internet to establish a database connection.

IMPORTANT 2: Don't expect your DB dump files to automatically convert from one DBaaS provider to another without first manually verifying
it first. Each DBaaS provider may put things in the dump files which only work correctly with their system. 

NOTE: The "database layer" is still deployed with your cloudhost when you use DBaaS. It is functionally redundent in terms of application operation but, it is how the backup part of the architecture works, so the DB layer is still deployed so that the backup process runs and completes successfully and gives you backups as usual of your DB even though you are using DBaaS. Probably your DBaaS provider has it's own mechanism for backups also, but, when we deploy using the Agile Deployment Toolkit, we depend on our bespoke backup and archiving mechanism, so it is essential that the backups still take place for the toolkit to function correctly. 

There are lots of cloud hosting providers who provide DBaaS. So, there's a few hoops to jump through, however. When you access DBaaS using a mysql client, you are doing so over the internet. The problem is that whilst the mysql obviously has usernames and passwords, the connection itself isn't encrypted and so the data you are sending to your database is visible to any would be snooper. To get around this, we have to use SSH tunnels. The way it is set up is you deploy your database of required size and so  on with your DBaaS provider. The next step, then, is to deploy a VPS cloud host server with your DBaaS provider that is in the
same region as your database. What we can then do is setup an ssh key and connect using an SSH tunnel to the cloudhost server which proxies it to the database instance. Is that clear? So, using rackspace as an example, we would start up our, for example, mariadb Instance, that is all we have to do, figure out what size we need and create it through the databases menu. We then set up our cloudhost VPS server (make sure it has enough clout to deal with the encryption) with an ssh key for authentication. 
All we then need to do is give the ssh private key (and other required parameters) to our client scripts and that enables them to set up and use the ssh tunnel to the database instance.

So, that's how it works for rackspace. There are of course, other providers such as amazon and so on, so you can choose different providers but the process is basically the same. You can set up your database, you then setup your cloud server with an ssh key set and following that, you run your the agile deployment toolkit build scripts and there you go, you have an ssh tunnel set up to your database.

If you want to read more about ssh keys with rackspace, you can follow this link:

https://support.rackspace.com/how-to/connecting-to-a-server-using-ssh-on-linux-or-mac-os/

Simiarly, if you wish to use a different provider for your DBaaS, then you will or might need to review their documentation on SSH keys and so on, so that you set them up correctly. 

Every provider is a little different. If you want to access your database directly, you can do that, but be aware that because there is no SSH tunnel that DBaaS is over the internet. If you are accessing the DB directly without a local SSHtunnel proxy, then your communications will not be encrypted and therefore open to snooping. Whether this is acceptable or not depends on what you are doing. It is cheaper and faster, not to encrypt and go direct to the DB but in most situations, people are not prepared to risk their communications being snooped on. So, using rackspace as an example, if you want to access the DB directly from the public internet, make sure your DB has very strong passwords and so on, in the first instance. Secondly, in the case of rackspace, you will need to set up a loadbalancer to route the requests from the public internet to your database. You can see more about this by reading this:

https://support.rackspace.com/how-to/connect-to-a-cloud-databases-instance/

With other service providers, it may be a little different. For example, with Amazon Web Services, what you find is that you can go direct to the database unencrypted, but what you have to do whitelist the IP address of the machine you are connecting from in the security policy of the database. As we are connecting from possible numerous (autoscaled) ip addresses from our webservers as well as out database server, if we go this route, then we have to use the 0.0.0.0/0 whitelist which allows connections from everywhere. We could write scripts using CLIs and so on, to whitelist particular ip addresses, but I presumed this over complicate things. In nearly all circumstances, folks, should, therefore connect using an SSH tunnel which goes via the local database machine to the SSH tunnel proxy in the same cloud as the database and from the SSH tunnel proxy to the database. 

---------------------------------------------------------------------------------------------------------------------------------

Another example, then, might be AWS or "Amazon Webservices". If you want to have your database service with Amazon, there's some steps to go through.

Before you run the Agile Deployment Toolkit build scripts, what you need to do, is get your database instance up and running with Amazon, so assuming you have a valid and active account with Amazon here are the steps.

1) Select the RDS service.
2) Decide what type of database you are deploying, MySQl, Postgres and so on and select it.
3) Set the size and so on of your database and review all the settings of your database.
4) Set the username, password and name of your database. Make a note of them as you will need them for the agile deployment script.
5) Deploy the database instance, it will take a bit of time.
6) Give the database public accessibility capability and the scripts will restrict access to our webservers by ip address and port
7) Once the 'endpoint' becomes available, make a note of it, minus the colon and port number at the end of it.
8) Once the amazon database is all set for you, run the agile deployment toolkit

The second way is to have an SSH tunnel which then connects within the amazon cloud on their private network and so the database doesn't need to be public facing at all and all communications are encypted. There's obviously a performance hit for this as you are encrypting your datastreams and sending them over a WAN if your webservers are remote (not on AWS) and so, clearly this is a slow down. You need to make sure that the machine (ec2) which is acting as your ssh forwarder has enough compute power to be able to efficiently do the decryption of the incoming data streams which might be a bit pricier than you hoped for. In this case.

How to setup an SSH tunnel to an RDS instance on S3

1) Deploy an RDS instance of your required size and choice in the region you are in. As you are deploying the instance, make a note of the username, password and identifier that you set for the database. Make sure it is publicly accessible as we will be connecting to it from another ec2 instance. Select the default VPC Security group. Give the database a name and make a note of it and also record the port that you set (3306) by default as you will need to use this port again when you are running the deployment kit. Disable encryption unless you have something really really sensitive or something like GDPR requires your 
data is encrypted at rest. Launch you instance (which will take some minutes). 
2) Now. Spin up an ec2 instance in the same region. Generate a key pair and download it to your computer as you spin up the ec2 instance. You will the key as part of the deployment process. When your ec2 instance is listed on the far far right is its security group. Click on the security group link and ensure that the port 22 is world accessible (anywhere) for ssh.
3)Make a note of your ec2 instance's ip addresss and go to your rds instance again.  Under "instance actions" click "see details". Click on the security group of your instance and then edit the "inbound rules" so that it has a new rule for the ip address of your ec2 instance port 3306 (or whatever you have set as your  db port) for the TCP protocol using "custom" as the selector. Remember to add a "/0" to the end of the ip address of your ec2 instance. 
4)Optional: Add the private key to your client machine and connect to the ec2 instance you have started using your ssh keys. On there install mysql (apt-get install mysql-server) and attempt to connect to the rds instance you have set up from your ec2 instance. If it connects then you know that your ec2 instance can successfully communicate to the rds instance. 
5) In your agile deployment toolkit directory create a file ${BUILD_HOME}/ssl/${WEBSITE_URL}/dbaas_server_key.pem and paste in the private key for your ec2 instance that you downloaded from AWS. If it has any blank lines in it when you paste it (for some reason on my system it did), carefully remove them and save the file
6)Run through the build process answering the prompts as you ordinarily would for a Agile Deployment Toolkit build process. ESSENTIAL- Make sure you set the DB port to be the same as the port you chose when you deployed your RDS instance with Amazon. 

