# Dockerfile

## Setting timezone

Set timezone to America/Mexico_City

    # On alpine image
    FROM golang:1.17-alpine3.15
    
    RUN apk add tzdata \
        && cp /usr/share/zoneinfo/America/Mexico_City /etc/localtime \
        && echo "America/Mexico_City" > /etc/timezone \
        && apk del tzdata

## Python virtual environments

To create a python virtual environment inside a Dockerfile

    FROM python:3.9-bullseye

    ENV VIRTUAL_ENV=/opt/venv
    RUN python3 -m venv $VIRTUAL_ENV
    ENV PATH="$VIRTUAL_ENV/bin:$PATH"

    # Install dependencies:
    COPY requirements.txt .
    RUN pip install -r requirements.txt

    # Run the application:
    COPY main.py .
    CMD ["python", "main.py"]

## Example Dockerfiles

* [Angular frontend with golang backend](dockerfile-angular-golang.md)
* [Flutter web with golang backend](dockerfile-flutter-golang.md)

