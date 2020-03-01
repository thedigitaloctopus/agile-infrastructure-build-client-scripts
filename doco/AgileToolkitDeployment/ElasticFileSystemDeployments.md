If you make a deployment using Elastic File Systems (currently only supported by AWS) then, this is a different datastore mechanism to what the other providers use which is S3 style buckets and an s3fs mount. Therefore, if you deployed using EFS and you want to redeploy to a different provider, then, you need to transfer any application assets to an S3 bucket for mounting using S3FS by the alternative cloudhost provider. 
EFS systems are automatically replicated to S3 by the toolkit, but, if we are redeploying, we need our EFS S3 assets to be available in the object store of our alternative provider. Our bucket used by EFS in S3 will have an EFS specific name like:

s3://ok9nuoorguk-wp-content-uploads-fs-b160407a

What we need to do to make our assets available for use by the alternative provider is in their object store, create a bucket

s3://ok9nuoorguk-wp-content-uploads and transfer all assets from s3://ok9nuoorguk-wp-content-uploads-fs-b160407a to it.
Obviously, these bucket names will vary from mine in your case, these are just examples. With that done, you can point the Agile Deployment Scripts to the appropriate Object Store when you are redeploying and that will enable you to make a full deployment.

Of course you could do it in the other direction and copy files out of an S3 bucket and into an EFS file system if you were switching to an EFS based solution. 
