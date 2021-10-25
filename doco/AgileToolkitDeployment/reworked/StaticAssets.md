**CONTENT DELIVERY NETWORK**
-----------------------------

What I have done to facilitate a CDN system is centralise asset storage for each application in their S3 compatible object storage service using s3fs (or if you are using AWS, the EFS service), so, for example, for Digital Ocean this would be the Digital Ocean Spaces service. What this means is that for n webservers as soon as a new asset is uploaded by a user of an application (for example, a new profile picture), the asset is written to the centralied S3 compatible storage service. This means that all webservers "see" the same files as soon as they are created or uploaded. So, webservers 1 to n are all writing to the same bucket in S3. Now, what we don't want to do for every read of that image file to have to go to the origin server and retreive the asset from object storage and then return it to the client, so, what we want to do is at an application level set up a CDN which uses the bucket we are uploading our assets to using s3fs from the webservers as an origin. So, for your application, for example, Joomla, Wordpress, Drupal or Moodle if you install a CDN system plugin using the S3 bucket that your webservers are writing to, then, the CDN will read the assets from the bucket and serve them directly to the client, caching them where possible. This is much more efficient and reduces the load on the origin webservers.

Most modern applications generate static assets during usage. In a horizontally scaled architecture, these assets need to be shared immediately amongst all the webservers and not just the webserver that they were generated through or uploaded to. I have adopted a flexible approach to how to make this so and you can choose which technique you would like to use.

Here are your available options:  

1. Use an application level plugin to offload your assets automatically to an S3 compatible object storage system. These plugins are available for Wordpress, Joomla and so on. If you install one of these plugins into your application, then, all of your assets can be offloaded into the cloud (S3 compatible storage) and automatically shared between all of your webservers instantly. The limit to how many assets you can store is the limit of the S3 bucket, and obviously how deep your pockets are also.   

Here is how you can offload your wordpress static assets to S3 and use a CDN:  https://www.codeinwp.com/blog/wordpress-s3-guide/  
Here is an extension you can use to offload your assets for joomla to S3 https://extensions.joomla.org/extension/ja-amazon-s3/  

2. At a systems level, you can set things up such that services such as Elastic File System (available on AWS) or an S3 bucket mounted as a file system using S3FS. The EFS solution is a very good solution because you can have (up to) petabytes of data and it is fast. Using S3FS should be an option of last resort, because, as someone said, S3 is not really for filesystems. S3FS will work, to an extent, but, option 1 is the preferable option even though it means more complexity in the application. If you are using S3FS, when applications are requested by a user interacting with your application it means that the sytem has to read through S3FS to get the assets which is slow. If you use an application level plugin, then, the application will read the assets direct from the bucket which can be cached at the edge through some systems.  

**CONFIGURING FOR YOUR APPLICATION** 
------------------------

Each application has different directories which receive user uploads, for example, for Joomla it is the /var/www/html/images directory for Wordpress it is /var/www/html/wp-content/uploads  

To define which directories you want the system to use for your assets uploads, you need to go either set the value at buid time if you are using a full build or to your template override script and set the following override parameters:  

So, for joomla, for example you would set something like:  

**export PERSIST_ASSETS_TO_CLOUD="1"  
export DIRECTORIES_TO_MOUNT="images"**  

For drupal you might set:

**export PERSIST_ASSETS_TO_CLOUD="1"  
export DIRECTORIES_TO_MOUNT="sites.default.files.pictures:sites.default.files.styles:sites.default.files.inline-images"**  

And for wordpress you might set:

**export PERSIST_ASSETS_TO_CLOUD="1"  
export DIRECTORIES_TO_MOUNT="wp-content.uploads"**  

The **DIRECTORIES_TO_MOUNT** environment variable is set to sensible defaults for each application but you can override it.

**CLOUDFLARE CDN**  
---------------------

If you use cloudflare, you don't need to install a CDN at an application level or as a plugin. What you can do instead is set some page rules with the setting "cache everything" for the assets directory of your application.

So, for Joomla, you would setup two page rules for the following paths with the cache everything setting set to on for each location:

So, if you are running a joomla website which has a URL, www.nuocial.org.uk, your images will be located at www.nuocial.org.uk/images. So, this is the  location we are interested in.

So, we need to set a page rule for each of these locations with the cache everything value set.

www.nuocial.org.uk/images ---- CACHE EVERYTHING

This way, the first time an asset is loaded, it will go all the way to the origin server but from then on it will be cached in the Cloudflare cache and retrieved from there which will greatly reduce the load on our webservers and so on. If you clear your Cloudflare cache, then, obviously everything will be reloaded from the origin server fresh.

**NOTE:** Of course, if you are in development mode and you don't need to guarantee uptime and you only use one webserver, then, you can just use the filesystem on your webserver to store any assets you generate as you develop your application. In fact, this is necessary because these assets will be included in the baseline of your application when you make one. When you offload your assets to S3 or EFS, they are not included in backups and in the case of S3, the S3 bucket itself becomes the storage place for your assets and in the case of EFS it is the EFS file system. In such a case, you should look into what services your provider has, or, roll your own solution for backing up your static assets to ensure their safety. 

To understand the different scenarios you are likely to want to deploy to consider this:  

1. **VIRGIN deployment in development mode** - no assets persisted to cloud (most cases when you have a virgin deployment you are not going to have a lot of assets - export PERSIST_ASSETS_TO_CLOUD="0"  
2. **BASELINE deployment in development mode** - when you are building your baseline, you shouldn't have many assets so there is no point mounting them from S3 - export PERSIST_ASSETS_TO_CLOUD="0" 
3. **TEMPORAL deployment in production mode** - You should offload all your user generated assets to S3 buckets as described - export PERSIST_ASSETS_TO_CLOUD="1". There is a bucket for each directory that you offload, and, this is important because a git repository has a limit of 1GB of data in it, so, if you don't offload your assets they will be backed up to your git repo as part of the temporal backup processsing and it will eventually fail if the size of the repository becomes greater than the size limit for your provider.  

**Its important to note that when you assets are offloaded to S3, that will be the only copy of them. Depending on your provider you might want to setup a way of backing up your assets through a process your provider facilitates or you may want to have some manual procedure for making the backups**
