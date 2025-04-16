# Sending mail from docker container

When running an application inside a Docker container, you might need it to send email via an SMTP server running on the host machine (e.g., Postfix).

## 1. Configure Application Mail Client

Your application needs to know the address of the SMTP server. Inside the container, you can usually reach the host machine using the special DNS name `host.docker.internal`. This is generally the recommended approach.

Set your application's mail host configuration to `host.docker.internal`.

```python
# Example Python configuration (adapt for your language/framework)
mail.smtp.server = "host.docker.internal"
mail.smtp.port = 25 # Or the port your host SMTP server listens on
```

**Note:** `host.docker.internal` is available in Docker Desktop (Mac/Windows) and recent Docker Engine versions on Linux. If it doesn't resolve, you might need to find the host's IP address on the Docker bridge network (often `172.17.0.1` for the default bridge, but check your network setup).

## 2. Configuring Postfix on the Host

The Postfix server running on the host machine needs to be configured to accept connections from the Docker container's network. This configuration needs to be done on the *host machine*, not inside the container.

Edit the Postfix configuration file, typically located at `/etc/postfix/main.cf`.

Find the `mynetworks` directive. This setting defines the list of "trusted" IP addresses or networks that are allowed to relay mail through this server without further authentication. Add the Docker network range to this list. The default Docker bridge network is usually `172.17.0.0/16`.

```cf
# /etc/postfix/main.cf
# Add your Docker network range (e.g., 172.17.0.0/16)
# Ensure existing entries like loopback are kept
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 172.17.0.0/16
```

After modifying `main.cf`, reload the Postfix configuration:

```bash
sudo systemctl reload postfix
```

## 3. Alternative Approaches

*   **External SMTP Services:** Use services like SendGrid, Mailgun, AWS SES, etc. Your container connects directly to their servers over the internet. This often simplifies setup and avoids managing a local mail server.
*   **Dedicated Mail Container:** Run a mail relay service (like Postfix itself, or a development tool like MailHog) in another container. Your application container connects to the mail relay container.

## 4. Security Considerations

Adding your Docker network range to `mynetworks` allows *any* container on that network to relay mail through your host's Postfix server without authentication. If untrusted containers might run on the same network, consider implementing SMTP authentication or firewall rules for tighter security.
