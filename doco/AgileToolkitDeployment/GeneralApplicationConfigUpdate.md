If you want to update all your application configuration files at once across your websevers you can use the following technique:

Say you are running joomla on 6 webservers. 

You can ssh onto one of your webservers and go to 

**${HOME}/config**  

Using Joomla as an example, you can then edit 

**${HOME}/config/joomla_configuration.php**  

and immediately issue the commands:

**/bin/echo " " >> ${HOME}/config/joomla_configuration.php && /bin/touch ${HOME}/config/GLOBAL_CONFIG_UPDATE**  

The echo command is need if the byte size of the joomla_configuration.php file didn't increase or decrease when you edited it. S3FS doesn't pick up file changes unless the byte size has changed. 
