# Docker uwegerdes/postfix

## Build

Build the image with (mind the dot):

```bash
$ docker build \
	-t uwegerdes/postfix \
	--build-arg MAILNAME=$(hostname) \
	--build-arg SMTPSERVER=smtp.server.com \
	--build-arg SENDERCANONICAL=user@server.com \
	.
```

## Usage

Run the postfix container with:

```bash
$ docker run -it \
	--name postfix \
	-p 25:25 \
	--volume /srv/docker/postfix:/var/spool/postfix \
	uwegerdes/postfix \
	bash
```

## Configuration

This installation delivers mail to the users listed in etc/aliases. You can also put .foward files in home directories. To use other distribution methods (LDAP, MySQL...) make your own docker and tell me. ;-)
