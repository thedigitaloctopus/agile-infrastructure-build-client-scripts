When you have n webservers running if you make an extension or plugin update through your CMS, then, the CMS will update the webroot of the server it is currently active on but not on the other machines. This means that the webroots are out of sync.  
There's not really an ideal solution to this that I could find that could be easily implemented. What I decided to do, was to check for new and modified files on each server's webroot every minute and write any new and modified files to a common place, an S3 bucket. On each machine I then sync this aggregation of new and modified files from the S3 bucket to each webroot in turn. This means that within just over a minute (often less depending on timings) every other webroot will be in sync with the webroot which was updated. This is a way in which for the majority of cases, updates can be made across webroots without error. 
Because there is a chance of a temporary error it is recommended, that when you update extensions or plugins that you display a "website is temporarily down for maintenance" whilst you make your updates (most likely at night) and then put the machine back online once your updates are made. Of course, if you only have a single webserver (like in when you are in development mode), there is no need to worry about this at all.   

The files which manage the webroot syncing are on the webserver machines located at:  

**${HOME}/providerscripts/datastore/configwwrapper/SyncFromDatastoreTunnel.sh**  

and

**${HOME}/providerscripts/datastore/configwrapper/SyncToDatastoreTunnel.sh**  

Both these scripts make use of the s3cmd tool to sync to and from the S3 webrootunnel bucket.  
