PHP8 used in all cases, PHP 7.4 and below not tested for

NOTE: you can switch between building NGINX from source or from repos in the file [InstallNGINX](https://github.com/agile-deployer/agile-infrastructure-webserver-scripts/blob/master/installscripts/InstallNGINX.sh)

|     CMS        |        WEBSERVER        |       OPERATING SYSTEM     |          DATABASE        |                        STATUS                    |
| -------------- | ----------------------- | -------------------------- | ------------------------ | ------------------------------------------------ |
|   JOOMLA 4     |       NGINX (REPOS)     |         DEBIAN 10          |           MARIADB        | ISSUES WITH USING NGINX FROM REPOS FOR JOOMLA 4  |
|   JOOMLA 4     |       NGINX (SOURCE)    |         DEBIAN 10          |           MARIADB        | NO KNOWN ISSUES                                  |
|   JOOMLA 4     |       NGINX (REPOS)     |        UBUNTU 20.04        |           MARIADB        | ISSUES WITH USING NGINX FROM REPOS FOR JOOMLA 4  |
|   JOOMLA 4     |       NGINX (SOURCE)    |        UBUNTU 20.04        |           MARIADB        | NO KNOWN ISSUES                                  |
|   JOOMLA 4     |       NGINX (REPOS)     |         DEBIAN 10          |            MySQL         | ISSUES WITH USING NGINX FROM REPOS FOR JOOMLA 4  |
|   JOOMLA 4     |       NGINX (SOURCE)    |         DEBIAN 10          |            MySQL         | NO KNOWN ISSUES                                  |
|   JOOMLA 4     |       NGINX (REPOS)     |       UBUNTU 20.04         |            MySQL         | ISSUES WITH USING NGINX FROM REPOS FOR JOOMLA 4  |
|   JOOMLA 4     |       NGINX (SOURCE)    |       UBUNTU 20.04         |            MySQL         | NO KNOWN ISSUES                                  |
|   JOOMLA 4     |       APACHE (REPOS)    |         DEBIAN 10          |           MARIADB        | NO KNOWN ISSUES                                  |
|   JOOMLA 4     |       APACHE (REPOS)    |       UBUNTU 20.04         |           MARIADB        | NO KNOWN ISSUES                                  |
|   JOOMLA 4     |       APACHE (REPOS)    |         DEBIAN 10          |            MySQL         | NO KNOWN ISSUES                                  |
|   JOOMLA 4     |       APACHE (REPOS)    |       UBUNTU 20.04         |            MySQL         | NO KNOWN ISSUES                                  |
|   JOOMLA 4     |       LIGHTTPD(REPOS)   |            ALL             |             ALL          | JOOMLA 4 DOES NOT SUPPORT LIGHTTPD               |
|   JOOMLA 4     |       ALL               |            ALL             |           POSTGRES       | ADT DOES NOT SUPPORT JOOMLA/POSTGRES AT PRESENT  |
|                |                         |                            |                          |                                                  |
|                |                         |                            |                          |                                                  |
|   WORDPRESS    |       NGINX (REPOS)     |         DEBIAN 10          |           MARIADB        | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       NGINX (SOURCE)    |         DEBIAN 10          |           MARIADB        | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       NGINX (REPOS)     |        UBUNTU 20.04        |           MARIADB        | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       NGINX (SOURCE)    |        UBUNTU 20.04        |           MARIADB        | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       NGINX (REPOS)     |         DEBIAN 10          |            MySQL         | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       NGINX (SOURCE)    |         DEBIAN 10          |            MySQL         | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       NGINX (REPOS)     |       UBUNTU 20.04         |            MySQL         | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       NGINX (SOURCE)    |       UBUNTU 20.04         |            MySQL         | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       APACHE (REPOS)    |         DEBIAN 10          |           MARIADB        | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       APACHE (REPOS)    |       UBUNTU 20.04         |           MARIADB        | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       APACHE (REPOS)    |         DEBIAN 10          |            MySQL         | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       APACHE (REPOS)    |       UBUNTU 20.04         |            MySQL         | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       LIGHTTPD (REPOS)  |         DEBIAN 10          |           MARIADB        | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       LIGHTTPD (REPOS)  |       UBUNTU 20.04         |           MARIADB        | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       LIGHTTPD (REPOS)  |         DEBIAN 10          |            MySQL         | NO KNOWN ISSUES                                  |
|   WORDPRESS    |       LIGHTTPD (REPOS)  |       UBUNTU 20.04         |            MySQL         | NO KNOWN ISSUES                                  |
|                |                         |                            |                          |                                                  |
|   DRUPAL 9     |       NGINX (REPOS)     |         DEBIAN 10          |           MARIADB        | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       NGINX (SOURCE)    |         DEBIAN 10          |           MARIADB        | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       NGINX (REPOS)     |        UBUNTU 20.04        |           MARIADB        | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       NGINX (SOURCE)    |        UBUNTU 20.04        |           MARIADB        | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       NGINX (REPOS)     |         DEBIAN 10          |            MySQL         | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       NGINX (SOURCE)    |         DEBIAN 10          |            MySQL         | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       NGINX (REPOS)     |       UBUNTU 20.04         |            MySQL         | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       NGINX (SOURCE)    |       UBUNTU 20.04         |            MySQL         | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       APACHE (REPOS)    |         DEBIAN 10          |           MARIADB        | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       APACHE (REPOS)    |       UBUNTU 20.04         |           MARIADB        | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       APACHE (REPOS)    |         DEBIAN 10          |            MySQL         | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       APACHE (REPOS)    |       UBUNTU 20.04         |            MySQL         | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       LIGHTTPD (REPOS)  |         DEBIAN 10          |           MARIADB        | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       LIGHTTPD (REPOS)  |       UBUNTU 20.04         |           MARIADB        | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       LIGHTTPD (REPOS)  |         DEBIAN 10          |            MySQL         | NO KNOWN ISSUES                                  |
|   DRUPAL 9     |       LIGHTTPD (REPOS)  |       UBUNTU 20.04         |            MySQL         | NO KNOWN ISSUES                                  |
