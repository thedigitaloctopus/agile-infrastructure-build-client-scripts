To be more secure, when you are using cloudflare you might want to firewall off the 443 and 80 ports to only be accessible by Cloudflare ip addresses.  

You need to keep an eye on these ip addresses:  

[Cloudflare IP Addresses](https://www.cloudflare.com/en-gb/ips/)  

they are added to the native firewalling system  

[here](https://github.com/agile-deployer/agile-infrastructure-build-client-scripts/blob/master/providerscripts/security/firewall/GetDNSIPs.sh)  

and for the UFW firewall  

[here](https://github.com/agile-deployer/agile-infrastructure-webserver-scripts/blob/master/security/SetupDNSFirewall.sh). 
