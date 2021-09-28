The normal process for deploying an application would be as follows:

1. Choose your cloudhost and deploy a virgin copy of your chosen CMS, Wordpress, Joomla, Moodle or Drupal.
2. Once your virgin CMS is deployed, build your application using the CMS taking baselines of your application as needed to ensure you have backups of it. Once your application is ready, take a final baseline of it. Occasionally redeploy this baseline and update the plugins/extensions it is using and generate a new baseline from the updated code. Take your servers offline and then proceed to step 3. 
3. Deploy your baseline as a "live site" and run the build machine process to create backups of the baseline, this will create HOURLY,DAILY,WEEKLY,MONTHLY,BIMONTHLY backups of your application as a starting position. Once the backups are complete, take your servers offline.
4. Redeploy from one of the backups made in 3 as a "full deployment" to enable access to autoscaling features and so on. The sytem will then make periodic backups as your users interact with your website. 
