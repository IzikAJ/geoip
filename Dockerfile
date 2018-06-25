FROM alpine
MAINTAINER izikaj@gmail.com

RUN apk update && apk upgrade --available \
 && echo http://public.portalier.com/alpine/testing >> /etc/apk/repositories \
 && wget http://public.portalier.com/alpine/julien%40portalier.com-56dab02e.rsa.pub -O /etc/apk/keys/julien@portalier.com-56dab02e.rsa.pub \
 && apk update && apk add --no-cache crystal openssl gmp yaml \
 && apk add --no-cache --virtual .build shards gcc g++ make openssl-dev gmp-dev yaml-dev \
 && mkdir -p /app

WORKDIR /app

COPY . ./

RUN shards update \
 && rm -rf bin/geoip \
 && mkdir -p bin \
 && crystal build src/geoip.cr -o bin/geoip --release --no-debug --stats --progress \
 && apk del .build \
 && rm -rf .shards lib dev spec shard* sentry* geoip* \
 && mkdir -p tmp \
 && wget --directory-prefix=tmp http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz \
 && tar -xvzpf tmp/GeoLite2-Country.tar.gz -C tmp \
 && cp -f $(find tmp -name "*.mmdb") vendor \
 && rm -rf tmp

EXPOSE 3000
CMD ["bin/geoip"]
