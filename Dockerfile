FROM alpine
MAINTAINER izikaj@gamil.com

RUN apk update && apk upgrade --available \
 && echo http://public.portalier.com/alpine/testing >> /etc/apk/repositories \
 && wget http://public.portalier.com/alpine/julien%40portalier.com-56dab02e.rsa.pub -O /etc/apk/keys/julien@portalier.com-56dab02e.rsa.pub \
 && apk update && apk add --no-cache crystal openssl gmp \
 && apk add --no-cache --virtual .build shards gcc g++ make openssl-dev gmp-dev \
 && mkdir -p /app
WORKDIR /app

COPY . ./

RUN shards update \
 && rm -rf bin/geoip \
 && mkdir -p bin \
 && crystal build src/geoip.cr -o bin/geoip --release --no-debug --stats --progress \
 && apk del .build \
 && rm -rf .shards lib dev spec docker-compose* shard* sentry* geoip* README.md LICENSE Dockerfile* \
 && rm -rf .DS_Store .crystal-version .dockerignore .editorconfig .gitignore .travis.yml

EXPOSE 3000
CMD ["bin/geoip"]
