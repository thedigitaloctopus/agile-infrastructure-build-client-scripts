You have two strategies for persisting your application assets:

1. configure the toolkit such that it uses a remote bucket in the cloud, "Persist application assets to cloud". 
All webservers then share this bucket to obtain their assets from. Whilst you application is live, assets must not be deleted from the bucket as this is the only place they are stored.

2. Configure the toolkit to use only the local files sytem. This will limit the space and there is a short synchronisation inconsistency when one webserver has updated assets which then have to be synchronised with other webservers. Also, the assets are persisted as part of the backup procedure for the websites source code, so a large number of assets will cause the repository limits to be exceeded, causing problems. 
