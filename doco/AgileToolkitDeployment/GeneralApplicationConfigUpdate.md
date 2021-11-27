If you want to update all your application configuration files at once across your websevers you can use the following technique:

Say you are running joomla on 6 webservers. 

You can ssh onto one of your webservers and go to 

**${HOME}/config**  

Using Joomla as an example, you can then edit 

**${HOME}/config/joomla_configuration.php**  

and immediately issue the commands:

**/bin/echo " " >> ${HOME}/config/joomla_configuration.php && /bin/touch ${HOME}/config/GLOBAL_CONFIG_UPDATE**  

The echo command is need if the byte size of the joomla_configuration.php file didn't increase or decrease when you edited it. S3FS doesn't pick up file changes unless the byte size has changed. 

Once you have issued all of these command, recheck

**${HOME}/config/joomla_configuration.php**  

That it is as you want it to be and wait a minute and your updates should be pushed out to all of your webservers in that time. As long as your update was valid, your webservers should still be online. 

