If you want to update all your application configuration files at once across your websevers you can use the following technique:

Say you are running joomla on 6 webservers. 

You can ssh onto one of your webservers and go to 

**${HOME}/config**  

Using Joomla as an example, you can then edit 

**${HOME}/runtime/joomla_configuration.php**  

and immediately issue the command:

**/bin/touch ${HOME}/config/GLOBAL_CONFIG_UPDATE**  
