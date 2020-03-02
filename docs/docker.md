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

