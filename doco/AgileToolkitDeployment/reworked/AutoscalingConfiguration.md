You can configure the number of webservers that are running in the file **${HOME}/config/scalingprofile/profile.cnf**  

In most circumstances you will want to ssh onto your build machine and run the script: 

**${BUILD_HOME}/helperscripts/AdjustScaling.sh**

to adjust the scaling criteria in real time. 

You can also configure the scaling process to intiate at set times in the day. For example, you might want to scale up from 3 to 8 webservers at 7:30AM each day and scaled down from 8 to 3 again at 5:30 pm. You can use these scripts by going onto your autoscaler machine and doing a crontab -e to edit them and (possibly) alter the perioidicity at which they activate. 

**${HOME}/providerscripts/utilities/DailyScaledown.sh**  

**${HOME}/providerscripts/utilities/DailyScaleup.sh**  

from within cron to set how and when to scale up and scale down on a daily basis. If you want to set more scaling options automatically, you could, for example, make a copy of the **DailyScaleUp.sh** script and call it "MiddayScaleup.sh" and set a scaling event in cron such that there would be a daily scale up as well as your DailyScaledown and DailyScaleup

#### NOTE: The profile.cnf needs to be a different size for changes to be picked up by s3fs

I have taken steps to make this so by adding (and removing) spaces from **profile.cnf** from cron such that to trigger the s3fs system and reflect changes across all machines, the byte count of the file varies and therefore changes are picked up and reflected. 
