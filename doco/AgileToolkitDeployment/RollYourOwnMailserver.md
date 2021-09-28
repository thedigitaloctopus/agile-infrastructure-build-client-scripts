There are a few solutions to providing email services for your users:

1. Allow any domain email addresses in your application, like gmail, yahoo and so on.
2. If you want your users to have their own custom domain, you can do something like this: [Mail Forwarding](https://www.youtube.com/watch?v=MEheS8gM4Xs)
3. If you want to run your own email server, you can run one using [iRedmail](https://www.iredmail.org) or [Mail in a box](https://mailinabox.email) or [Modoba](https://modoboa.org/en/)
4. Cloudflare are providing an email routing service which you can setup to route people's emails through your domain to their own email address on gmail or hotmail or summink. This requires that your domain is setup with Cloudflare, however and it remains to be seen if email addresses routing through Cloudflare can be setup programmatically or whether you would have to have an admin manually add people to the service.

Of course, if you want to use this solution for your pre-existing organisation and your peeps already have custom email address, you can use the mail solution you already use or have. 
