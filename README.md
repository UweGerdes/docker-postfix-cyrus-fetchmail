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

Check for other MTA on your server - they should not use the ports listed below: `sudo netstat -tulpen`. Perhaps you should `sudo dpkg-reconfigure exim4-config` to listen on local address 127.0.0.2 (which will not interfere with localhost).

Run the mailserver container with:

```bash
$ docker run -it \
	--name mailserver \
	--hostname mailserver \
	-p 50022:22 \
	-p 50025:25 \
	-p 110:110 \
	-p 143:143 \
	-p 465:465 \
	-p 587:587 \
	-p 993:993 \
	--volume /srv/docker/postfix:/var/spool/postfix \
	uwegerdes/mailserver \
	bash
```

## Configuration

This installation delivers mail to the users listed in etc/aliases. You can also put .foward files in home directories. To use other distribution methods (LDAP, MySQL...) make your own docker and tell me. ;-)

To use TLS with keys that survive recreation of the image please create the ssl-cert in the running container (hostname is set) and copy ssl-cert-snakeoil.pem and ssl-cert-snakeoil.key from a container to the host and put them in subdirectories in `etc/ssl` - and restrict access. Please keep in mind that the keys depend on the container hostname.


## Cyrus mail backup and restore

Give user cyrus a password and try to connect from another computer in your network:

```bash
$ ssh -p 50022 cyrus@mailserver
```

Accept the key. You may want to rsync the contents of mail.

## Logs

Postfix and Cyrus log to `/var/log/mail.log` and `/var/log/mail.err`.
