If you want to update all your application configuration files at once across your websevers you can use the following technique:

Say you are running joomla on 6 webservers. 

You can ssh onto one of your webservers and go to 

**${HOME}/runtime**  

you can then 

**/bin/cp ${HOME}/runtime/joomla_configuration.php**  
**${HOME}/runtime/joomla_configuration.php.updating**  
**vi ${HOME}/runtime/joomla_configuration.php.updating**  

Make sure that the configuration is correct or it will take your application offline when you update  it.

Then, save the file you have edited and IMMEDIATELY ISSUE BOTH OF THE FOLLOWING COMMANDS TO INSTALL IT TO ALL YOUR WEBSERVERS:

**/bin/cp ${HOME}/runtime/joomla_configuration.php.updating ${HOME}/config/joomla_configuration.php**  
**/bin/touch ${HOME}/config/GLOBAL_CONFIG_UPDATE**  
**/bin/rm ${HOME}/runtime/joomla_configuration.php.updating**  
