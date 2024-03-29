# Gcloud notes
## Update components

    $ gcloud components updates


## Enabling the Artifact Registry

* console: https://console.cloud.google.com/artifacts?authuser=1

Adding credentials for: us-central1-docker.pkg.dev

    $ gcloud auth configure-docker \
        us-central1-docker.pkg.dev

Create a Docker repository:

    $ gcloud artifacts repositories create my-dockerfiles  --repository-format=docker --project my-project \
        --location us-central1 --description "Dockerfiles for my-project"

List the repositories:

    $ gcloud artifacts repositories list --project my-project

Before you push the Docker image to Artifact Registry, you must tag it with the repository name. We will use `us-central1-docker.pkg.dev` zone.

If you use Artifact Registry, the [repository](https://cloud.google.com/artifact-registry/docs/repositories/create-repos#docker) REPO_NAME must already be created. The URL has the shape `REGION-docker.pkg.dev/PROJECT_ID/REPO_NAME/PATH:TAG` .

    $ docker tag my_docker_image:latest us-central1-docker.pkg.dev/my-project/my-dockerfiles/my_docker_image:latest

Push image to Artifact Registry

    $ docker rmi us-central1-docker.pkg.dev/my-project/my-dockerfiles/my_docker_image:latest

Clean up remote repository

    $ gcloud artifacts repositories delete dockerfiles --location=us-central1

