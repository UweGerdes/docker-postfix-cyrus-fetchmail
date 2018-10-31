# Docker uwegerdes/mailserver

Mail server setup is a bit tricky - if you want to use one at home this repo is a possible starting point.

## Edit files

Copy the `*.sample` files to files without the `.sample` extension and edit them to your needs. You should `chmod 600` the copies because they contain passwords.

Check other files and perhaps add some settings. You might want to `git update-index --assume-unchanged etc/aliases` to keep changes out of git.

See below for details of the configuration.

## Build

Build the image with (mind the dot):

```bash
$ docker build -t uwegerdes/mailserver --build-arg CRONTAB_MIN="4-59/5" .
```

`CRONTAB_MIN` is the minutes entry for `/etc/crontab` when fetchmail will be started.

## Usage

The ports are mapped to unused ports because at least 22 and 25 are in use on a usual Ubuntu installation. Please set the mail client ports to those exported ports.

Run the mailserver container with:

```bash
$ docker run -d \
	--restart always \
	--name mailserver \
	--hostname mailserver.localdomain \
	-p 61022:22 \
	-p 61025:25 \
	-p 61110:110 \
	-p 61143:143 \
	-p 61465:465 \
	-p 61587:587 \
	-p 61993:993 \
	-p 61190:4190 \
	--volume /srv/docker/mailserver/postfix:/var/spool/postfix \
	--volume /srv/docker/mailserver/cyrus/mail:/var/spool/cyrus/mail \
	--volume /srv/docker/mailserver/cyrus/lib:/var/lib/cyrus \
	--volume /srv/docker/mailserver/log:/var/log \
	--dns 192.168.178.1 \
	uwegerdes/mailserver
```

I had to start the container on one computer with `--dns 192.168.178.1` - it didn't find the other system without DNS server. Reason: `/etc/resolv.conf` on host.

To execute commands in the docker container enter:

```bash
$ docker exec -it mailserver bash
```

If you stopped the container restart it with:

```bash
$ docker start mailserver
```

## Configuration

### `var/lib/fetchmail/fetchmailrc`

This is the receiving part of the mailserver - change the server name, username and password to match your mail provider. Multiple user entries and other severs can be included.

The mail is handed over to `mailbox` at `etc/aliases`.

You should make sure to set `chmod 600 var/lib/fetchmail/fetchmailrc` to have a bit of protection for the password.

### `etc/aliases`

This installation delivers mail to the users listed in `etc/aliases`. You can also put `.foward` files in home directories. To use other distribution methods (LDAP, MySQL...) make your own docker and tell me. ;-)

The file `etc/aliases` contains some redirections to user `root`, then to `mailbox` (where also the fetchmail points to) and get delivered to `user2` and `mailbackup`. Those mailboxes are configured by `root/cyrususers`.

### `root/cyrususers`

This file contains users and passwords for the cyrus environment. A user `cyrus` is needed for configuration (it gets no mailbox), `mailbox` receives mails (it is not really in use). Other users get mailboxes and a password (stored with `saslpasswd2`) so they can access their mailbox with IMAP and POP3.

Apply `chmod 600 root/cyrususers` to that file.

### `etc/postfix/sender_canonical`

For outgoing mail the user root get the mail addess you specify here. You mail client supports sending with defined addresses but internal mails (from `cron` or `amavis`) should use a valid sender address.

### `etc/postfix/sasl_password`

To allow sending to your mail provider you need the credentials in this file.

Apply `chmod 600 root/cyrususers` to that file.

### `etc/amavis/whitelist`

If you receive mail from users or servers that should not be spam checked please add the mail address or domain name (without @) to this file.

If you don't want to whitelist please add an empty file to avoid error messages.

### TLS

To use TLS with keys that survive recreation of the image copy ssl-cert-snakeoil.pem and ssl-cert-snakeoil.key (both are text files) from a container and put them in subdirectories in `etc/ssl` - and restrict access.

This doesn't apply if you use SSL (with Let's Encrypt or others) with your own domain name (see below).

## Commands

### Cyrus mail replication

You should install a second mailserver in your local network on another computer. The mailboxes can be copied from your mailserver (master) to mailserver2 (replication). Please make shure you execute the commands in the desired docker container - `mailhost` and `mailhost2` are the names of the computer (in your local network) running the docker containers.

In my network the master mailserver runs on a Raspberry Pi 3, the replication mailserver runs on my laptop.

On the first run key based login (for user `cyrus`) is activated from master to replication. You must accept the fingerprint, are asked to login (which should last more than 5 seconds, use `cyrus` password of mailserver2) and the hit RETURN to generate a key and then login again to copy the key. From now on the user `cyrus` should not be asked to enter a password when connecting from master to replication. It is not recommended to have key based login from replication to master - you will not want to overwrite the master with the replication (except in case of corrupted master mailboxes).

Command for replication (issued on master `mailhost`):

```bash
$ docker exec -it mailserver cyrus_rsync.sh mailhost2
```

If you set up a copy mailbox for each user (see above: `etc/aliases`, add `, usercopy`) you can use fetchmail on the replication mailserver to load the newest mails from the master and have a nearly syncronous replicatation (mails are not copied to subfolders if the mailclient does so on the master - but at least the mails are saved if the master mailserver crashes the mailboxes). They mailboxes will be overwritten on the next `cyrus_rsync.sh` - this is intended.

You should think about setting different times for the fetchmail cronjob in `Dockerfile` for the replication mailserver (see `CRONTAB_MIN` above).

## SSL

If you have a mailserver container it has it's own ssl-sert-snakeoil certificates - you may want to copy the files to a mounted volume and add them to the respective locations in this projects directory `etc/ssl/`. They are reused on the next `docker build` and your mail clients should only comply on the first connection to the mailserver with that certificate.

### Let's Encrypt

I've set up Let's Encrypt `certbot` on the host running the mailserver so I can include the files in the `docker run` command:

```bash
	--volume /etc/letsencrypt:/etc/letsencrypt \
```

Or build your image with a `/root/authenticator.sh` to be used as `certbot --manual-auth-hook` script - I'm using it with a desec.io dynamic dns and they provide a hook.sh script. Then create a `/root/.certbot` with a line `CERTBOT_DOMAIN=your.domain.com` and build a new image.

Perhaps some changes are needed in `/root/setup-letsencrypt.sh`.

Now install `certbot` and your Let's Encrypt certificate with `setup-letsencrypt.sh`. Setup for `cyrus` is included.

TODO: Some modifications and symbolic links for `postfix` is required.
For `certbot` a post-deploy-hook should send a mail.

## Logs

You find the logs in the mounted volume `/srv/docker/mailserver/log` (see `docker run` command).
