# MySQL on docker

ref: [MySQL Docker containers: the basics](https://severalnines.com/database-blog/mysql-docker-containers-understanding-basics)

## Installing

Create user

    # useradd -m mysql
    
Add user to docker group

    # usermod -aG docker

Go to user's home

    # su - mysql
    
Create container using official [MySQL Docker image](https://hub.docker.com/_/mysql)

    $ docker run --name=beta-mysql mysql

That command will fail because of mising root password

    $ docker run --detach --name=beta-mysql --env="MYSQL_ROOT_PASSWORD=mypassword" mysql
    
View container logs to confirm server is up and running

    $ docker logs -f beta-mysql
    
    
## Connecting to the Container

mysql client must be installed on host machine `apt-get install mysql-client`

Retrieve IP address using:

    $ docker inspect beta-mysql | grep IPAddress
        "IPAddress": "172.17.0.21",
    $ mysql -uroot -pmypassword -h 172.17.0.21 -P 3306
    
To connect with another container, e.g. a wordpress container

    $ docker run --detach --name beta-wordpress --link beta-mysql:mysql wordpress
    
With the `--link` parameter the new container will have an alias name in `/etc/hosts` file

    $ docker exec -it test-wordpress bash
    root@0cb9f4152022:/var/www/html# cat /etc/hosts
    172.17.0.22    0cb9f4152022
    127.0.0.1    localhost
    ::1    localhost ip6-localhost ip6-loopback
    fe00::0    ip6-localnet
    ff00::0    ip6-mcastprefix
    ff02::1    ip6-allnodes
    ff02::2    ip6-allrouters
    172.17.0.21    mysql 0a7aa1cf196e beta-mysql
    
## Expose MySQL container to the outside world

You can also expose the MySQL container to the outside world by mapping the container’s MySQL port to the host machine port using the publish flag (as illustrated in the above diagram). Let’s re-initiate our container and run it again with an exposed port:

    $ docker rm -f beta-mysql
    $ docker run --detach --name=beta-mysql --env="MYSQL_ROOT_PASSWORD=mypassword" --publish 6603:3306 mysql
    
    
Verify if the container is correctly mapped:

    CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                    NAMES
    8d97b70658a9        mysql:latest        "docker-entrypoint.s   3 seconds ago       Up 3 seconds        0.0.0.0:6603->3306/tcp   beta-mysql
    0cb9f4152022        wordpress:latest    "/entrypoint.sh apac   15 minutes ago      Up 15 minutes       80/tcp                   beta-wordpress
 
At this point, we can now access the MySQL container directly from the machine’s port 6603.

