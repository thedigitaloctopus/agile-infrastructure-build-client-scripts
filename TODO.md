If you wanted to extend the core of the Agile Deployment Toolkit, here are some of the ways you could do it.

1) Include deployment option to Centos. 
This will require modifying the build client scripts and the autoscaler scripts to spin up instances of centos rather than 
ubuntu or debian. It will also require modification/extension of the scripts in the "installscripts" directory of all machine types to install for centos (using yum rather than apt-get). There might be other issues which I am not aware of which will need to be worked through to be able to successfully deploy to centos. 

2) Add new application types. There's hundreds of applications out there which as long as they follow a design pattern similar to 
Joomla or Wordpress should be easy enough to integrate. I think it should take (as long as the application doesn't have a lot of 
idiosyncracies a practiced developer about 1 week of work to integrate a new application type).

3) Inclusion of deployments to further VPS cloudhosts, perhaps rackspace, googlecloud, microsoft azure and you know, there's a lot more out there. 

4) Possibly extend the scaling process to use dynamic scaling with providers that support it, this would enable applications with unpredictable workloads to be deployed. 
