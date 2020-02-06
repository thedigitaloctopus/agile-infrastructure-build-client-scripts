1) To add a new DNS provider, first of all, research the provider, they must support round robin DNS loadbalancing. If they do, then you can think about adding them as a provider with this toolkit as long as they have a suitable API or CLI toolkit to programmatically access their DNS service. You could look into Route 53 for example at the time of writing I have implemented for cloudflare and rackspance DNS services. Cloudflare has lots of additional security services you can add with free and more extensive payed plans. 

2) Add your new DNS provider to the ${BUILDPHOME}/SelectDNSProvider.sh script alongside cloudflare and rackspace, following those example methodologies.

3) Update ${BUILD_HOME}/providerscripts/dns/* on the Build client

4) Update ${HOME}/providerscipts/dns/* on the Autoscaler

${HOME}/providerscripts/mailserver/ObtainSSLCertificate.sh

5) On the Webserver codebase implement ${HOME}/provider/dns/SetupDNSFirewall.sh and make the rules as tight as you can. In the cloudflare case, the firewall will only except requests from  a cloudflare IP. This is the case when the DNS service is acting as a proxy and actually rerouting the requests via their service so they can filter bad actors so they never hit your site. In other cases, the DNS reuqests are routed straight to your webserver from any IP address on the internet. In this case, it is imperitive that your firewall is active and it should be set to accept requests from anywhere to port 443 and only port 443. You can study the UFW rules for the rackspace dns provder to see how to set this up. In the case of a proxy service, you will need to ask them what their ip address ranges are and allow only those ranges in your firewall rules.

Also on the webserver, modify also ${HOME}/providerscripts/webserver/ObtainSSLCertificate.sh

