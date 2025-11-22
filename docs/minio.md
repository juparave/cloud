# MinIO Reverse Proxy Configuration Reference

This document provides a comparison and explanation of the necessary configuration directives for setting up a secure reverse proxy for a MinIO deployment using both Nginx and Apache HTTP Server, based on the provided configuration (minio.conf).

### Backing up MinIO

There's a good reference here [My Experience Backing Up MinIO](https://medium.com/@dev.fethi/my-experience-backing-up-minio-344f407d9bbf)

## 1. Architecture Overview

MinIO runs two distinct services:

- **S3 API**: Typically on port 9000 (handles file uploads/downloads).
- **Console UI**: Typically on port 9001 (requires WebSockets).

The reverse proxy (Nginx or Apache) handles SSL termination, redirects, and routing traffic to the correct backend service.

## 2. Key Configuration Requirements

| Requirement | Description | Apache Directives (based on minio.conf) | Nginx Directives (from original config) |
|-------------|-------------|------------------------------------------|------------------------------------------|
| HTTP to HTTPS | Forces all insecure traffic to use SSL. | `RewriteEngine On`, `RewriteRule ^ https://... [END,NE,R=permanent]` | `if ($host = media.prestatus.com) { return 301 https://$host$request_uri; }` |
| S3 API Proxy | Routes generic requests (/) to the S3 API backend (9000). | `ProxyPass / http://localhost:9000/`, `ProxyPassReverse / http://localhost:9000/` | `proxy_pass http://localhost:9000;` |
| Console Routing | Routes specific requests (/minio/ui/) to the Console backend (9001). | `ProxyPass /minio/ui/ http://localhost:9001/` | `proxy_pass http://minio_console;` (where minio_console is localhost:9001) |
| Path Stripping | Removes the /minio/ui/ prefix before sending the request to the backend. | Handled automatically by the ProxyPass syntax: `ProxyPass /minio/ui/ http://localhost:9001/` | `rewrite ^/minio/ui/(.*) /$1 break;` |
| WebSockets | Required for real-time communication in the Console UI (e.g., streaming logs). | `RewriteCond %{HTTP:Upgrade} websocket [NC]`, `RewriteRule ^/minio/ui/(.*) ws://localhost:9001/$1 [P,L]` (using mod_proxy_wstunnel) | `proxy_set_header Upgrade $http_upgrade;`, `proxy_set_header Connection "upgrade";` |
| Large Files/Timeouts | Prevents proxy time-outs during large file uploads/downloads. | `LimitRequestBody 0`, `ProxyTimeout 300` | `client_max_body_size 0;`, `proxy_read_timeout 300;` etc. |
| Host Header | Ensures the backend sees the correct public hostname (crucial for MinIO's S3 signature validation). | `ProxyPreserveHost On` | `proxy_set_header Host $host;` |

## 3. Apache Configuration Highlights (minio.conf)

The Apache configuration is split into three main parts: general settings, WebSocket handling, and routing.

### A. Required Modules

To run the `minio.conf` file, you must ensure these modules are enabled (via a2enmod):

- **ssl**: For HTTPS support.
- **headers**: For setting security headers.
- **proxy, proxy_http**: For basic reverse proxy functionality.
- **proxy_wstunnel**: Crucial for WebSockets used by the MinIO Console.
- **rewrite**: For the HTTP redirect and the WebSocket conditional rewrite.
- **alias**: For the Certbot challenge directory exclusion.

### B. MinIO Console WebSocket Handling

In Apache, WebSocket traffic must be explicitly captured and proxied using a different handler (ws://). This is done using mod_rewrite and mod_proxy_wstunnel before the standard ProxyPass rules:

```apache
# 1. Handle WebSockets for the console
RewriteEngine On
RewriteCond %{HTTP:Upgrade} websocket [NC]
RewriteCond %{REQUEST_URI} ^/minio/ui/.* [NC]

# Rewrites /minio/ui/path to ws://localhost:9001/path
RewriteRule ^/minio/ui/(.*) ws://localhost:9001/$1 [P,L]
```

### C. Large File Configuration

The settings to handle large file uploads (the Nginx client_max_body_size 0) and increased timeouts are set globally within the VirtualHost block:

```apache
# Enable large file uploads
LimitRequestBody 0

# Increase connection/data timeouts
ProxyTimeout 300
```

## 4. Nginx vs. Apache Summary

| Feature | Nginx Implementation | Apache Implementation |
|---------|---------------------|----------------------|
| S3 API Backend | `proxy_pass http://localhost:9000;` | `ProxyPass / http://localhost:9000/` |
| Console Backend | `proxy_pass http://minio_console;` | `ProxyPass /minio/ui/ http://localhost:9001/` |
| Path Stripping | `rewrite ^/minio/ui/(.*) /$1 break;` | Implicit in `ProxyPass /minio/ui/` |
| WebSockets | `proxy_set_header Upgrade $http_upgrade;`, `proxy_set_header Connection "upgrade";` | RewriteCond/RewriteRule using ws:// with mod_proxy_wstunnel |
| Max Body Size | `client_max_body_size 0;` | `LimitRequestBody 0` |

## 5. Example configs

### Apache2

```conf
# NOTE: This configuration requires the following Apache modules to be enabled:
# a2enmod ssl headers proxy proxy_http proxy_wstunnel alias rewrite

#####################################################################
# 1. HTTP to HTTPS Redirect (media.prestatus.com) - Best Practice
#####################################################################
<VirtualHost *:80>
    ServerName media.prestatus.com
    RewriteEngine On
    # Force redirect all HTTP traffic to HTTPS
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]

    # Certbot challenge directory (must be accessible on port 80)
    Alias /.well-known/acme-challenge/ /var/www/certbot/.well-known/acme-challenge/
    <Directory /var/www/certbot/.well-known/acme-challenge/>
        Require all granted
    </Directory>
</VirtualHost>

#####################################################################
# 2. HTTPS Reverse Proxy (media.prestatus.com) - MinIO S3 API and Console
#####################################################################
<VirtualHost *:443>
    ServerName media.prestatus.com

    # --- Logging (Nginx access_log/error_log equivalent) ---
    # Note: Apache error logging can be configured for 'debug' via LogLevel if needed
    ErrorLog /var/log/apache2/media.prestatus.com.error.log
    CustomLog /var/log/apache2/media.prestatus.com.log combined

    # --- SSL Configuration ---
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/media.prestatus.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/media.prestatus.com/privkey.pem
    # Include security settings if available (like the Certbot options)
    # Include /etc/letsencrypt/options-ssl-apache.conf
    
    # Security Headers
    Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains; preload"
    Header always set X-Frame-Options DENY
    Header always set X-Content-Type-Options nosniff

    # --- MinIO Specific Settings ---

    # Enable large file uploads (Nginx client_max_body_size 0 equivalent)
    # Setting to 0 disables the request body limit in Apache 2.4+
    LimitRequestBody 0 

    # Increase connection/data timeouts (Nginx proxy_*_timeout 300s equivalent)
    ProxyTimeout 300

    # Ensure proxy host is preserved and X-Forwarded-Proto is set for SSL
    ProxyPreserveHost On
    RequestHeader set X-Forwarded-Proto "https"
    
    # Nginx's `proxy_buffering off` is generally not needed in Apache for MinIO, 
    # but the above settings handle the core requirement for large file transfers.

    # Exclude ACME challenge before proxying
    ProxyPass /.well-known/acme-challenge/ !
    Alias /.well-known/acme-challenge/ /var/www/certbot/.well-known/acme-challenge/
    <Directory /var/www/certbot/.well-known/acme-challenge/>
        Require all granted
    </Directory>

    # --- 2a. MinIO Console/UI Proxy (location /minio/ui/) ---
    
    # 1. Handle WebSockets for the console (requires mod_proxy_wstunnel and mod_rewrite)
    # This must be defined BEFORE the main ProxyPass rule for /minio/ui/
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{REQUEST_URI} ^/minio/ui/.* [NC]
    # Rewrites /minio/ui/path to ws://localhost:9001/path
    RewriteRule ^/minio/ui/(.*) ws://localhost:9001/$1 [P,L]
    
    # 2. Main Console HTTP/HTTPS Proxy (MinIO Console runs on localhost:9001)
    # ProxyPass /minio/ui/ will automatically strip the path prefix for the backend, 
    # matching the Nginx rewrite rule.
    ProxyPass /minio/ui/ http://localhost:9001/
    ProxyPassReverse /minio/ui/ http://localhost:9001/

    # --- 2b. MinIO S3 API Proxy (location /) ---
    # MinIO S3 API runs on localhost:9000
    # This must be the last ProxyPass rule as it's the most general (location /)
    ProxyPass / http://localhost:9000/
    ProxyPassReverse / http://localhost:9000/

</VirtualHost>
```

### Nginx

```conf
upstream minio_s3 {
   least_conn;
   server localhost:9000;
}

upstream minio_console {
   least_conn;
   server localhost:9001;
}

# Main server block for HTTPS
server {
    listen 443 ssl;
    server_name media.prestatus.com;

    # SSL configuration - Certbot will populate these
    ssl_certificate /etc/letsencrypt/live/media.prestatus.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/media.prestatus.com/privkey.pem; # managed by Certbot

    # Enable large file uploads
    client_max_body_size 0;

    # Increase timeouts for large files
    proxy_connect_timeout 300;
    proxy_send_timeout 300;
    proxy_read_timeout 300;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_http_version 1.1;
        proxy_set_header Connection "";

        proxy_buffering off;
        proxy_request_buffering off;
        chunked_transfer_encoding off;

        proxy_pass http://localhost:9000;

        client_max_body_size 0;
    }

    location /minio/ui/ {
      rewrite ^/minio/ui/(.*) /$1 break;
      proxy_set_header Host $http_host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-NginX-Proxy true;
      real_ip_header X-Real-IP;
      proxy_connect_timeout 300;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      chunked_transfer_encoding off;

      proxy_pass http://minio_console; # This uses the upstream directive definition to load balance
   }

    # Add error logging
    error_log /var/log/nginx/media.prestatus.com.error.log debug;
    access_log /var/log/nginx/media.prestatus.com.log combined;
}
```
