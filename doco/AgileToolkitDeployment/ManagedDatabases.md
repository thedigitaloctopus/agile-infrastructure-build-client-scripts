Digital Ocean managed databases require usage of primary keys on database tables for performance reasons. This cannot be switched off. 
On my sample application (and possibly yours as well), some lugins create tables without primary keys.
This means that when the Agile Deployment toolkit tries to import your application database file into the managed database it fails to complete.
There is a way around this.
1. Run the agile deployment toolkit and let the webserver build and the database.
2. The database will fail to complete because the sql file does not have primary keys set for all the tables it creates.
3. Open a new ssh tab connect to the failed database droplet and look for the file
4. ${HOME}/backups/installDB/*.sql
5. grep through this file with the command cat *.sql | grep -e "CREATE\\|PRIMARY" and that will show you which tables do not have a primary key set
6. Do some work to modify the sql file to have dummy primary keys for whichever create commands are missing them. There should be a table "zzzz" at the end of the dump which is used as a marker, this shows you how to add a dummy PRIMARY KEY to any tables which need them. Once you have added the primary keys, your hourly backups and so on will include them, but, if you redeploy from a baseline and primary keys are missing from tables, you will have to re-add them on first deploy. You can, of course, make your own baseline and use that. 
7. Once all tables have primary keys import the sql file into your managed database cluster with a command something like this example (replace all params with your own values):
        
    /usr/bin/mysql -A -u <username> -p<password> --host="private-db-mysql-lon1-36076-do-user-21398432-0.a.db.ondigitalocean.com" --port=25060 <db_name> < ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
8. Once the database sql file has successfully imported, return to the ssh command which should have reported the failed build and request for it to try again. This time the build should complete and your application database is in your managed database cluster
