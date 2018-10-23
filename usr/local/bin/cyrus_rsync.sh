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
echo "stop" > /tmp/fetchstart.lock
sleep 1
FETCHPID=`/usr/bin/pgrep fetchmail`
while [ -n "${FETCHPID}" ] ; do
	sleep 5
	read -p "fetchmail is running - [RETURN]"
	FETCHPID=`/usr/bin/pgrep fetchmail`
done
sleep 2
FETCHPID=`/usr/bin/pgrep fetchmail`
if [ -z "${FETCHPID}" ] ; then
	echo "TODO mailserverstop auf ${TARGETHOST} aufrufen..."
	sleep 10
	MAILSERVERRUN=`/bin/ps ax | egrep 'postfix/sbin/.?master|cyr.?master'`
	if [ -n "${MAILSERVERRUN}" ] ; then
		echo "stopping mailserver - please wait"
		service postfix stop
		sleep 2
		service cyrus-imapd stop
		sleep 2
	else
		echo "kein Stop des Mail-Systems"
	fi
echo 'TODO /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogz "/var/lib/cyrus/" "raspihome:/srv/docker/cyrus/lib"'
#		/usr/bin/rsync --delete -rtpvogz "/mnt/Daten/cyrus/lib/" "cyrus@${TARGETHOST}:/mnt/Daten/cyrus/lib"

# for all users in replication list
echo 'TODO /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogz "/var/spool/cyrus/mail/u/user/uweimap/" "raspihome:/var/spool/cyrus/mail/u/user/uweimap"
"'
#		/usr/bin/rsync --delete -rtpvogz "/mnt/Daten/cyrus/mail/" "cyrus@${TARGETHOST}:/mnt/Daten/cyrus/mail"

	echo "starting mailserver"
	service cyrus-imapd restart
	service postfix restart
else
	echo "mailserver not stopped, fetchmail running with PID ${FETCHPID}"
	read -p "this should never happen - please check... [RETURN]"
	echo "starting mailserver"
fi

rm /tmp/fetchstart.lock

exit 0
