Adding a new application is a fairly involved process, but it's not too difficult in most cases. There's a procedure that you need to follow and as long as the application itself isn't too quirky, it should work OK. Here are the steps

1) To the BUILD CLIENT scripts, update the file initscripts/InitialiseBuildChoice.sh. You need to add a new action to the case statement which switches on  ${BUILD_CHOICE} in the case where it is set to 0. You can add your application here following what has been done for other applications.
  Also, around about line 30-40 of initscripts/InitialiseBuildChoice.sh enable a new choice switch for your new application. 
  For example Joomla is choice 1.

2) Now, still on the BUILD CLIENT scripts, you need to update 

${BUILD_HOME}/providerscripts/application/WhichApplicationByGitAndBackup.sh
${BUILD_HOME}/providerscripts/application/WhichApplicationByGitAndBaseline.sh
${BUILD_HOME}/providerscripts/application/WhichApplicationByDatastoreAndBaseline.sh
${BUILD_HOME}/providerscripts/application/WhichApplicationByDatastoreAndBackup.sh

I could have condensed these files but it's clear enough like this. You just need to update them as has been done for other applications for your own application. 
It is recommended that you use directories in the root of the application installation which uniquely identify it as an installation of that type. As an example, for drupal, I chose 'core' 'modules' profiles' to test on which you can see as an example in the scripts. So, grab yourself a copy of that application you are intalling, extract it on your local computer and identify the directories you want to test on. 

If we are a virgin, we already know what application we are running because we configured it at build time

N.B. If you are updating the DIRECTORIES_TO_MOUNT variable with paths that have subdirectories, for example, I think wordpress is something like wp-content/uploads then the / delimiter in the path name needs to be replaced with a . (a full stop or period). This is then substituted where needed for a / again as needed on the servers and is already set for use with the Datastore providers that the data will be stored in some of whom only accept ascii and the - and . characters. 
As you can see the wordpress example already has a - in the wp-content part and so this would confuse the meaning so it only left the . subsitution viable.

Hopefully, no directory names for an application will have a . in them. Certainly it would be kinda weird if they did. 

3) In the scripts for the WEBSERVER, you will find a directory: ${HOME}/providerscripts/application/configuration. In this directory, you will find subdirectories for each of the applications which the agile deployment toolkit has been configured to support. You need to add a directory for your new application following the examples of the other applications which have already been installed. .

You then need to do the same for these directories: 

    ${HOME}/providerscripts/application/processing to install your application.
    ${HOME}/providerscripts/application/monitoring to install your application.
    ${HOME}/providerscripts/application/customise to install your application.
    ${HOME}/providerscripts/application/configuration to install your application.
    ${HOME}/providerscripts/application/email to install your application.


NB. Please do not create any directories in these directories which are not application directories. The script looks for subdirs and assumes that any subdirectory is the directory of an appilcation. If you make a subdir, bitsandbobs, then the script will try and treat is like an application. It's not something that could break it, but in the philosophy of neatness, well, you see what I mean.

4) On the WEBSERVER, update ${HOME}/providerscripts/webserver/InstallWebserver.sh so that each webserver has the correct confgiuration for your application. Some applications require specific settings in the webserver configuration to function properly.

Should be somewhere around line number 222  of InstallWebserver.sh where you need to add a conditions for your application so the correct configuration code gets installed for your application.
