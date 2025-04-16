# Configuring Apache as a Reverse Proxy

A reverse proxy acts as an intermediary for requests from clients seeking resources from servers. Apache HTTP Server (`httpd`) can be configured to function as a reverse proxy using its `mod_proxy` module and related modules. This setup is useful for load balancing, improving security, and simplifying SSL/TLS configuration.

This guide outlines the basic steps to configure Apache as a reverse proxy on Debian/Ubuntu-based systems.

Based on concepts from: [DigitalOcean Ubuntu 16.04 Guide](https://www.digitalocean.com/community/tutorials/how-to-use-apache-as-a-reverse-proxy-with-mod_proxy-on-ubuntu-16-04) (Note: Commands are generally applicable to newer versions).

## Step 1: Enable Required Apache Modules

Apache requires specific modules to handle proxying and load balancing. Enable them using the `a2enmod` command:

*   `mod_proxy`: The core proxy module.
*   `mod_proxy_http`: Handles proxying HTTP requests.
*   `mod_proxy_balancer` & `mod_lbmethod_byrequests`: Provide load balancing capabilities across multiple backend servers (optional if only proxying to a single server, but often useful).
*   `mod_ssl`: Required if you plan to handle HTTPS connections at the proxy level (recommended).
*   `mod_headers`: Allows modification of HTTP headers, often needed in proxy setups.

```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_balancer
sudo a2enmod lbmethod_byrequests
sudo a2enmod ssl
sudo a2enmod headers
```

Apply the changes by restarting Apache:

```bash
sudo systemctl restart apache2
```

## Step 2: Configure the Reverse Proxy Virtual Host

Create or modify an Apache Virtual Host configuration file (e.g., in `/etc/apache2/sites-available/`) to define the proxy settings. Here's a basic example proxying requests for `api.myapp.com` to a backend service running on `http://127.0.0.1:8081`:

```apacheconf
<VirtualHost *:80>
    ServerAdmin webmaster@myapp.com
    ServerName api.myapp.com
    # Optional: Add ServerAlias www.api.myapp.com

    # Preserve the original Host header from the client
    ProxyPreserveHost On

    # Proxy requests to the backend server
    ProxyPass / http://127.0.0.1:8081/
    ProxyPassReverse / http://127.0.0.1:8081/

    # Optional: Add error logs
    ErrorLog ${APACHE_LOG_DIR}/api.myapp.com-error.log
    CustomLog ${APACHE_LOG_DIR}/api.myapp.com-access.log combined
</VirtualHost>
```

**Explanation of Directives:**

*   `ProxyPreserveHost On`: Sends the original `Host:` header from the client to the backend server. This is important for applications that rely on this header.
*   `ProxyPass / http://.../`: This is the main proxy directive. It maps incoming requests starting with `/` (i.e., all requests for this VirtualHost) to the specified backend URL. The trailing slash on both paths is important for correct path mapping.
*   `ProxyPassReverse / http://.../`: This directive rewrites the `Location`, `Content-Location`, and `URI` headers in responses from the backend server. It prevents the backend server's internal URL from being exposed to the client during redirects.

## Step 3: Enable the Site and Test

Enable the new virtual host configuration (replace `your-config-file.conf` with the actual filename):

```bash
sudo a2ensite your-config-file.conf
```

Check the configuration for syntax errors:

```bash
sudo apache2ctl configtest
```

If the syntax is OK, reload Apache to apply the changes:

```bash
sudo systemctl reload apache2
```

You should now be able to access your backend application via the `ServerName` defined (e.g., `http://api.myapp.com`).

## Further Considerations

*   **SSL/TLS (HTTPS):** For production environments, configure SSL/TLS on the Apache reverse proxy. This typically involves obtaining an SSL certificate (e.g., via Let's Encrypt) and creating a `<VirtualHost *:443>` block with `SSLEngine on` and related SSL directives.
*   **Load Balancing:** To distribute traffic across multiple backend servers, use `ProxyPass` within a `<Proxy balancer://...>` block along with `BalancerMember` directives.
*   **Security:** Implement appropriate security measures, such as limiting access, using `mod_security`, and keeping Apache updated.
