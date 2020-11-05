SNAPSHOTS WORKFLOW

AgileDeployment.sh method

Under this method, if your cloudhost supports snapshots, then, you will be asked whether you want to use snapshots.
If you do, you will be asked if you want to 

1. Generate Snapshots - in this case, the build process will take snapshots of your autoscaler, webserver and database at the end of the build process. It is expected that you will then terminate these machines are retain the snapshots for later usage

2.Build usng snapshots - once you have run step 1 for your application, you will have snapshots available. 
You will be asked to choose which of the available snapshots you wish to build from and once selected, your servers will build (quickly), probably about 5 minutes for all three and once built, any scaling events will also be built from snapshots. If you set the repository to an hourly or daily backup, then once the servers have built, they will pull down the latest version of your application from the repsoitory or datastore. This way, you can build from snapshots taken some time ago but still have the latest version of an application running. 

ExpeditedAgileDeploymentToolkit.sh

Under this method, you have to manually edit the template and for each method, you need to set the environment varibles as follows:

1. Generate Snapshots: GENERATE_SNAPSHOT="1"

2. Build using snapshots: AUTOSCALE_FROM_SNAPSHOTS="1"
                          GENERATE_SNAPSHOTS="0"
                          SNAPSHOT_ID="XXXX"  #swap for your own 4 letter code in snapshot name - you can find in the console
                          WEBSERVER_IMAGE_ID="XXXXXXXX" #swap for your own 
                          AUTOSCALER_IMAGE_ID="XXXXXXXX" #swap for your own
                            DATABASE_IMAGE_ID="XXXXXXXX" #swap for your own
                            
 If you have snapshots generated and ready and you set these values, assuming that the rest of your template is set up correctly, you will be able to build from snapshots. If you use an hourly, daily etc backup, then, the build will sync to the latest repository. 
