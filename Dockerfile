FROM alpine
MAINTAINER izikaj@gamil.com

RUN apk update && apk upgrade --available

RUN echo http://public.portalier.com/alpine/testing >> /etc/apk/repositories
RUN wget http://public.portalier.com/alpine/julien%40portalier.com-56dab02e.rsa.pub -O /etc/apk/keys/julien@portalier.com-56dab02e.rsa.pub

RUN apk update && apk add crystal shards build-base openssl-dev gmp-dev
# libxml2-dev readline-dev gmp-dev yaml-dev
# alpine-sdk
RUN mkdir -p /app
WORKDIR /app

COPY . ./
# ENTRYPOINT ["crystal", "run", "src/geoip.cr"]
EXPOSE 3000
CMD ["crystal", "run", "src/geoip.cr"]
