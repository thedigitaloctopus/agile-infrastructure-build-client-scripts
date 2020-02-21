There are several different deployment scenarios that might play out:

1. Virgin Build - This type of build should be deployed in deployment mode. It will deploy one webserver and possibly a database and so on, depending on your use case. With this done, you can develop your application and at the end of the process, you can
generate a baseline using the git scripts supplied on the webserver and the database server. You can access your machines using
the helper scripts on the build client and you will find the scripts for generating the baselines under ${HOME}/providerscripts/git

2. Baseline Build - This is the type of build you would want if you are deploying a new instance of an application you have built. 
You would have built the application using a virgin build and then baselined it. From that baseline, you can do as many fresh
deployments as you like. A baseline build can take a considerable amout of time to complete depending on the scenario.

3. Hourly Build - In an hourly build (representative of any of the build from backup scenarios), the assets for the application should already persist in the datastore, either from the baseline build or from active usage of the application.  

N.B. As all the assets for the application are stored in buckets, you have the option to use them for sources to a CDN. The CDN,
if your application supports it, can help with server load as the assets are retreived from the CDN. If you can use a CDN, then your application won't need to use s3fs over the network to access your assets from the remote bucket. It is assumed that in the usual case, you will use a CDN, but, that in some cases, CDN usage is not possible and so, s3fs is a solution to that. 
  
