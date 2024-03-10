## ElKondo

## Enabling the Artifact Registry

* console: https://console.cloud.google.com/artifacts?authuser=1&project=elkondo

Adding credentials for: us-central1-docker.pkg.dev

    $ gcloud auth configure-docker \
        us-central1-docker.pkg.dev

Set the default region to: us-central1

    $ gcloud config set compute/region us-central1
    $ gcloud config set run/region us-central1

Create a Docker repository:

    $ gcloud artifacts repositories create dockerfiles  --repository-format=docker --project elkondo \
        --location us-central1 --description "Dockerfiles for elkondo"

List the repositories:

    $ gcloud artifacts repositories list --project elkondo

Before you push the Docker image to Artifact Registry, you must tag it with the repository name.

Backend

    $ docker tag elkondo:latest us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo:latest

Frontend

    $ docker tag elkondo-ui:latest us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo-ui:latest

Fullstack*
    
    $ docker tag elkondo-fullstack:latest us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo-fullstack:latest

Database

    $ docker tag elkondo-db:latest us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo-db:latest

Push image to Artifact Registry

    $ docker push us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo:latest
    $ docker push us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo-ui:latest
    $ docker push us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo-fullstack:latest
    $ docker push us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo-db:latest

Clean up local images

    $ docker rmi us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo:latest
    $ docker rmi us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo-ui:latest
    $ docker rmi us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo-fullstack:latest

Clean up remote repository

    $ gcloud artifacts repositories delete dockerfiles --location=us-central1

### Building the container image

Build your container image using Cloud Build by running the following command from the directory containing your Dockerfile:

    $ gcloud builds submit --tag gcr.io/elkondo/elkondo:latest .

    Upon success, you will see a SUCCESS message containing the image name
    (gcr.io/PROJECT_ID/helloworld).


### Mapping custom domain name to a service

    $ gcloud beta run domain-mappings create --service elkondo-fullstack --domain elkondo.com

    $ gcloud beta run domain-mappings describe --domain elkondo.com

### Delete domain mapping

    $ gcloud beta run domain-mappings delete --domain elkondo.com


## Managing revisions

ref: https://cloud.google.com/run/docs/managing/revisions#command-line

List of services:
    
    $ gcloud run services list
    $ gcloud run services describe elkondo-fullstack

List revisions for a service: (elkondo-fullstack)

    $ gcloud run revisions list --service elkondo-fullstack

    $ gcloud run revisions describe elkondo-fullstack-00001-yul

List images in artifact registry:

    $ gcloud artifacts docker images list us-central1-docker.pkg.dev/elkondo/dockerfiles --include-tags

## Rollouts and traffic

ref: https://cloud.google.com/run/docs/rollouts-rollbacks-traffic-migration

Deploy a revision with no traffic:

    $ gcloud run deploy elkondo-fullstack --image us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo-fullstack:latest --no-traffic

If using VPC Connector

    $ gcloud run deploy elkondo-fullstack --image us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo-fullstack:latest  --no-traffic --tag staging --vpc-connector konnector

To send all traffic to the most recently deployed revision:

    $ gcloud run services update-traffic elkondo-fullstack --to-latest

Using tags for testing, traffic migration and rollbacks

    $ gcloud run deploy elkondo-fullstack --image us-central1-docker.pkg.dev/elkondo/dockerfiles/elkondo-fullstack:latest  --no-traffic --tag staging

After confirming that the new revision works properly, you can start migrating traffic to it

    $ gcloud run services update-traffic elkondo-fullstack --to-tags staging=100


## Creating and accessing secrets

Create a secret:

    $ gcloud secrets create DB_PASSWORD --replication-policy="automatic"

Adding a secret version:

    $ gcloud secrets versions add DB_PASSWORD --data-file=secret.txt

optionally, you can add it from the command line:

    $  echo -n "s3cr3t" | gcloud secrets versions add DB_PASSWORD --data-file=-


## Using Cloud Storage to store the contents fot the application ui

**This does't work yet**

ref: https://medium.com/bb-tutorials-and-thoughts/building-angular-static-website-with-gcp-cloud-storage-be3410f881a8

Create a new bucket on project `elkondo`:

    $ gsutil mb -p elkondo -c STANDARD -l US-CENTRAL1 -b on gs://elkondo-ui

Display bucket metadata:

    $ gsutil ls -L -b gs://elkondo-ui

Grant anyone the ability to read the bucket:

    $ gsutil iam ch allUsers:objectViewer gs://elkondo-ui

Set index and error page, otherwise the bucket will return a 404 error:

    $ gsutil web set -m index.html -e error.html gs://elkondo-ui

Copy the contents of the directory containing your Angular app to the bucket:

    $ gsutil -m cp -r ./dist/angular-fe gs://elkondo-ui

Delete previous contents of the bucket:

    $ gsutil -m rm -r gs://elkondo-ui/angular-fe

Sync the contents of the directory containing your Angular app to the bucket:

    $ gsutil -m rsync -d -r ./dist/angular-fe gs://elkondo-ui

### Set Load Balancer

ref: https://cloud.google.com/cdn/docs/setting-up-cdn-with-bucket#gcloud

    $ gcloud compute forwarding-rules create elkondo-http-rule \
        --global \
        --target-http-proxy elkondo-http-proxy \
        --ports 80 \
        --address elkondo-http-lb

Reserve an external IP address:

    $ gcloud compute addresses create elkondo-http-ip \
        --ip-version=IPV4 \
        --global

Note the IP address:

    $ gcloud compute addresses list --global

Remove the IP address:

    $ gcloud compute addresses delete elkondo-http-ip

Create external http load balancer

    $ gcloud compute backend-buckets create cat-backend-bucket \
        --load-balancing-scheme=EXTERNAL \
        --gcs-bucket-name=elkondo-ui \
        --enable-cdn
        