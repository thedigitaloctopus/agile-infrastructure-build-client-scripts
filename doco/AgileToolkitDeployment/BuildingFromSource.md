You have the choice to build certain compoenents of the toolkit from source or from the regular repositories. 
The advantage of building from source is that it gives you more control and you can use the very latest versions of software that the repos haven't caught up with yet which can be more secure. The disadvantage is that it is more complex and there is more that might go wrong and also the machines can take longer to build and deploy. 

In order to configure how you want each eligible component to be built you need to edit the file ${BUILD_HOME}/buiddescriptors/buildstyles.dat in your fork.

The settings work as follows:

#### The set of possible configurations you could have are as follows:
-----
##### If you are building for NGINX you can select one of:
-----
##### NGINX:source
##### NGINX:repo
##### NGINX:source:modsecurity
##### NGINX:repo:modsecurity
-----
##### If you are building for APACHE you can select one of:
-----
##### APACHE:source
##### APACHE:repo
##### APACHE:source:modsecurity
##### APACHE:repo:modsecurity
-----
##### If you are building for lighttpd you can select one of:
-----
##### LIGHTTPD:source
##### LIGHTTPD:repo
-----
##### If you are building for postgres, you can select one of:
-----
##### POSTGRES:source
##### POSTGRES:repo
