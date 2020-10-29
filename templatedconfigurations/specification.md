### S3_ACCESS_KEY and S3_SECRET_KEY

These grant you access to manipulate an object store. Under the principle of least privileges, you should grant as few privileges to these keys wen you create them as possible.

You can get your S3_ACCESS_KEY and S3_SECRET KEY as follows:

##### digital ocean - Login to your digital ocean account and go to the API submenu (on the left bottom) and generate "Digital Ocean Spaces Keys". This will give you an access key which you can paste into your template. The first key is the S3_ACCESS_KEY and the second key is the S3_SECRET_KEY

##### exoscale - Login to your exoscale account and go to the IAM menu (on the right) and generate a pair of API keys which have access to object storage capabilities. The first key is the S3_ACCESS_KEY and the second key is the S3_SECRET_KEY which you can post into your template.

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

### ACCESS_KEY and SECRET_KEY 

These grant you access to compute resources with your cloud provider. Under the principle of least privileges, you should grant as few privileges to these keys wen you create them as possible.

digital ocean -    @@@@@@@@@@@@@

##### exoscale - Login to your exoscale account and go to the IAM menu (on the right) and generate a pair of API keys which have access to compute manipulation capabilities. The first key is the ACCESS_KEY which you can paste into your template for the ACCESS_KEY variable.

linode -  @@@@@@@@@@@@@@@'

vultr - @@@@@@@@@@@@@@@@@

##### AWS - Under your IAM user, create a pair of keys which have compute manipulation capabilities and paste them into your template as ACCESS_KEY and SECRET_KEY

-----

### DNS_USERNAME

This will be the username for your DNS service provider

cloudflare - the emal address of your cloudflare account

digital ocean - @@@@@@@@@@@@@

rackspace - @@@@@@@@@@@@@@@@@@@

-----

### DNS_SECURITY_KEY 

This is the security key which will enable us to manipulate records as needed with your DNS provider. You can find this key as follows for each provider:

cloudflare - Ths is the Global API key for your cloudflare account which you can find by clicking on your profile at the top right of the screen

digital ocean - @@@@@@@@@@@@@@

rackspace  - @@@@@@@@@@@@@@@@

------

### DNS_CHOICE - 

This can be set to one of three values at the time of writing (2020) - "cloudflare", "digitalocean", "rackspace". It defines which of the (supported) DNS service you would like to use with your deployment.

-----

### DEFAULT_USER

When you deploy to exoscale, the default user should be set to "ubuntu" if you are deploying Ubuntu and "debian" if you are deploying to Debian.
When you deploy to AWS, the default user should be set to "ubuntu" if you are deploying Ubuntu and "admin" if you are deploying to Debian.
For all other cases, the DEFAULT_USER should be set to "root"
