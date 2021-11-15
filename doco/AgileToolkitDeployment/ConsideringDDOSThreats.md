If you deploy to Cloudflare, the webservers only allow connections from Cloudflare IP addresses. How effective that is at warding off potential attacks I am not sure, but, that is the suggested approach and the  

**"uncomplicated firewall (ufw)"**  

is used to achieve this on each webserver.

You also have the options to deploy **modsecurity** and **modevasive** which will interogate requests to see if they are genuine or not. 

So, when you use the naked DNS systems such as the DNS services provided by say, Digital Ocean or Exoscale, the problem here is that your server is not shielded in the way that it is with Cloudflare. Again, you have the option of deploying **modsecurity** and **modevasive**, but, I have added some extra code to make it easy to use the "Basic Auth" mechanism built into your browser to protect your application.

All you have to do is switch on "GATEWAY_GUARDIAN" at build time for the basic auth mechanism to be deployed and configured. Once you do that requests (to your admin areas of your application) will have to authenticate to the the basic auth mechanism before getting anywhere near your application and this is a recommended approach if you are not using cloudflare four your DNS. Cloudflare also offers a similar approach which is called "Cloudflare Access, Zero Trust" and it will send your users an access code by email before they are allowed near your webproperty. 

You can read more about what I have done to setup the basic auth mechanism here:

[Gateway Guardian](GatewayGuardian.md)



