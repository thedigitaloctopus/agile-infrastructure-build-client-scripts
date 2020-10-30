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

##### cloudflare - the emal address of your cloudflare account

digital ocean - @@@@@@@@@@@@@

rackspace - @@@@@@@@@@@@@@@@@@@

-----

### DNS_SECURITY_KEY 

This is the security key which will enable us to manipulate records as needed with your DNS provider. You can find this key as follows for each provider:

##### cloudflare - Ths is the Global API key for your cloudflare account which you can find by clicking on your profile at the top right of the screen

digital ocean - @@@@@@@@@@@@@@

rackspace  - @@@@@@@@@@@@@@@@

------

### DNS_CHOICE - 

This can be set to one of three values at the time of writing (2020) - 

##### 1. "cloudflare" 
##### 2. "digitalocean" 
##### 3. "rackspace". 

It defines which of the (supported) DNS service you would like to use with your deployment.

-----

### DEFAULT_USER

When you deploy to exoscale, the default user should be set to "ubuntu" if you are deploying Ubuntu and "debian" if you are deploying to Debian.
When you deploy to AWS, the default user should be set to "ubuntu" if you are deploying Ubuntu and "admin" if you are deploying to Debian.
For all other cases, the DEFAULT_USER should be set to "root"

-----

### WEBSITE_DISPLAY_NAME

This is simply the display name of your application, for example, "My Social Network", or "My Blog" and so on. It should be descriptive of your website and likely will be similar to the core part of the WEBSITE_URL described below

-----

### WEBSITE_NAME

This HAS to be exactly the same of the core part of the URL name of your website. So, if your website is called www.nuocial.org.uk, then, this value MUST be "nuocial"

-----

###  WEBSITE_URL

This is the URL of your website. It can be any valid URL

-----

### APPLICATION_REPOSITORY_PROVIDER

This is the git service provider where your application repositories are hosted. It has to be one of "github", "bitbucket" or "gitlab". If you fill this variable with one of those three exact strings, then, that will tell us who your application code is hosted with. It may or may not be hosted with the same provider as the infrastructure code for the agile deployment toolkit

-----

### APPLICATION_REPOSITORY_OWNER

This is the username of the user who owns (or created) your application repositories with your chosen git service provider

-----

### APPLICATION_REPOSITORY_USERNAME

This is the username of the user that you are currently using to access the application repositories. For example, the repositories might be owned by userA and are kept private but, userB is granted access. In this case the APPLICATION_REPOSITORY_OWNER would be userA and the APPLICATION_REPOSITORY_USERNAME would be userB. If you are the application repository owner, then this username and the owner name above will be the same.

-----

### APPLICATION_REPOSITORY_PASSWORD

This is the password for the APPLICATION_REPOSITORY_USERNAME or the application repository user. This is the password for your user account with your git provider. If the application repositories are public (be careful not to expose sensitive credentials if you make your application repos public), then this password can be blank.

-----

### SYSTEM_EMAIL_PROVIDER

At the moment, there are three SMTP email service providers. Enter the number value, "1", "2" or "3" to select which provider you want to use for your SMTP service. If you leave these variables blank, you simply won't receive any system emails to give status updated on build progression, server intialisations and so on. You are free to leave these variables blank, as you choose.

Enter "1" - Sendpulse (www.sendpulse.com)
Enter "2" - Google (gmail)
Enter "3" - AWS SES 

-----

### SYSTEM_TOEMAIL_ADDRESS 

The email address that system emails will be sent to this can be any email address that you have access to. MAYBE, the emails get marked as spam depending on your provider. If you take them out of the spam folder, then, the system should learn they are not spam. Most likely you will want to have a dedicated email address for your system emails for your deployed application as they will likely fill up your inbox otherwise.

-----

### SYSTEM_FROMEMAIL_ADDRESS

-----

The email address that system emails will be sent from. This should be an email address that the system emails are sent from. In your SYSTEM_TOEMAIL_ADDRESS inbox, this will be the email address that the system messages are seen to be sent from or to have originated from.

-----

### SYSTEM_EMAIL_USERNAME

This is the username of your SMTP user. For Amazon SES, for example, this will be the username generated when you enable the SES service. This is the SMTP username. 

-----

### SYSTEM_EMAIL_PASSWORD=""

This is the password of your SMTP user. For Amazon SES, for example, this will be the password generated when you enable the SES service. This is the SMTP password. 
