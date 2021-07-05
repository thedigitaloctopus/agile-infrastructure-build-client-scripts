#### CONTENT DELIVERY NETWORK

What I have done to facilitate a CDN system is centralise asset storage for each application in their S3 compatible object storage service, for example, for digital ocean this would be the Digital Ocean Spaces service. What this means is that for n webservers as soon as a new asset is uploaded by a user of an application (for example, a new profile picture), the asset is written to the centralied S3 compatible storage service. This means that all webservers "see" the same files as soon as they are created or uploaded. So, webservers 1 to n are all writing to the same bucket in S3. Now, what we don't want to do for every read of that image file to have to go to the origin server and retreive the asset from object storage and then return it to the client, so, what we want to do is at an application level set up a CDN which uses the bucket we are uploading our assets to from the webservers as an origin. So, for your application, for example, Joomla, Wordpress, Drupal or Moodle if you install a CDN system plugin using the S3 bucket that your webservers are writing to, then, the CDN will read the assets from the bucket and serve them directly to the client, caching them where possible. This is much more efficient and reduces the load on the origin webservers.  

Each application has different directories which receive user uploads, for example, for joomla it is the $WEBROOT/images  and $WEBROOT/media directories  
  
To define which directories you want the system to use for your assets uploads, you need to go to your template override script and set the following override parameters:  
  
So, for joomla, for example you would set something like:  

##### export DIRECTORIES_TO_MOUNT="images:media"  

For drupal you might set:  

##### export DIRECTORIES_TO_MOUNT="sites.default.files.pictures:sites.default.files.styles:sites.default.files.inline-images"  

And for wordpress you might set:  

##### export DIRECTORIES_TO_MOUNT="wp-content.uploads"  

The DIRECTORIES_TO_MOUNT environment variable is set to sensible defaults for each application.  
  
    
#### CLOUDFLARE CDN  
    
If you use cloudflare, you don't need to install a CDN at an application level. What you can do instead is set some page rules with the setting "cache everything" for the assets directory of your application.  
  
  
So, for joomla, you would setup two page rules for the following paths with the cache everything setting set to on for each location:  

So, if you are running a joomla website which has a URL, www.nuocial.org.uk, your images will be located at www.nuocial.org.uk/images and your media at www.nuocial.org.uk/media. So, these are the two locations we are interested in.  
So, we need to set a page rule for each of these locations with the cache everything value set.  
  
www.nuocial.org.uk/images  ---- CACHE EVERYTHING  
www.nuocial.org.uk/media   ---- CACHE EVERYTHING  
  
This way, the first time an asset is loaded, it will go all the way to the origin server but from then on it will be cached in Cloudflare cache and retrieved from there which will greatly reduce the load on our webservers and so on. If you clear your cache, then, obviously everything will be reloaded from the origin server fresh.   
