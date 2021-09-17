In order to allow access just to your laptop's ip address to your build machine, you can provider a list of line separated ip addresses.

To do this, in the root of your datastore, you need to create a bucket authip-${BUILD_IDENTIFIER} and in that bucket you need to create a file authroised-ips.dat

In the authorised-ips.dat file you need to put the ip address of your laptop or desktop machine and if you ip address changes, then, you need to update the allowed
ip addresses to include the new ip address. This means that only your allowed ip addresses can access your build machine which is more secure than allowing any ip address to access your ssh port.

If you don't provide such a file in the authip-${BUILD_IDENTIFIER} bucket, then, connections through ssh are allowed from any ip address. 

The build machine will run a cron task to check for new updates to your allowed ip addresses. In this way you can update the authip-${BUILD_IDENTIFIER} file in order to allow additional ips to connect to your build machine if for example your laptop needs access as well as your colleagues laptop.

It is highly recommended to take the time to create such a file. 
