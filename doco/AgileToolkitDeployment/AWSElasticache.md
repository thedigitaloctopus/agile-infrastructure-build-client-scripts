If you are deploying to the AWS cloud, you might like to use AWS Elasticache as a memcached or redis solution to your application's caching needs.
To do this, you simply have to 
1) If there is a security group with the group name "AgileDeploymentToolkitSecurityGroup" already existing delete it using the AWS console.
2) Create a new security group which must be called precisely, "AgileDeploymentToolkitSecurityGroup" and assign it to a VPC
3) Create your elasticache cluster in and assign it to the security group you created in 2.
4) Make a note of which subnet your elasticache cluster is in by looking in its assigned subnet group
5) Back on the build client, select that you want to use caching and assign the security group id from your new security group.
6) Again on your build client, when you select your EC2 subnet when prompted, make sure it is the same subnet as in 4.