There are three basic ways you can build a deployment from the Agile Deployment Toolkit:

1. The Full Build
2. The Expedited Buikd
3. The Hardcore Build

The Full Build involves manually running a script and entering values at the command line. The inputs you give have limited saniy checking on them and is good if you really don't understand how this toolkit works. 
Its also good if you want to see what configuration of variables is produced for a particular build configuration.

The Expedited Build involves manually editing a template of your choosing and manually running a shell script to deploy from that template.

The Hardcore build involves manually editing an override script or generating one using the ${BUILD_HOME}/helperscripts/GenerateOverrideScript.sh
