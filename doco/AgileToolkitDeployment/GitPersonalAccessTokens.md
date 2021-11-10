The prefered way to access github and gitlab repositories is to use a personal access token instead of a password. 
You can generate personal access tokens through their respective GUI systems, for example, github/settings/tokens.
You can then use this token in place of a password when using these providers by setting the environment variable:  

**APPLICATION_REPOSITORY_TOKEN**

and you can leave **APPLICATION_REPOSITORY_PASSWORD** unset

**MAKE SURE THE TOKEN IS GIVEN THE RIGHTS TO DELETE REPOSITORIES, OTHERWISE THERE WILL BE FAILURES RELATING TO BACKUPS AND SO ON**