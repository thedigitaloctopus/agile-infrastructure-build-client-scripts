If you are deploying an expedited or a hardcore build, there is a little trick you can do to deploy using a DBaaS or managed database service in your template or template override
The managed database you describe here will spin up automatically through the build process

### Digital Ocean

If you are using digital ocean managed databases you can set the following in your template or override

##### DATABASE_DBaaS_INSTALLATION_TYPE="\<db-type\>:DBAAS:\<db-engine\>:\<region\>:\<size\>:\<db-version\>:\<cluster-name\>:\<db-name\>"  
##### DATABASE_DBaaS_INSTALLATION_TYPE="\<db-type\>"
  
So an example of this would be in your template or override:

1. DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:mysql:lon1:1:db-s-1vcpu-1gb:8:testdbcluster1:testdb1"
2. DATABASE_DBaaS_INSTALLATION_TYPE="Postgres:DBAAS:pg:lon1:1:db-s-1vcpu-1gb:8:testdbcluster1:testdb1"

So, for the first example:  
  
db-type="MySQL"
db-engine="mysql"
region="lon1"
size="db-s-1vcpu-1gb"
db-version="8"  (mysql 8)
cluster-name="testdbcluster1"
db-name="testdb1"
  
So,  
  
  **db-type** can be: **"Maria", "MySQL", "Postgres"**  
  **db-engine** can be **"mysql", "pg"**  
  **region** can be **"nyc1, sfo1, nyc2, ams2, sgp1, lon1, nyc3, ams3, fra1, tor1, sfo2, blr1, sfo3"**  
  **size** can be **"db-s-1vcpu-1gb", "db-s-1vcpu-2gb", "db-s-1vcpu-3gb", "db-s-2vcpu-4gb", "db-s-4vcpu-8gb", "db-s-8vcpu-16gb", "db-s-8vcpu-32gb"**  
  **db-version** can be for **mysql = "8"** for **postgres="13"**  
  **cluster-name** can be unique string for your cluster, for example, **"testcluster"**   
  **db-name** can be a unique string for your database, for example, **"testdatabase"** 
  
--------
  
### Exoscale
  
If you are using exoscale managed databases you can set the following in your template or override

##### DATABASE_DBaaS_INSTALLATION_TYPE="\<db-type\>:DBAAS:\<db-engine\>:\<region\>:\<size\>:\<db-name\>"  
##### DATABASE_DBaaS_INSTALLATION_TYPE="\<db-type\>"

So an example of this would be in your template or override:

1. DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:mysql:ch-gva-2:hobbyist-1:testdb1"
2. DATABASE_DBaaS_INSTALLATION_TYPE="Postgres:DBAAS:pg:ch-gva-2:hobbyist-1:testdb1"
  
So, for the first example:  
  
db-type="MySQL"
db-engine="mysql"
region="ch-gva-2"
size="hobbyist-1"
db-name="testdb1"

So,
  
  **db-type** can be: **"Maria", "MySQL", "Postgres"**  
  **db-engine** can be **"mysql", "pg"**
  ** region** can be **"ch-gva-2", "de-fra-1", "de-muc-1", "at-vie-1", "ch-dk-2", "bg-sof-1"**
  **size** can be **"hobbyist-1", startup-[4|8|16|32|64|128|255]", business-[4|8|16|32|64|128|255]", premium-[4|8|16|32|64|128|255]"**
  **db-name** can be a unique string for your database, for example, **"testdatabase"** 
 
  
  
  
  
