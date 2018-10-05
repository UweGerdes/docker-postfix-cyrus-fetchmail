# Docker uwegerdes/mailserver

## Edit files

Copy the `*.sample` files to files without the `.sample` extension and edit them to your needs. You should `chmod 600` the copies because they contain passwords.

Check other files and perhaps add some settings.

## Build

Build the image with (mind the dot):

```bash
$ docker build \
	-t uwegerdes/mailserver \
	--build-arg SMTPSERVER=smtp.server.com \
	--build-arg SENDERCANONICAL=user@server.com \
	.
```

## Usage

Run the mailserver container with:

```bash
$ docker run -it \
	--name mailserver \
	--hostname mailserver \
	-p 25:25 \
	--volume /srv/docker/postfix:/var/spool/postfix \
	uwegerdes/mailserver \
	bash
```

## Configuration

This installation delivers mail to the users listed in etc/aliases. You can also put .foward files in home directories. To use other distribution methods (LDAP, MySQL...) make your own docker and tell me. ;-)

## Logs

Postfix and Cyrus log to `/var/log/mail.log` and `/var/log/mail.err`.
