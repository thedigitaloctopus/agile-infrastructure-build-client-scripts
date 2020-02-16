You can configure the number of webservers that are running in the file ${HOME}/config/scalingprofile/profile.cnf 

If you are using static scaling, you can cofigure the scripts:

${HOME}/providerscripts/utilities/DailyScaledown.sh
${HOME}/providerscripts/utilities/DailyScaleup.sh

from cron to set how and when to scale up and scale down on a daily basis. Note, if you have more than one autoscaler running, then, you will need to alter the configuration of cron on all of them for this to work reliably. 
