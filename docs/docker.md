# Docker tips

[How To Remove Docker Containers, Images, Volumes, and Networks
](https://linuxize.com/post/how-to-remove-docker-images-containers-volumes-and-networks/)

#### Remove all stopped containers

Before performing the removal command, you can get a list of all non-running (stopped) containers that will be removed using the following command:

    $ docker container ls -a --filter status=exited --filter status=created 
 
To remove all stopped containers use the docker container prune command:

    $ docker container prune
    
You’ll be prompted to continue, use the -f or --force flag to bypass the prompt.

#### Stop all containers

    $ docker container stop $(docker container ls -aq)
    
   
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
    # chkconfig docker on
    
### Deployment

on chofero user env

-- local machine

    $ docker save -o image.zip chofero-docker
    $ scp image.zip chofero@beta.stupidfriendly.com:~/incoming

-- on server

    $ docker load -i ~/incoming/image.zip

Another option to deployment is to setup `docker host` 

* [ref](https://www.digitalocean.com/community/tutorials/how-to-use-a-remote-docker-server-to-speed-up-your-workflow)
* [How To Set Up a Private Docker Registry on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-14-04)

```
$ export DOCKER_HOST=ssh://chofero@beta.stupidfriendly.com
$ docker build --rm -f Dockerfile -t chofero:latest .
```

And with [watchtower](https://hub.docker.com/r/v2tec/watchtower/) the container will update automatically with the new image.


