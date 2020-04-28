Applications usually need updating from time to time with plugin updates or extension updates.
If you are in developer mode, this is no problem.
If you are in production mode with multiple webservers running, then, when you update a plugin, it will update the file system of a particular webserver and the toolkit will then replicate those updated files to the other webservers within 10 minutes

ESSENTIAL NOTE: application plugins and extensions should not be updated during scaling events. Make sure you have a stable server set before updating your plugins as there's a slight chance of inconsistency if a update is made to the application during a scaling event. 

All active webservers should have been online and resposive for 20 minutes before any application plugins or extensions are updated. 
