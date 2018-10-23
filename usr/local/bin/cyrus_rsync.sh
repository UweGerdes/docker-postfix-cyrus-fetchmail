#!/bin/bash

TARGETHOST="$1"

if [ -z "${TARGETHOST}" ] ; then
	echo "missing argument: targethost"
	exit 1
fi

if [ "`whoami`" != "root" ] ; then
	echo "script has to be started as user root"
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
	echo "mailserverstop auf ${TARGETHOST} aufrufen..."
	sudo -u cyrus ssh -p 61022 cyrus@${TARGETHOST} sudo /usr/local/bin/mailserverstop.sh
	#sleep 10
	MAILSERVERRUN=`/bin/ps ax | egrep 'postfix/sbin/.?master|cyr.?master'`
	if [ -n "${MAILSERVERRUN}" ] ; then
		echo "stopping mailserver - please wait"
		/usr/sbin/postfix stop
		sleep 2
		service cyrus-imapd stop
		sleep 2
	else
		echo "kein Stop des Mail-Systems"
	fi
	echo sudo -u cyrus /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogz "/var/lib/cyrus/" "${TARGETHOST}:/var/lib/cyrus"
	# for all users in replication list
	if [ -f "/root/rsyncusers" ] ; then
		echo "rsync mailboxes"
		while IFS=" " read -r user ; do
			if [ -d "/var/spool/cyrus/mail/${user:0:1}/user/${user}" ]; then
				echo "rsync mailbox for $user"
				echo sudo -u cyrus /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogz "/var/spool/cyrus/mail/${user:0:1}/user/${user}/" "${TARGETHOST}:/var/spool/cyrus/mail/${user:0:1}/user/${user}"
			fi
		done < "/root/rsyncusers"
	fi

	echo "starting mailserver"
	service cyrus-imapd restart
	service postfix restart
	echo "mailserverstart auf ${TARGETHOST} aufrufen..."
	sudo -u cyrus ssh -p 61022 cyrus@${TARGETHOST} sudo /usr/local/bin/mailserverstart.sh
else
	echo "mailserver not stopped, fetchmail running with PID ${FETCHPID}"
	read -p "this should never happen - please check... [RETURN]"
	echo "starting mailserver"
fi

rm /tmp/fetchstart.lock

exit 0
