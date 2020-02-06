OK, so you deployed in Development mode and have spent some time creating a web application in your favourite CMS. What now?
Well, you need to make a baseline of your application so that other developers/webmasters can deploy that baseline and add
their own user data - content, site members and so on to your application. The way that you make a baseline, then, assuming
the case where you have a webroot and a database is as follows.

First of all decide on a name for your application. For example, if you are creating a social network you may choose to call
it 'socialnetwork'. 

On the Webserver you have been developing on, go to the directory

${HOME}/providerscripts/git

In this directory, you will find a script called CreateWebrootBaseline.sh This is the script we will run to create our baseline 

OK, so here are the steps.

1) I decided to use bitbucket for my baseslines, but you could use github or gitlab, so, create two repositories in bitbucket based on the name you have
chosen for your baseline for example:

socialnetwork-webroot-sourcecode-baseline
and
socialnetwork-db-baseline

The format then, is 
<baseline-name>-webroot-sourcecode-baseline for your application sourcecode
and
<baseline-name>-db-baseline for your applications database

IMPORTANT: Remember if your database is too large to be stored in a git repo, then the you can set "Super Safe Backup" and when the storage to git
fails, it will fall back on stroing your database to your datastore such as Amazon S3 or another similar service which doesn't limit the size your
database can get to. Without super safe backups switched on, the process may fail for large databases.

2) So, remember the script ${HOME}/providerscripts/git/CreateWebrootBaseline.sh that is the script we are going to run on the Webserver.

   So, cd ${HOME}/providerscripts/git

   to run the baselining process, we need to export the value of the home directory to the script so we run the script like this:

   export HOME="/home/XdgfhyeuX" && sh CreateWebrootBaseline.sh                     NB: replace XdgfhyeuX with your home directory value

   You will then be prompted...

   At the prompt simply type the name you have given your application

   socialnetwork

   You can get a coffee whilst it processes

3) On the Database server we are interested in the script

   ${HOME}/providerscripts/git/CreateDBBaseline.sh

   So, 

   cd ${HOME}/providerscript/git/CreateDBBaseline.sh

   export HOME="/home/XdgfhyeuX" && sh CreateDBBaseline.sh                     NB: replace XdgfhyeuX with your value

   When prompted, enter the name of your appication - for example: socialnetwork

   Depending on the size of your database - it probably shouldn't be that big - the script should complete fairly quickly, so no time for coffee this time.

4) Then you can test your deployment by entering the names of your new repositories next time you run the build process script on the build client

   socialnetwork-webroot-sourcecode-baseline
   socialnetwork-db-baseline

   NB. make sure that you point the infrastructure repository type to bitbucket as that is where the infrastructure sourcecode is stored. 
