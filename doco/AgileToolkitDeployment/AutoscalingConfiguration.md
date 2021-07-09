You can configure the number of webservers that are running in the file ${HOME}/config/scalingprofile/profile.cnf 

If you are using static scaling, you can cofigure the scripts:

${HOME}/providerscripts/utilities/DailyScaledown.sh  

${HOME}/providerscripts/utilities/DailyScaleup.sh  

from within cron to set how and when to scale up and scale down on a daily basis.

##### NOTE1: if you have more than one autoscaler running, then, you will need to alter the configuration of cron on all of them for this to work reliably. 

You can configure the toolkit to deploy several autoscalers at the same time. This has a couple of effects. If you are concerned about resilence, a single autoscaler in this design would be a single point of failure. If you run more than one, you have the safety of having the others as backups should one machine fail. Secondly, when using static scaling, you can scale up more quickly because the autoscalers will be provisioning webservers in tandem. The more autoscalers you have (they only need to be small capacity machines) the faster your system will scale up and scale down. 

#### NOTE2: The profile.cnf needs to be a different size for changes to be picked up
If you look at the scripts ${HOME}/providerscripts/utilities/DailyScaledown.sh and ${HOME}/providerscripts/utilities/DailyScaleup.sh you will see that they append a space at the end of the file each time they run. This is to modify the number of bytes in the file. For example if you change the NO_WEBSERVERS parameter from 2 to 5 the actual number of bytes in the file won't have changed and the s3fs system won't pick up that the file has been changed. So, by appending a space each time it changes the number of bytes and makes sure the change is reflected everywhere. Also, if you update the file ${HOME}/config/scalingprofile/profile.cnf manually you should make sure that the number of bytes in the file is altered which you can do by adding or removing a space. 
