```docker
##########
# Stage 1. Build flutter files, Ubuntu is best suited
FROM ubuntu:22.04 as build_front

# Set timezone
ENV TZ=America/Mexico_City

# Install dependencies
RUN apt-get update && apt-get install -y curl wget unzip git

# Install flutter
RUN git clone https://github.com/flutter/flutter.git -b stable

# Add flutter path
ENV PATH "$PATH:/flutter/bin"

# Run flutter, this will download Dart sdk in a separate step from building for web
# lets take advantage of dockers cache
RUN flutter

WORKDIR app

# Copy src
ADD flutter_src .

# Build for web, avoid font error ref:https://github.com/flutter/flutter/issues/119074
RUN flutter build web --no-tree-shake-icons

##########
# Stage 2. Build the backend and html server
FROM golang:1.20-alpine3.16 as build_back

WORKDIR app

# Install git.
# Git is required for fetching the dependencies.
# gcc and musl-dev required to compile sqlite-3 dependencies for go
RUN apk update && apk add --no-cache \
  git \
  gcc \
  musl-dev \
  ca-certificates \
  tzdata \
  # clean up
  && rm -rf /tmp/* \
  && update-ca-certificates

# Set timezone
ENV TZ=America/Mexico_City

# Install tzdata package to set the timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create appuser.
ENV USER=appuser
# Using host's `australqc` UID (id -u australqc)
ENV UID=1024

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
  --disabled-password \
  --gecos "" \
  --home "/nonexistent" \
  --shell "/sbin/nologin" \
  --no-create-home \
  --uid "${UID}" \
  "${USER}"

## Go dependencies
# copy go modules dependencies files
COPY server/go.* .

# download go modules dependencies
RUN go mod download

# build binary
ADD server .

# CGO_ENABLED=0 staticaly-linked binary
# ldflags -s `disable symbol table` -w `disable DWARF generation`
RUN CGO_ENABLED=0 go build -ldflags="-w -s" -o /go/bin/app cmd/web/*.go

# give appuser ownership over the binary
RUN chown appuser:appuser /go/bin/app

# create folders with appuser ownership
RUN mkdir -p /html && chown -R appuser:appuser /html
RUN chown -R appuser:appuser /go/app/assets


############
## Stage 3 - Prod
# lib for pdf generation. ref: https://github.com/Surnet/docker-wkhtmltopdf
# FROM surnet/alpine-wkhtmltopdf:3.16.2-0.12.6-full as wkhtmltopdf
# FROM scratch
FROM ubuntu:22.04

# Set timezone
ENV TZ=America/Mexico_City

RUN apt-get update && apt-get install -y wkhtmltopdf

# Import the user and group files from the builder.
COPY --from=build_back /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=build_back /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build_back /etc/passwd /etc/passwd
COPY --from=build_back /etc/group /etc/group

# Set timezone in final stage
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set default env values
ENV ENV=prod
RUN echo "The ENV variable value is $ENV"
# Enable production config
COPY --from=build_back /go/app/config.${ENV}.json /config.json
# Copy the binary to the production image from the builder
COPY --from=build_back /go/bin/app /
# Copy assets to the production image from the builder
COPY --from=build_back /go/app/assets /assets
# Copy html folder with ownership
COPY --from=build_back /html /html

# Copy the build flutter app
COPY --from=build_front /app/build/web html

# There's no chown in `scratch` that's why we set ownership in previous step
# Give appuser ownership over the application and html directory.
# RUN chown -R appuser:appuser /app
# RUN chown -R appuser:appuser /html

# Use an unprivileged user.
USER appuser:appuser

EXPOSE 5000

CMD [ "/app", "--production" ]
```
