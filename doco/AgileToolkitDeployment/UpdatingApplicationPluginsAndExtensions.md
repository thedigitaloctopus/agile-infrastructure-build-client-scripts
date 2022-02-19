As a rule your webroot shouldn't change much because your dyanmic assets should be offloaded to S3 or EFS.  
However, one time when your webroot will change is if you are installing or updating plugins within your application.  
This means that you don't want scaling events to be happening whilst you are making the updates.  
It should be fine to make updates to your system if you have several webservers running and updates to one webroot will be promptly synced to other webroots.  
The exception is if you are installing plugins and there is a scaling event things might get inconsistent, so, the way to deal with this is when you are going to install plugins or extensions begin by creating a file precisely called:  

/bin/touch ${HOME}/config/SWITCHOFFSCALING

This will switch off all scaling events whilst you are installing plugins or extensions and then once you are done (and your webroots have synced), you can remove the file:  

/bin/rm ${HOME}/config/SWITCHOFFSCALING  

And scaling events will begin again
