# Docker tips

- [Dockerfile](dockerfile.md)
- [How To Remove Docker Containers, Images, Volumes, and Networks
  ](https://linuxize.com/post/how-to-remove-docker-images-containers-volumes-and-networks/)
- [Send mail from docker container](docker-mail.md)

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


## Docker machine

### Install on macOS

[ref](https://docs.docker.com/machine/install-machine/)

    base=https://github.com/docker/machine/releases/download/v0.16.0 &&
    curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/usr/local/bin/docker-machine &&
    chmod +x /usr/local/bin/docker-machine

Test

    $ docker-machine version
    docker-machine version 0.16.0, build 702c267f

It's good idea to also install `docker-machine` completion scripts

    base=https://raw.githubusercontent.com/docker/machine/v0.16.0
    for i in docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash
    do
       sudo wget "$base/contrib/completion/bash/${i}" -P /etc/bash_completion.d
    done

### Installing on Ubuntu 18.04

We will install Docker from Offical Repository

Download dependencies

    # aptitude update
    # aptitude install apt-transport-https ca-certificates curl software-properties-common

Add Docker's GPG Key

    # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

Install the Docker Repository and update

    # add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
    # aptitude update

Install Docker Community Edition

    # aptitude install docker-ce

## Docker Engine

[ref](https://docs.docker.com/install/linux/docker-ce/ubuntu/)

If you want to create your own Docker server

    # apt-get remove docker docker-engine docker.io containerd runc
    # apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    # apt-key fingerprint 0EBFCD88
    # add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    # apt-get update
    # apt-get install docker-ce docker-ce-cli containerd.io
    # apt-cache madison docker-ce
    # docker run hello-world
    # groupadd docker
    # usermod -aG docker pablito
    # su - pablito
    # systemctl enable docker
    # systemctl status docker

### DNS

[ref](https://development.robinwinslow.uk/2016/06/23/fix-docker-networking-dns/)

You need to change the DNS settings of the Docker daemon. You can set the default options for the docker daemon by creating a daemon configuration file at `/etc/docker/daemon.json`.

You should create this file with the following contents to set two DNS, firstly your network’s DNS server, and secondly the Google DNS server to fall back to in case that server isn’t available:

/etc/docker/daemon.json:

    {
        "dns": ["10.0.0.2", "8.8.8.8"]
    }

### Deployment

on chofero user env

-- local machine

    $ docker save -o image.zip chofero-docker
    $ scp image.zip chofero@beta.stupidfriendly.com:~/incoming

-- on server

    $ docker load -i ~/incoming/image.zip

Another option to deployment is to setup `docker host`

- [ref](https://www.digitalocean.com/community/tutorials/how-to-use-a-remote-docker-server-to-speed-up-your-workflow)
- [How To Set Up a Private Docker Registry on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-14-04)

```
$ export DOCKER_HOST=ssh://chofero@beta.stupidfriendly.com
$ docker build --rm -f Dockerfile -t chofero:latest .
```

And with [watchtower](https://hub.docker.com/r/v2tec/watchtower/) the container will update automatically with the new image.

    $ docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock --restart unless-stopped containrrr/watchtower --no-pull

#### Setting the network

Create a docker network, Every container on that network will be able to communicate with each other using the container name as hostname.

    $ docker network create -d bridge chofero-net

### Host Database

Docker creates a bridge named `docker0` by default. Both the docker host and the docker containers have an IP address on that bridge.

    $ sudo ip addr show docker0
    3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
        link/ether 02:42:1e:63:39:5d brd ff:ff:ff:ff:ff:ff
        inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
           valid_lft forever preferred_lft forever
        inet6 fe80::42:1eff:fe63:395d/64 scope link
           valid_lft forever preferred_lft forever

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

#### PHPMyAdmin

    $ docker pull phpmyadmin/phpmyadmin:latest

    $ docker run --name chofero-phpmyadmin -e PMA_HOST=chofero-mysql -d --network chofero-net --restart unless-stopped -p 8081:80 phpmyadmin/phpmyadmin

Run `phpmyadmin` for local instance of MySQL, (MacOs)

    $ docker run --name my-phpmyadmin -d -e PMA_HOST=host.docker.internal -e PMA_PORT=3306 -p 8080:80 phpmyadmin

#### Watchtower

    $ docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock --restart unless-stopped --no-pull containrrr/watchtower

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
