# Raspberry Pi Home Server with Dockers

Setup a Raspberry Pi 3 as home server with some apps for me

## Setup Hardware

Install Raspbian, make updates, configure for ssh, cam, etc., rpi-update (firmware)...

sudo apt-get install xrdp

## Install Docker

Start with uwegerdes/docker-baseimage-arm32v7 - installation of Docker is documented there.

## Build and install docker-compose

https://www.berthon.eu/2017/getting-docker-compose-on-raspberry-pi-arm-the-easy-way/

```bash
$ git clone https://github.com/docker/compose.git
$ cd compose/
$ git checkout release
$ docker build -t docker-compose:armhf -f Dockerfile.armhf .
$ docker run --rm --entrypoint="script/build/linux-entrypoint" -v $(pwd)/dist:/code/dist -v $(pwd)/.git:/code/.git "docker-compose:armhf"
```

You get a file `dist/docker-compose-Linux-armv7l` - copy it to /usr/local/bin/docker-compose and try `docker-compose --version`.

## Docker mail server

### Postfix

More info in `docker/postfix/README.md`.

## Docker nodejs

Build `uwegerdes/docker-nodejs`.

## Docker frontend-development

See my git `uwegerdes/frontend-development`.
