You can configure the number of webservers that are running in the file ${HOME}/config/scalingprofile/profile.cnf 

If you are using static scaling, you can cofigure the scripts:

${HOME}/providerscripts/utilities/DailyScaledown.sh
${HOME}/providerscripts/utilities/DailyScaleup.sh

from within cron to set how and when to scale up and scale down on a daily basis.

##### Note, if you have more than one autoscaler running, then, you will need to alter the configuration of cron on all of them for this to work reliably. 

You can configure the toolkit to deploy several autoscalers at the same time. This has a couple of effects. If you are concerned about resilence, a single autoscaler in this design would be a single point of failure. If you run more than one, you have the safety of having the others as backups should one machine fail. Secondly, when using static scaling, you can scale up more quickly because the autoscalers will be provisioning webservers in tandem. The more autoscalers you have (they only need to be small capacity machines) the faster your system will scale up and scale down. 
