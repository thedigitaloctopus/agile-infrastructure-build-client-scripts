If you want to globally update your applications configuration settings when it is deployed with multiple webservers in production mode, you can ssh onto any webserver using the helperscripts on the build client and update the configuration file that you find in the config directory on the webserver, for example in the case of wordpress:

${HOME}/config/wordpress_config.php

Once you have updated your configuration, you need to tell the toolkit to push the changes out to the configuration files of each webserver. 
You can do that with precisely the following command:

/bin/touch ${HOME}/config/GLOBAL_CONFIG_UPDATE
