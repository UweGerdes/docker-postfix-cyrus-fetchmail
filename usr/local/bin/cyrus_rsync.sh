#!/bin/bash

TARGETHOST="$1"

if [ -z "${TARGETHOST}" ] ; then
	echo "${0} missing argument: targethost"
	exit 1
fi

if [ "`whoami`" != "root" ] ; then
	echo "${0} has to be started as user root"
	exit 1
fi

if [ ! -f "/root/rsyncusers.${TARGETHOST}" ] ; then
	echo "${0} missing file: /root/rsyncusers.${TARGETHOST} - are you on a replicated system?"
	exit 1
fi

echo "Try connection to ${TARGETHOST}"
sudo -u cyrus ssh -p 61022 cyrus@${TARGETHOST} echo "connection established"

/usr/local/bin/mailserverstop.sh

FETCHPID=`/usr/bin/pgrep fetchmail`
if [ -z "${FETCHPID}" ] ; then
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

	# cyrus lib files
	sudo -u cyrus /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogzi --size-only "/var/lib/cyrus/" "${TARGETHOST}:/var/lib/cyrus"

	# for all users in replication list
	while IFS=" " read -r user ; do
		if [ -d "/var/spool/cyrus/mail/${user:0:1}/user/${user}" ]; then
			echo ""
			echo "rsync mailbox for $user"
			sudo -u cyrus /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogzi "/var/spool/cyrus/mail/${user:0:1}/user/${user}/" "${TARGETHOST}:/var/spool/cyrus/mail/${user:0:1}/user/${user}"
		fi
	done < "/root/rsyncusers.${TARGETHOST}"

	/usr/local/bin/mailserverstart.sh
	sudo -u cyrus ssh -p 61022 cyrus@${TARGETHOST} sudo /usr/local/bin/mailserverstart.sh
else
	echo "mailserver not stopped, fetchmail running with PID ${FETCHPID}"
	read -p "this should never happen - please check... [RETURN]"
	echo "starting mailserver"
fi

rm /tmp/fetchstart.lock

exit 0
