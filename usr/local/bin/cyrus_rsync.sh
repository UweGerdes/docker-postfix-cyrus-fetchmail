#!/bin/bash

TARGETHOST="$1"

if [ -z "${TARGETHOST}" ] ; then
	echo "missing argument: targethost"
	exit 1
fi

if [ "`whoami`" != "cyrus" ] ; then
	echo "script has to be started as user cyrus"
	exit 1
fi

echo "TODO stopping remote mailserver"

echo "TODO stopping local mailserver"

echo 'TODO /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogz "/var/lib/cyrus/" "raspihome:/srv/docker/cyrus/lib"'

# for all users in replication list
echo 'TODO /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogz "/var/spool/cyrus/mail/u/user/uweimap/" "raspihome:/var/spool/cyrus/mail/u/user/uweimap"
"'
