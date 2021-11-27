If you want to update all your application configuration files at once across your websevers you can use the following technique:

Say you are running joomla on 6 webservers. 

You can ssh onto one of your webservers and go to 

**${HOME}/runtime**  

Using Joomla as an example, you can then edit 

**/bin/cp ${HOME}/runtime/joomla_configuration.php ${HOME}/runtime/joomla_configuration.php.new**  

Issue the command 

**run ${HOME}/providerscripts/utilities/PushGlobalUpdate.sh "joomla_configuration"**

That it is as you want it to be and wait a minute and your updates should be pushed out to all of your webservers in that time. As long as your update was valid, your webservers should still be online. 

