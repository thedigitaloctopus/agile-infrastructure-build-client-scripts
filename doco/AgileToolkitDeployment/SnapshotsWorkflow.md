
### SNAPSHOTS WORKFLOW

##### AgileDeploymentToolkit.sh method
Under this method, if your cloudhost supports snapshots, then, you will be asked during your deployment process whether you want to use snapshots. If you do, you will be asked if you want to generate snapshots or build from snapshots which already exist

1. **Generate Snapshots** - if you chose the option to generate snaphots, the build process will take snapshots of your autoscaler, webserver and database at the end of the build process. It is expected that you will then terminate these machines and retain the snapshots for use in a deployment.
 
2. **Build usng snapshots** - once you have run step 1 for your application, you will have snapshots available. If you chose to build using snapshots, you will be asked to choose which of the available snapshots you wish to build from and once selected, your servers will build (quickly), probably about 5 minutes for all three and once built, any scaling events will also be built from snapshots. If you set the repository to an hourly or daily backup, then once the servers have built, they will pull down the latest version of your application from the repsoitory or datastore. This way, you can build from snapshots taken some time ago but still have the latest version of an application running. To build from snapshots you will need to know the snapshot id that you wish to build from this is the unique id that was given to your snapshots during step 1. Using this option you will need  the first 4 characters of your snapshot id.

### ExpeditedAgileDeploymentToolkit.sh method

Under this method, you have to manually edit the template and for each method, you need to set the environment varibles as follows. So, as well as all the other settings that you need to set for your template using the expedited method, you need to specifically pay attention to the following:

1. **Generate Snapshots** Under this method, you need to set 

**GENERATE_SNAPSHOT="1"**  

This will prompt the build process to take a snapshot of your machines at build time as it did for the AgileDeploymentToolkit.sh method. 

2. **Build using snapshots**  To use this method, you need to set the following values in your template:

**AUTOSCALE_FROM_SNAPSHOTS="1"**  
**GENERATE_SNAPSHOTS=""**  
**SNAPSHOT_ID="XXXX"** #swap for your own 4 letter code in snapshot name - you can find in the console 
**WEBSERVER_IMAGE_ID="XXXXXXXX"** #swap for your own  
**AUTOSCALER_IMAGE_ID="XXXXXXXX"** #swap for your own  
**DATABASE_IMAGE_ID="XXXXXXXX"** #swap for your own  

If you have snapshots generated and ready and you set these values, assuming that the rest of your template is set up correctly, you will be able to build from snapshots. If you use an "hourly", "daily" etc backup, then, the build will sync to the latest repository.

### Hardcore method

The hardcore method involves using an Override script, for example: [OverrideScript](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/templatedconfigurations/templateoverrides/digitalocean/OverrideScript.sh) by taking a copy of it and filling in the necessary variables in the override script and overriding any addiction ones you might wish to override for this particular deployment such as DB_SIZE or WS_SIZE and so on accoring to the specification. Once you have the script populated up, you paste it into the user data of a virgin VPS machine with your cloud provider, as documented elsewhere. So, you need to pay close attention to all of your variables in your override script and particularly pertinent to the snapshot workflow is the addition of the following variables:

1. **Generate Snapshots** Under this method, you need to set GENERATE_SNAPSHOT="1" in your override script. This will prompt the build process to take a snapshot of your machines at build time as it did for the AgileDeployment.sh and the expedited method. 

2. **Build using snapshots**  To use this method, you need to set the following values in your override script:

**AUTOSCALE_FROM_SNAPSHOTS="1"**  
**GENERATE_SNAPSHOTS="0"**  
**SNAPSHOT_ID="XXXX"** #swap for your own 4 letter code in snapshot name - you can find in the console 
**WEBSERVER_IMAGE_ID="XXXXXXXX"** #swap for your own  
**AUTOSCALER_IMAGE_ID="XXXXXXXX"** #swap for your own  
**DATABASE_IMAGE_ID="XXXXXXXX"** #swap for your own  

Once you are satisfied that all the necessary variables are set in your override script, paste your override script into your user-data area of your VPS system and Bob's your uncle. 

**PLEASE NOTE**

If you are using, for example, EFS, then when you generate your snapshots in the first phase, you need to make sure that, for example, ENABLE_EFS=1, DIRECTORIES_TO_MOUNT="images" and PERSIST_ASSETS_TO_CLOUD="1". If you set these values to anything else when you generate your snapshots, they will remain as you set them when you autoscale from these snapshots, in other words, if ENABLE_EFS="0" when you generated your snapshots, the ADT won't change the setting if you set it to ENABLE_EFS="1" when you autoscale off your snapshots later on. In short, snapshots should be generated how you want your live machines to be. You also need to, for example, when you generate your snapshots, they need to be generated with the size that you want your autoscaled webserver machines to be. If you need your websevers to be a different size, then, you will need to regenerate your snapshots for that size. 


