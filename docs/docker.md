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
    
   
