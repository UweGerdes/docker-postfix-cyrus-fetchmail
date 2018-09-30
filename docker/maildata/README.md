# Docker maildata

This container shares some directories to other mail containers and keeps the data - or uses mounted volumes for the data to keep them across rebuilds.

## Build

Build the image with (mind the dot):

```bash
$ docker build -t uwegerdes/maildata .
```

## Usage

Make sure you have a htdocs directory in your current folder (`$(pwd)/htdocs`) or supply the absolute (not relative!) path to your desired web root:

```bash
$ docker run \
	--name maildata \
	--volume /srv/docker/postfix:/var/spool/postfix \
	uwegerdes/maildata
```

The command will create a container and exit. That is ok because only the volumes from the container will be used.

