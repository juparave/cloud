# Using Apache as a Reverse Proxy 

ref: [DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-apache-as-a-reverse-proxy-with-mod_proxy-on-ubuntu-16-04)


Step 1 — Enabling Necessary Apache Modules
Apache has many modules bundled with it that are available but not enabled in a fresh installation. First, we’ll need to enable the ones we’ll use in this tutorial.

The modules we need are mod_proxy itself and several of its add-on modules, which extend its functionality to support different network protocols. Specifically, we will use:

mod_proxy, the main proxy module Apache module for redirecting connections; it allows Apache to act as a gateway to the underlying application servers.
mod_proxy_http, which adds support for proxying HTTP connections.
mod_proxy_balancer and mod_lbmethod_byrequests, which add load balancing features for multiple backend servers.
To enable these four modules, execute the following commands in succession.

    # a2enmod proxy
    # a2enmod proxy_http
    # a2enmod proxy_balancer
    # sudo a2enmod lbmethod_byrequests


To put these changes into effect, restart Apache.

    # sudo systemctl restart apache2

Apache is now ready to act as a reverse proxy for HTTP requests. In the next (optional) step, we will create two very basic backend servers. These will help us verify if the configuration works properly, but if you already have your own backend application(s), you can skip to Step 3.

```conf
    ServerAdmin webmaster@myapp.com
    DocumentRoot /home/myapp/www
    ServerName api.myapp.com

    ProxyPreserveHost On

    ProxyPass / http://127.0.0.1:8081/
    ProxyPassReverse / http://127.0.0.1:8081/
```

