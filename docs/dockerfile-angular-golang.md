```docker
## docker build --rm -f Dockerfile -t app:latest .
## docker run -ti --entrypoint=sh app:latest
## Stage 1 - Build backend
FROM golang:1.21-alpine3.18 as backend

WORKDIR /app

# Install build dependencies
ARG BUILD_DEPS="git ca-certificates openssh build-base libxslt-dev libxml2-dev zlib-dev"

RUN apk update && apk add --no-cache ${BUILD_DEPS} \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* \
    && update-ca-certificates

# Create appuser
ENV USER=appuser
# Get your host's user UID (id -u pdp)
ENV UID=1027

# See https://stackoverflow.com/a/55757473/12429735RUN 
RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"

# Set timezone to America/Mexico_City
ENV TZ=America/Mexico_City
RUN apk add tzdata \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

# Add the private key to the container
# See https://medium.com/@lightsoffire/how-to-use-golang-private-modules-with-docker-553ff43fa117
ARG SSH_PRIVATE_KEY
RUN git config --global url.ssh://git@github.com/.insteadOf https://github.com/

# Make ssh dir
RUN mkdir -p /root/.ssh/ && \
    echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 700 /root/.ssh/ && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts

# Go dependencies
# copy go modules dependencies files
COPY server/go.* ./

# download go modules dependencies
RUN go mod download

# remove private key
RUN rm -rf /root/.ssh/id_rsa

# Compile
COPY server .

# CGO_ENABLED=0 staticaly-linked binary
# ldflags -s `disable symbol table` -w `disable DWARF generation`
RUN CGO_ENABLED=1 go build -ldflags="-w -s" -o /pdp ./cmd/web/*.go

# Give appuser ownership over the binary
RUN chown appuser:appuser /pdp

# create folders with appuser ownership
RUN mkdir -p /html && chown -R appuser:appuser /html

## Stage 2 - Build frontend
FROM node:18-alpine3.18 as frontend

WORKDIR /angular

RUN npm install -g @angular/cli@17

COPY angular/package* ./

# Install dependencies, we're using npm ci as opposed to the regular npm
# install, since the former is more fit for productions environments
# ref: https://docs.npmjs.com/cli/v8/commands/npm-ci
RUN npm ci

# Copy the rest of the files
COPY angular .

# Build the app
RUN ng build --configuration production --vendor-chunk=true 

# Clear all the dev dependencies from the "node_modules" 
RUN npm prune --production

## Stage 3 - Final
FROM golang:1.21-alpine3.18

# Import the user and group files from the builder.
COPY --from=backend /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=backend /etc/timezone /etc/timezone
COPY --from=backend /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=backend /etc/passwd /etc/passwd
COPY --from=backend /etc/group /etc/group

# Default dir
WORKDIR /app

# Copy frontend files
COPY --from=backend /app/config.prod.json /app/config.json
COPY --from=backend /pdp /app/pdp
COPY --from=backend /html /app/html

# Copy our static executable
COPY --from=frontend /angular/dist/angular /app/html

# Use an unprivileged user
USER appuser:appuser

# Port on which the service will be exposed
EXPOSE 5000

# Run the app binary
CMD [ "./pdp", "--production", "true"]
```
