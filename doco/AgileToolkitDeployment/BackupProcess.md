1. No time based backups for virgin deployments - make baselines
2. When deployed from baseline or another time based backup, time based backups are made
3. Super Safe
4. Making a baseline

Application development life cycle

Install a virgin CMS (Joomla, Wordpress, Drupal or Moodle)
Develop your applications making periodic manual baselines using the baselining script (on the build machine)
Once the application is developed, make a time based backup by running the backup script.
Shutdown your servers and make a live deployment by deploying from your hourly backup made in 3. 
Run you application
