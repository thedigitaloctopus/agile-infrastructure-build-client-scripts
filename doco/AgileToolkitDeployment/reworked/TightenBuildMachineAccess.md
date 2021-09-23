#### HOW TO TIGHTEN BUILD MACHINE ACCESS  

Your build machine (the one that your user-data script gets run on) contains a lot of senstive data pertinent to your webservers and databases. By default all ports are firewalled off on it except for the SSH port you have selected. By default this SSH port accepts connections from anywhere. This is still secure because you need the ssh key you set in your user-data script to be able to authenticate, but still, you can get pests trying brute force against your machine. Ideal then, we want to firewall it complete except for the ip addresses of the machines that we actually own and want to connect from.   


So, it will work fine by default, but, if you want to go the extra mile you can do the following:  

1. Install S3CMD on your laptop/desktop and configure it so it can access your S3 compatible object store for your cloudhost.  
  
3. Create a bucket on your datastore called  

##### s3://authip-${BUILD_IDENTIFIER) 

where the build identifier is the build identifier that you gave to the particular build you want to access (you will need to create a bucket for each build you want to protect if you have multiple builds on the same machine).  

4. Edit a file (authorisedips.dat) on your laptop and on separate lines put the ip addresses of each machine you want to grant access rights to your build machine to. So, if your laptop ip address is 111.111.111.111 and your colleagues laptop ip address is 222.222.222.222 then your file will look like:  
   
  ##### 111.111.111.111  
  ##### 222.222.222.222  
   
5. Upload this file to your s3 

   ##### /usr/bin/s3cmd put authorised-ips.dat s3://authip-${BUILD_IDENTIFIER}/authorised-ips.dat. 
   
The file must be named that precisely for the build machine to pick it up and reconfigure or tighten the firewall. You can grant and revoke access to different ip adresses by reuploading or uploading a different authorised-ips.dat file to the correct S3 bucket. This means your build machine can't be accessed from any ip address except for the ones that you authorise. A bit of a process, but, once its done you are all set. 
