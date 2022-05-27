# Dockerfile

## Setting timezone

Set timezone to America/Mexico_City

    # On alpine image
    FROM golang:1.17-alpine3.15
    
    RUN apk add tzdata \
        && cp /usr/share/zoneinfo/America/Mexico_City /etc/localtime \
        && echo "America/Mexico_City" > /etc/timezone \
        && apk del tzdata
