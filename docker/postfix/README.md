# Docker uwegerdes/postfix

## Build

Build the image with (mind the dot):

```bash
$ docker build \
	-t uwegerdes/postfix \
	--build-arg MAILDOMAIN=$(hostname) \
	--build-arg SMTPSERVER=smtp.server.com \
	--build-arg SMTPUSERNAME=user@server.com \
	--build-arg SMTPPASSWORD=mysecretpassword \
	.
```

## Usage

Run the postfix container with:

```bash
$ docker run -d \
	--hostname postfix \
	--name postfix \
	uwegerdes/postfix
```
