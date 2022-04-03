If you wanted to extend the core of the Agile Deployment Toolkit, here are some of the ways you could do it.

1) Include deployment option to for other flavours of linux. 
This will require modifying the build client scripts and the autoscaler scripts to spin up instances of the other linux flavour rather than 
ubuntu or debian. It will also require modification/extension of the scripts in the "installscripts" directory of all machine types to install for your chosen flavour of linux (perhaps using yum rather than apt-get). There might be other issues which I am not aware of which will need to be worked through to be able to successfully deploy with a version of linux other than ubuntu or debian. 

2) Add new application types. There's hundreds of applications out there which as long as they follow a design pattern similar to 
Joomla or Wordpress should be easy enough to integrate. NOTE: I haven't been able to get Joomla 4 beta to run properly yet, so if anyone wants to take a look at that, that would be great because it would be cool to have joomla 4 running on here. The problem I faced was being logged out of the backend all the time, I am not quite sure why, it may be that there's something simple I don't know about. Put it this way, it might take me a month to integrate and test one additional application and I am very familiar with the ADT. To update the toolkit to possibly support an additional 100 applications, it would take me 100 months of continuous work which, well, you know at my age, I might never see it through, but, if 100 skilled developers are put on the task though it can be done and dusted within at the most 3 months. So, that's my request really, as many linux devs as are interested putting their time in to help the ADT support a wider variety of applications.  

3) Inclusion of deployments to further VPS cloudhosts, perhaps rackspace, googlecloud and so on and as you know, there's a lot more out there. 

4) Possibly extend the scaling process to use dynamic scaling with providers that support it, this would enable applications with unpredictable workloads to be deployed. It would involve, for example, using the AWS CLI to provision scaling groups for webservers and so on via the ADT autoscaler machine. 

5) See if there are more providers than just Cloudflare that can be integrated for DNS services with proxy server protection and so on. 

6) Integrate more email service providers than are currently supported. 

