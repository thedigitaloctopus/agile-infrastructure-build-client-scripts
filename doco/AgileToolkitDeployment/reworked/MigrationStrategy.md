If you have an existing site hosted with a different provider, you need to be able to generate a tar archive of your webroot and a database dump of your database in order to migrate it.

Note:

WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"  
websiteDB="`${WEBSITE_NAME}-DB-backup".tar.gz`"

You can do the migration as follows:

1. Build a tar archive of your webroot using the command:  

**/bin/tar cvfz website_archive.tar.gz /var/www/html** 

Then copy the tar archive to your laptop

2. Take a database dump of your database using the following commands:

   MYSQL:
   
       /usr/bin/mysqldump --lock-tables=false  --no-tablespaces -y --host=<hostname> --port=<port> -u <user> -p<password> <database_name> >> applicationDB.sql
       /bin/echo "CREATE TABLE \`zzzz\` ( \`idxx\` int(10) unsigned NOT NULL, PRIMARY KEY (\`idxx\`) ) Engine=INNODB CHARSET=utf8;" >> applicationDB.sql
       /bin/sed -i -- 's/http:\/\//https:\/\//g' applicationDB.sql
       /bin/sed -i "s/<database_username>/XXXXXXXXXX/g" applicationDB.sql
       /bin/sed -i '/SESSION.SQL_LOG_BIN/d' applicationDB.sql
       /bin/sed -i "s/${IP_MASK}/YYYYYYYYYY/g" applicationDB.sql
       /bin/tar cvfz ${websiteDB} applicationDB.sql
  
  PSQL:
  
        export PGPASSWORD="${DB_P}" && /usr/bin/pg_dump -U ${DB_U} -h ${HOST} -p ${DB_PORT} -d ${DB_N} > applicationDB.sql
        /bin/echo "CREATE TABLE public.zzzz ( idxx serial PRIMARY KEY );" >> applicationDB.sql
        /bin/sed -i -- 's/http:\/\//https:\/\//g' applicationDB.sql
        /bin/sed -i "s/${DB_U}/XXXXXXXXXX/g" applicationDB.sql
        IP_MASK="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'IPMASK'`"
        /bin/sed -i "s/${IP_MASK}/YYYYYYYYYY/g" applicationDB.sql
        /bin/tar cvfz ${websiteDB} applicationDB.sql  
  
  
   3. On your laptop extract the website_archive.tar.gz into a directory. Create a repository with your git provider with nomenclature: <identifier>-website-sourcecode-baseline and push the extracted website_archive.tar.gz into your empty repository.  
   
   4. Create a repository with your git provider with nomenclature: <identifier>-db-baseline and push the unextracted ${websiteDB} into the new empty repository.  
   
   With these two repositories on with your git provider, you should be able to deploy your website as you would any other baseline. 
   
