If you want to globally update your applications configuration settings when it is deployed with multiple webservers in production mode, you can ssh onto any webserver using the helperscripts on the build client and update the configuration file that you find in the config directory on the webserver, for example in the case of wordpress you can update the machine you are on by editing one of the following files and waiting for a minute:

**${HOME}/runtime/wordpress_config.php**  
**/var/www/html/configuration.php**  

To update the configuration for your application on all of your webservers, VERY CAREFULLY, if your configuration settings are wrong it will hose your whole site,

Edit: **${HOME}/config/wordpress_config.php** and make your changes

then issue the command: 

**/bin/touch ${HOME}/config/GLOBAL_CONFIG_UPDATE**
