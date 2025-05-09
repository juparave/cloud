# Docker tips

- [Dockerfile](dockerfile.md)
- [How To Remove Docker Containers, Images, Volumes, and Networks
  ](https://linuxize.com/post/how-to-remove-docker-images-containers-volumes-and-networks/)
- [Send mail from docker container](docker-mail.md)

## Table of Contents

- [Remove all stopped containers](#remove-all-stopped-containers)
- [Stop all containers](#stop-all-containers)
- [Remove dangling images](#remove-dangling-images)
- [Remove images by pattern](#remove-images-by-pattern)
- [Remove images by age](#remove-images-by-age)
- [Clean docker script](#clean-docker-script)
- [Debug Docker images](#debug-docker-images)
- [Restart a docker container](#restart-a-docker-container)
- [Installing Docker Engine on Ubuntu](#installing-docker-engine-on-ubuntu)
- [DNS](#dns)
- [Deployment](#deployment)
- [Host Database](#host-database)
- [Docker Database](#docker-database)
- [SSL on nginx](#ssl-on-nginx)
- [certbot with nginx](#certbot-with-nginx)
- [Run the application](#run-the-application)
- [PHPMyAdmin](#phpmyadmin)
- [Using Docker Compose](#using-docker-compose)
- [Docker logs](#docker-logs)
- [Troubleshooting](#troubleshooting)

#### Remove all stopped containers

Before performing the removal command, you can get a list of all non-running (stopped) containers that will be removed using the following command:

    $ docker container ls -a --filter status=exited --filter status=created

To remove all stopped containers use the docker container prune command:

    $ docker container prune

You’ll be prompted to continue, use the -f or --force flag to bypass the prompt.

#### Stop all containers

    $ docker container stop $(docker container ls -aq)

#### Remove dangling images

A dangling image is an image that is not tagged and is not used by any container. To remove dangling images type:

    $ docker image prune

#### Remove images by pattern

    $ docker images -a |  grep "chofero"
    $ docker images -a |  grep "chofero" | awk '{print $3}' | xargs docker rmi

#### Remove images by age

    # 720 hours = 30 days and older
    $ docker image prune --all --filter "until=720h"

#### Clean docker script

```bash
#!/bin/bash
# Remove all stopped containers
echo "Removing all stopped containers"
docker container prune -f

# Remove all dangling images
echo "Removing all dangling images"
docker image prune -a -f
```

## Debug Docker images

Common flags:

```
-t              : Allocate a pseudo-tty
-i              : Keep STDIN open even if not attached
--rm             : Automatically clean up the container and remove the file system when the container exits
```

### Start/run with a different entry point

Start a stopped Docker container with a different command

    $ docker run -ti --entrypoint=sh telopromo:v0.1

### Open a shell into a running container

    $ docker exec -ti telopromo-run /bin/sh

### Open a shell on a conatiner image, for testing

    $ docker run -ti --rm --entrypoint=sh python:3.8-alpine3.14

or

    $ docker run --rm -i -t python:3.9-slim-buster /bin/sh

For size

    $ docker image build --no-cache -t build-context -f - . <<EOF
    FROM busybox
    WORKDIR /build-context
    COPY . .
    CMD find .
    EOF
    $ docker container run --rm -it build-context /bin/sh

For testing in old python with mapped path

    $ docker run -ti --rm -v "$(pwd)":/app -p 8080:8080 --entrypoint=sh python:2.7

### Restart a docker container

    $ docker restart telopromo-run

## Installing Docker Engine on Ubuntu

[Official Docker Engine installation guide for Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

```bash
# Uninstall old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Set up the repository
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Verify installation
sudo docker run hello-world

# Post-installation steps (Run Docker as a non-root user)
sudo groupadd docker
sudo usermod -aG docker $USER
# Log out and log back in for this to take effect, or run: newgrp docker

# Configure Docker to start on boot
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

### Docker Desktop (macOS / Windows / Linux)

For local development on macOS, Windows, and some Linux distributions, [Docker Desktop](https://www.docker.com/products/docker-desktop/) is often the easiest way to get started. It includes Docker Engine, the Docker CLI client, Docker Compose, and more.

## DNS

[ref](https://development.robinwinslow.uk/2016/06/23/fix-docker-networking-dns/)

You need to change the DNS settings of the Docker daemon. You can set the default options for the docker daemon by creating a daemon configuration file at `/etc/docker/daemon.json`.

You should create this file with the following contents to set two DNS, firstly your network’s DNS server, and secondly the Google DNS server to fall back to in case that server isn’t available:

/etc/docker/daemon.json:

```json
{
    "dns": ["10.0.0.2", "8.8.8.8"]
}
```

## Deployment

on chofero user env

-- local machine

    $ docker save -o image.zip chofero-docker
    $ scp image.zip chofero@beta.stupidfriendly.com:~/incoming

-- on server

    $ docker load -i ~/incoming/image.zip

### Using a Docker Registry

While `docker save`/`load` works, a more common approach is to push your built image to a Docker registry (like Docker Hub or a private registry) and pull it on the server.

```bash
# Example: Tag and push to Docker Hub
docker tag chofero:latest your-dockerhub-username/chofero:latest
docker push your-dockerhub-username/chofero:latest

# On the server
docker pull your-dockerhub-username/chofero:latest
# Then run the container using the pulled image
```
See also: [Private Docker Registry Notes](docker-registry.md)

Another option to deployment is to setup `docker host`

- [ref](https://www.digitalocean.com/community/tutorials/how-to-use-a-remote-docker-server-to-speed-up-your-workflow)
- [How To Set Up a Private Docker Registry on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-14-04)

```
$ export DOCKER_HOST=ssh://chofero@beta.stupidfriendly.com
$ docker build --rm -f Dockerfile -t chofero:latest .
```

And with [watchtower](https://hub.docker.com/r/v2tec/watchtower/) the container will update automatically with the new image.

    $ docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock --restart unless-stopped containrrr/watchtower --no-pull

## Host Database

Docker creates a bridge named `docker0` by default. Both the docker host and the docker containers have an IP address on that bridge.

    $ sudo ip addr show docker0
    3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
        link/ether 02:42:1e:63:39:5d brd ff:ff:ff:ff:ff:ff
        inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
           valid_lft forever preferred_lft forever
        inet6 fe80::42:1eff:fe63:395d/64 scope link
           valid_lft forever preferred_lft forever

### Connecting to the Host from a Container

To allow a container to connect to a service running on the host machine:
*   On **Docker Desktop (macOS, Windows)**, use the special DNS name `host.docker.internal`.
*   On **Linux**, you can typically use the gateway IP of the `docker0` bridge (often `172.17.0.1` by default, check with `ip addr show docker0`).

You might still need to configure host firewall rules (like the `csf` example below) to allow connections from the Docker network IPs (e.g., `172.17.0.0/16`).

laforge server is protected with csf allow docker network to connect by modifying `/etc/csf/csf.allow` adding:

    tcp|in|d=3306|s=172.17.0.0/24
    tcp|out|d=3306|d=172.17.0.0/24

`172.17.0.0` is the docker network interface on 16 bits but we close it to 24 bits

Then in MySQL side, the user has to have the correct permission

    > CREATE USER 'telopromo'@'172.17.0.0/255.255.255.0' IDENTIFIED WITH mysql_native_password AS '***';
    > GRANT ALL PRIVILEGES ON `telopromo`.* TO 'telopromo'@'172.17.0.1/255.255.255.0';
    > GRANT ALL PRIVILEGES ON `telopromo\_%`.* TO 'telopromo'@'172.17.0.0/255.255.255.0';

#### Docker Database

1. Create a data directory on the host system, e.g. `/home/chofero/data`
2. Start your mysql container like this (mysql v5.7):

   $ docker run --name chofero-mysql -v /home/chofero/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d --network chofero-net --restart unless-stopped mysql:5.7

Run commands inside container

    $ docker exec -it chofero-mysql bash

Create database

    mysql> CREATE DATABASE IF NOT EXISTS `chofero` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

Create local user

    mysql> CREATE USER 'chofero'@'localhost' IDENTIFIED WITH mysql_native_password AS '***';
    mysql> GRANT USAGE ON *.* TO 'chofero'@'localhost';
    mysql> GRANT ALL PRIVILEGES ON `chofero`.* TO 'chofero'@'localhost';
    mysql> GRANT ALL PRIVILEGES ON `chofero\_%`.* TO 'chofero'@'localhost';

Create remote user, try to limit access only to your app host

    mysql> CREATE USER 'chofero'@'%' IDENTIFIED WITH mysql_native_password AS '***';
    mysql> GRANT USAGE ON *.* TO 'chofero'@'%';
    mysql> GRANT ALL PRIVILEGES ON `chofero`.* TO 'chofero'@'%';
    mysql> GRANT ALL PRIVILEGES ON `chofero\_%`.* TO 'chofero'@'%';

##### Importing data

    $ docker exec -i chofero-mysql mysql -uroot -psecret chofero < chofero.sql

or

    $ docker exec -i chofero-mysql mysql -uroot -p"$CHOFERO_PASS" chofero < chofero.sql

#### SSL on nginx

ref: https://medium.com/faun/setting-up-ssl-certificates-for-nginx-in-docker-environ-e7eec5ebb418

Copy private key and crt to `/etc/ssl/chofero`

#### certbot with nginx

certbot is a tool for handlig free SSL certificates. ref: https://absolutecommerce.co.uk/blog/auto-renew-letsencrypt-nginx-certbot

    # apk add certbot certbot-nginx

Run certbox for nginx configuration

    # certbot --nginx

Configuration generated by certbot `/etc/nginx/conf.d/nginx.conf`

```
server {
    listen 443 ssl;
    server_name stage.chofero.com;
    ssl_certificate /etc/letsencrypt/live/stage.chofero.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/stage.chofero.com/privkey.pem; # managed by Certbot

    location / {
        include uwsgi_params;
        uwsgi_param SCRIPT_NAME '';
        uwsgi_pass localhost:9000;
        # uwsgi_pass 172.17.0.2:9000;
    }

}
server {
    if ($host = stage.chofero.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name stage.chofero.com;
    return 404; # managed by Certbot


}
```

Copy certificate to host, running from host

    $ docker cp chofero-run:/etc/letsencrypt/archive/stage.chofero.com .
    $ cp ~chofero/incoming/stage.chofero.com/fullchain1.pem ~chofero/incoming/stage.chofero.com/privkey1.pem /etc/ssl/chofero

#### Run the application

With new image, this will create a new container

    $ docker run -d -p 80:80 -p 443:443 --name chofero-run -v /etc/ssl/chofero:/etc/ssl/chofero --network chofero-net --restart unless-stopped chofero

Stop and Delete previous container

    $ docker stop chofero-run
    $ docker rm chofero-run


With existing container

    $ docker container start chofero-run

View logs

    $ docker logs chofero-run

Grep logs

    $ docker logs chofero-run 2>&1 | grep "auth"

#### PHPMyAdmin

    $ docker pull phpmyadmin/phpmyadmin:latest

    $ docker run --name chofero-phpmyadmin -e PMA_HOST=chofero-mysql -d --network chofero-net --restart unless-stopped -p 8081:80 phpmyadmin/phpmyadmin

Run `phpmyadmin` for local instance of MySQL, (MacOs)

    $ docker run --name my-phpmyadmin -d -e PMA_HOST=host.docker.internal -e PMA_PORT=3306 -p 8080:80 phpmyadmin

## Using Docker Compose

[Docker Compose](https://docs.docker.com/compose/) is a tool for defining and running multi-container Docker applications. It uses a YAML file (typically `docker-compose.yml`) to configure the application's services, networks, and volumes.

Using Compose simplifies the management of related containers, like the application, database (MySQL), and utility (phpMyAdmin) examples shown previously using individual `docker run` commands.

**Example `docker-compose.yml` structure:**

```yaml
version: '3.8'
services:
  app:
    build: . # Or image: your-app-image
    ports:
      - "80:80"
      - "443:443"
    networks:
      - app-net
    volumes:
      - /path/on/host:/path/in/container
    depends_on:
      - db

  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: your_secret_password
      MYSQL_DATABASE: your_database
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - app-net

  phpmyadmin:
     image: phpmyadmin/phpmyadmin
     ports:
       - "8081:80"
     environment:
       PMA_HOST: db
     networks:
       - app-net
     depends_on:
       - db

networks:
  app-net:
    driver: bridge

volumes:
  db_data:
```

You can then manage the application stack with commands like `docker compose up -d`, `docker compose down`, `docker compose logs`, etc.

## Docker logs

ref: https://www.baeldung.com/ops/docker-logs

Clear logs

    # truncate -s 0 /var/lib/docker/containers/*/*-json.log 

Provide the configuration of log max-size and max-file in the /etc/docker/daemon.json file

```json
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100k", // or "10m"
        "max-file": "5" 
    }
}
```

## Troubleshooting

### iptables

    docker: Error response from daemon: driver failed programming external
    connectivity on endpoint acosta-wordpress-prod-run
    (90c088970113c4da5764fdf3a4a225b988945d7e94420998f590613474159a51):
    (iptables failed: iptables --wait -t nat -A DOCKER -p tcp -d 0/0 --dport
    8081 -j DNAT --to-destination 172.17.0.2:80 ! -i docker0: iptables: No
    chain/target/match by that name.

Solved by clearing iptables and restarting docker service

    # iptables -t filter -F
    # iptables -t filter -X
    # service docker restart

### Firewall

On a machine I have two Docker networks 172.17.0.0 and 172.18.0.0 (bridge).  
Found a script related [csf_docker.sh](https://raw.githubusercontent.com/sensson/puppet-csf/master/templates/csf_docker.sh)
