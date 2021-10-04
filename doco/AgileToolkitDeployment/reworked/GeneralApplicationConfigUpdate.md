If you want to update all your application configuration files at once across your websevers you can use the following technique:

Say you are running joomla on 6 webservers. 

You can ssh onto one of your webservers and go to 

**${HOME}/runtime**

you can then 

**vi ${HOME}/runtime/joomla_configuration.php**

Make sure that the configuration is correct or it will take your application offline.

Then, save the file you have edited and IMMEDIATELY ISSUE THE FOLLOWING COMMANDS TO PUSH IT TO ALL YOUR WEBSERVERS:

**/bin/cp ${HOME}/runtime/joomla_configuration.php ${HOME}/config/joomla_configuration.php**
**/bin/touch ${HOME}/config/GLOBAL_CONFIG_UPDATE**
