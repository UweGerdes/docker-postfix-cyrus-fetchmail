# Docker uwegerdes/mailserver

## Edit files

Copy the `*.sample` files to files without the `.sample` extension and edit them to your needs. You should `chmod 600` the copies because they contain passwords.

Check other files and perhaps add some settings. You might want to `git update-index --assume-unchanged etc/aliases` to keep changes out of git.

## Build

Build the image with (mind the dot):

```bash
$ docker build \
	-t uwegerdes/mailserver \
	--build-arg SMTPSERVER=smtp.server.com \
	--build-arg SENDERCANONICAL=mailserver@myserver.com \
	.
```

## Usage

Check for other MTA on your server - they should not use the ports listed below: `sudo netstat -tulpen`. Perhaps you should `sudo dpkg-reconfigure exim4-config` to listen on local address 127.0.0.2 (which will not interfere with localhost).

Run the mailserver container with:

```bash
$ docker run -it \
	--name mailserver \
	--hostname mailserver \
	-p 61022:22 \
	-p 61025:25 \
	-p 61110:110 \
	-p 61143:143 \
	-p 61465:465 \
	-p 61587:587 \
	-p 61993:993 \
	--volume /srv/docker/mailserver/postfix:/var/spool/postfix \
	--volume /srv/docker/mailserver/cyrus/mail:/var/spool/cyrus/mail \
	--volume /srv/docker/mailserver/cyrus/lib:/var/lib/cyrus \
	--volume /srv/docker/mailserver/log:/var/log \
	uwegerdes/mailserver \
	bash
```

## Configuration

This installation delivers mail to the users listed in etc/aliases. You can also put .foward files in home directories. To use other distribution methods (LDAP, MySQL...) make your own docker and tell me. ;-)

To use TLS with keys that survive recreation of the image copy ssl-cert-snakeoil.pem and ssl-cert-snakeoil.key from a container and put them in subdirectories in `etc/ssl` - and restrict access.


## Cyrus mail backup and restore

The prompt of the docker container is the same on the master and replication - please make shure you enter the commands in the desired docker container!

Give user cyrus a password and try to connect from another computer in your network:

```bash
root@mailserver:/# ssh -p 61022 cyrus@mailhost2
```

Accept fingerprint and log out again.

You may want to use key based login to avoid password input - please accept fingerprint and logout, then generate key file and copy to remote docker container:

```bash
root@mailserver:/# sudo -s -H -u cyrus
cyrus@mailserver:/$ ssh -p 61022 cyrus@mailhost2
cyrus@mailserver:~$ ^D
cyrus@mailserver:/$ ssh-keygen -t rsa -C cyrus@mailserver -N '' -f ~/.ssh/id_rsa
cyrus@mailserver:/$ ssh-copy-id -i ~/.ssh/id_rsa.pub -p 61022 cyrus@mailhost2
```

I had to start the container on one computer with `--dns 192.168.1.1` - it didn't find the other system without DNS server. Reason: `/etc/resolv.conf` on host.

Commands for replication - TODO please stop other server first

```bash
$ /usr/bin/rsync -e "ssh -p 61022 cyrus@raspihome" --delete -rtpvogz "/var/lib/cyrus/" "cyrus@raspihome:/srv/docker/cyrus/lib"
$ /usr/bin/rsync -e "ssh -p 61022 cyrus@raspihome" --delete -rtpvogz "/var/spool/cyrus/mail/u/" "cyrus@raspihome:/srv/docker/cyrus/mail/u"
```

Accept the key. You may want to rsync the contents of spool/cyrus/mail and lib/cyrus.

## Logs

Postfix and Cyrus log to `/var/log/mail.log` and `/var/log/mail.err`.
