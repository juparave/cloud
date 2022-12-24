# Deploying Sveltkit with Docker

Sample `Dockerfile` with 3 stages, building from on stage 1

```Dockerfile
# Stage 1 - Build frontend. Sveltekit app
FROM node:16-alpine as build_front

WORKDIR /build

COPY svelte/package.json /build/svelte/

RUN cd svelte && npm install 

COPY svelte svelte

RUN cd svelte && npm run build

# Stage 2 - Build backend
FROM golang:1.17-alpine3.15 as build_back

WORKDIR /build

# Install for go-sqlite3
# gcc and musl-dev required to compile sqlite-3 dependencies for go
ARG BUILD_DEPS="gcc musl-dev"
RUN apk update && apk add --no-cache ${BUILD_DEPS}

# Go dependencies
COPY go-app/go.* ./
RUN go mod download

# Compile
COPY go-app .
RUN go build -ldflags="-w -s" -o app ./main.go

# Stage 3. Create server
FROM golang:1.17-alpine3.15

WORKDIR /app

# Install node
ARG RUN_DEPS="nodejs"
RUN apk update && apk add --no-cache ${RUN_DEPS}

COPY --from=build_front /build/svelte/build sveltekit
COPY --from=build_back /build/app .
COPY startup.prod.sh .

# create a package.json to avoid SyntaxError: Cannot use import statement outside a module
RUN echo '{ "type":"module" }' > sveltekit/package.json

EXPOSE 3000
# EXPOSE 5000

# Run
ENTRYPOINT ["./startup.prod.sh", "--production", "true"]
```

On the last stage we install `nodejs` to run the sveltekit app.  To avoid
`message	"Cross-site POST form submissions are forbidden"` we can
modify `svelte.config.js`

```javascript
import adapter from '@sveltejs/adapter-node'

const config = {
  kit: {
    adapter: adapter(),
    csrf: {
      checkOrigin: false,
    }
  },
}

export default config
```

This is not considered good practice, so instead, in the running script
`startup.prod.sh` we add `ORIGIN=http://localhost:3000` env var, like this.

```sh 
#!/bin/ash

set -e

# start node server for sveltekit app
cd /app/sveltekit && ORIGIN=http://localhost:3000 node index.js &

# start app server
cd /app && ./app
```
