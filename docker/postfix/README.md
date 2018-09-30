# Docker uwegerdes/postfix

## Build

Build the image with (mind the dot):

```bash
$ docker build \
	-t uwegerdes/postfix \
	--build-arg MAILNAME=$(hostname) \
	--build-arg SMTPSERVER=smtp.server.com \
	--build-arg SMTPUSERNAME=user@server.com \
	--build-arg SMTPPASSWORD=mysecretpassword \
	--build-arg SENDERCANONICAL=user@server.com \
	.
```

## Usage

Run the postfix container with:

```bash
$ docker run -it \
	--name postfix \
	-p 25:25 \
	--volumes-from maildata \
	uwegerdes/postfix \
	bash
```
