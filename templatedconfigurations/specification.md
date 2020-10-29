### S3_ACCESS_KEY and S3_SECRET_KEY

This setting is the access key for your s3 datastore. You can get the access key and secret key from each providers GUI console. You can get your S3_ACCESS_KEY and S3_SECRET KEY as follows:

##### digital ocean - Login to your digital ocean account and go to the API submenu (on the left bottom) and generate "Digital Ocean Spaces Keys". This will give you an access key which you can paste into your template. The first key is the S3_ACCESS_KEY and the second key is the S3_SECRET_KEY

##### exoscale - Login to your exoscale account and go to the IAM menu (on the right) and generate a pair of API keys which have access to object storage and sever manipulation capabilities. The first key is the S3_ACCESS_KEY and the second key is the S3_SECRET_KEY which you can post into your template.

##### linode - Login to your Linode account and go to the Object Storage menu on the right then select the Access Key menu and select "Create an Access Key" and that will generate an access key and a secret key which you can copy into your template as S3_ACCESS_KEY and S3_SECRET_KEY.

##### vultr - You need to subscribe to S3 Object Storage and this will grant you a pair of S3 access keys which you can copy and paste into your template. 

##### AWS - Under your IAM user, create a pair of keys which have S3 manipulation capabilities and paste them into your template as S3_ACCESS_KEY and S3_SECRET_KEY

-----

### S3_HOST_BASE 

This parameter is the S3 endpoint for your deployment. It should be located as near as possible to where (in the world) you plan to run your VPS systems.

##### digital ocean - Available endpoints to choose from (2020) - nyc3.digitaloceanspaces.com, ams3.digitaloceanspaces.com, sfo2.digitaloceanspaces.com, sgp1.digitaloceanspaces.com, fra1.digitaloceanspaces.com

##### exoscale - Available endpoints to choose from (2020) - sos-ch-gva-2.exo.io, sos-ch-dk-2.exo.io, sos-de-fra-1.exo.io, sos-de-muc-1.exo.io, sos-at-vie-1.exo.io, sos-bg-sof-1

##### linode - Available endpoints to choose from (2020) - us-east-1.linodeobjects.com, eu-central-1.linodeobjects.com

##### vultr - Available endpints to choose from (2020) - ewr1.vultrobjects.com, 

##### Amazon - There are lots of S3 endpoints to choose from for Amazon. Your S3 endpoint should be region specific. For example if you are in eu-west-1 in would be, s3.eu-west-1.amazonaws.com

You can set your ${S3_HOST_BASE} parameter in your template to one of these listed endpoints depending on who your object storage is hosted with (which will likely be the ssame provider as your VPS systems). 

-----

### S3_LOCATION

##### digital ocean - the location should always be set to "US" no matter where you are in the world, when I tried setting it differently, I got problems.

##### exoscale - the location should always be set to "US" no matter where you are in the world 

##### linode - the location should always be set to "US" no matter where you are in the world 

##### vultr - the location should always be set to "US" no matter where you are in the world

##### amazon - I have only used "US" and "EU" depending on whether I am deploying to the EU or the US, I am not sure what this setting would be for other parts of the world

-----
