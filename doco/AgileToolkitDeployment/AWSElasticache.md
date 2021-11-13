#### Important: I haven't used AWS Elasticache in earnest and apparently it is expensive, so be very aware of costs if you decide to use Elasticache. Also, there are other caching solutions you can deploy to EC2 based on docker and so on which most probably just rack up the cost of the EC2 instances that it is running on which is likely cheaper.

If you are deploying to the AWS cloud, you might like to use AWS Elasticache as a Memcached or Redis solution to your application's caching needs.
To do this, you simply have to:

1) If there is a security group with the group name "**AgileDeploymentToolkitSecurityGroup**" already existing delete it using the AWS console.
2) Create a new security group which must be called precisely, "**AgileDeploymentToolkitSecurityGroup**" and assign it to a VPC.
3) Create your Elasticache cluster using the AWS GUI and assign it to the Security Group you created in 2.
4) Make a note of which subnet your Elasticache Cluster is in by looking in its assigned subnet group.
5) Back on the build client, (presuming you are using the full build method) select that you want to use caching and assign the security group id from your new security group. If you are using an Expedited or Hardcore build, you need to assign   
 **IN_MEMORY_CACHING=""  
IN_MEMORY_CACHING_PORT=""  
IN_MEMORY_CACHING_HOST=""  
IN_MEMORY_CACHING_SECURITY_GROUP=""**  
With values obtained from your Elasticcache cluster and refering the specification as well: [Specification](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/specification.md) 
6) Again on your build client, when you select your **EC2 subnet**, make sure it is the same **subnet** as in 4.
