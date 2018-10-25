# Docker uwegerdes/mailserver

Mail server setup is a bit tricky - if you want to use one at home this repo is a possible starting point.

## Edit files

Copy the `*.sample` files to files without the `.sample` extension and edit them to your needs. You should `chmod 600` the copies because they contain passwords.

Check other files and perhaps add some settings. You might want to `git update-index --assume-unchanged etc/aliases` to keep changes out of git.

## Build

Build the image with (mind the dot):

```bash
$ docker build -t uwegerdes/mailserver .
```

## Usage

The ports are mapped to unused ports because at least 22 and 25 are in use on a usual Ubuntu installation. Please set the mail client ports to those exported ports.

Run the mailserver container with:

```bash
$ docker run -d \
	--restart always \
	--name mailserver \
	--hostname mailserver \
	-p 61022:22 \
	-p 61025:25 \
	-p 61110:110 \
	-p 61143:143 \
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

This installation delivers mail to the users listed in etc/aliases. You can also put .foward files in home directories. To use other distribution methods (LDAP, MySQL...) make your own docker and tell me. ;-)

To use TLS with keys that survive recreation of the image copy ssl-cert-snakeoil.pem and ssl-cert-snakeoil.key from a container and put them in subdirectories in `etc/ssl` - and restrict access.


## Cyrus mail backup and restore

The prompt of the docker container is the same on the master and replication - please make shure you enter the commands in the desired docker container!

You may want to use key based login to avoid password input. The generated key file is copied to remote docker container - please accept fingerprint and enter password on remote mailhost2 (the network name of the computer running the docker mailserver container):

```bash
$ docker exec -it mailserver sudo -H -u cyrus sh -c "ssh-keygen -t rsa -C cyrus@mailserver -N '' -f ~/.ssh/id_rsa && ssh-copy-id -i ~/.ssh/id_rsa.pub -p 61022 cyrus@mailhost2"
```

Command for replication:

```bash
$ docker exec -it mailserver cyrus_rsync.sh mailhost2
```

If you set up a copy mailbox for each user you can use fetchmail on the replication mailserver to load the newest mails and have a nearly syncronous replicatation (mails are not copied to subfolders if the mailclient does so - but at least the mails are saved if the main mailserver deletes all the data). They will be overwritten on the next `cyrus_rsync.sh` - this is intended.

You should think about setting different times for the fetchmail cronjob in `Dockerfile` for the replication mailserver.

## SSL

If you have a mailserver container it has it's own ssl-sert-snakeoil certificates - you may want to copy the files to a mounted volume and add them to the respective locations in this projects directory `etc/ssl/`. They are reused on the next `docker build` and your mail clients should only comply on the first connection to the mailserver with that certificate.

## Logs

You find the logs in the mounted volume `/srv/docker/mailserver/log` (see `docker run` command.
