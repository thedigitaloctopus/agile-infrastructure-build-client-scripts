In order to allow access just to your laptop's ip address to your build machine, you can provider a list of line separated ip addresses.

To do this, in the root of your datastore, you need to create a bucket ${BUILD_IDENTIFIER}-adt and in that bucket you need to create a file authroised-ips.dat

In the authorised-ips.dat file you need to put the ip address of your laptop or desktop machine and if you ip address changes, then, you need to update the allowed
ip addresses to include the new ip address. This means that only your allowed ip addresses can access your build machine which is more secure than allowing any ip address to access your ssh port.
If you don't provide such a file in a bucket, then, connections through ssh are allowed from any ip address. 

${BUILD_IDENTIFIER}/adt/authorised-ips.dat

The build machine will run a cron task to check for new updates. 
