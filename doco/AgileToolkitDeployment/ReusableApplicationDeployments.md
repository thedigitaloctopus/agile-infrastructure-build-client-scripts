The objective of buiding the Agile Deployment Toolkit was to be able to easily redeploy an application several times. Say you had a town and you wanted to deploy an application to each postcode area of the town, so, you might deploy to postcode1.town.uk, postcode2.town.uk and so on. What you can do with the Agile Deployment Toolkit is to develop the application once and literally by changing the subdomain in the template file or when you run the main script, you can deploy the same application to postcode1 and postcode2 and to any other postcode. This is effectively application reuse. Develop once, deploy many which can save us a lot of trouble. This makes it possible to have libraries of the highest quality reusable applications instead of perhaps starting from scratch each time. 

So, if we want to create a reusable application, how do we do it?

1. Make your application reusable by editing or writing the following scripts:

a) On the Buildclient, register your application identifier by modifying the "ApplicationIdentifier.sh" script following the pattern as for the example applications.
b) For your Webserver and database, modify the scripts under ${HOME}/applicationscripts following the examples that have been given. You can add any additional customisations for your application here also. 

2. Assuming that we want to create a reusable wordpress application, deploy a virgin wordpress instance using the Agile Deployment Toolkit in development mode. Select the APPLICATION_IDENTIFIER, when prompted that you setup in step 1.

3. Develop your application from there until you are happy with it. 

4. Once you have developed your application, you need to baseline it. Please review ApplicationWorkflow.md which contains a description of how to baseline an application

5. Once you application is baselined, anyone with access to it (make sure your code doesn't contain any senstive credentials if you are going to make it public) can deploy from that baseline. 
