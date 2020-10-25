If you wanted to extend the core of the Agile Deployment Toolkit, here are some of the ways you could do it.

1) Include deployment option to Centos. 
This will require modifying the build client scripts and the autoscaler scripts to spin up instances of centos rather than 
ubuntu or debian. It will also require modification/extension of the scripts in the "installscripts" directory of all machine types to install for centos (using yum rather than apt-get). There might be other issues which I am not aware of which will need to be worked through to be able to successfully deploy to centos. 

2) Add new application types. There's hundreds of applications out there which as long as they follow a design pattern similar to 
Joomla or Wordpress should be easy enough to integrate. I think it should take (as long as the application doesn't have a lot of 
idiosyncracies a practised developer about 1 week of work to integrate a new application type).

3) Inclusion of deployments to further VPS cloudhosts, perhaps rackspace, googlecloud, microsoft azure and you know, there's a lot more out there. 

4) Possibly extend the scaling process to use dynamic scaling with providers that support it, this would enable applications with unpredictable workloads to be deployed.

5) Provide a templating mechanism such that servers can be built of a file based configuration process. This would give the option to bypass the question and answer process of the main method and to allow users to have a library of templates such that if they want to spin up a particular configuration, they just select a template from their library and go and get a cup of coffee and when they get back their servers will be ready. Templating is great because of the potential for time saving and reuse, but, if there are mistakes in the template then, obviously, the servers won't build. It would be nice therefore to write some validation processes such that a selected template is verified according to a spec and disallowed if there are aspects to how it is configured which violate the specification. Clearly, not everything can be checked, but, a fair amount of it can. I will probably be able to include templating as part of the first release, but, writing the templating validation code will likely be a future nice to have. A shortcut way to create templates is to follow the question and answer process and make a deployment to the configuration you desire. Under the buildconfiguration directory, the environment is dumped at the end of the build and those files are the basis of the templating mechanism. If you take a dump file like that you can copy it to the templates directory and make an official template out of it. With a library of templates, most scenarios can be templated for which makes the build process as firctionless and error free as possible. 
