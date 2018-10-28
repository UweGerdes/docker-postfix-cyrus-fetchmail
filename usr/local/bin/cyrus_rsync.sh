#!/bin/bash

if [ "`whoami`" != "root" ] ; then
	echo "${0} has to be started as user root"
	exit 1
fi

TARGETHOST="$1"

if [ -z "${TARGETHOST}" ] ; then
	echo "${0} missing argument: targethost"
	exit 2
fi

if [ ! -f "/root/rsyncusers.${TARGETHOST}" ] ; then
	echo "${0} missing file: /root/rsyncusers.${TARGETHOST} - are you on a replicated system?"
	exit 3
fi

/usr/local/bin/check_targethost.sh ${TARGETHOST}
if [ $? > 0 ] ; then
	echo "${0} connection to ${TARGETHOST} not established"
	exit 4
fi

/usr/local/bin/mailserverstop.sh

FETCHPID=`/usr/bin/pgrep fetchmail`
if [ -z "${FETCHPID}" ] ; then
	sudo -u cyrus ssh -p 61022 cyrus@${TARGETHOST} sudo /usr/local/bin/mailserverstop.sh

	# cyrus lib files
	sudo -u cyrus /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogzi --size-only "/var/lib/cyrus/" "${TARGETHOST}:/var/lib/cyrus"

	# cyrus mail files
	sudo -u cyrus /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogzi "/var/spool/cyrus/mail/" "${TARGETHOST}:/var/spool/cyrus/mail"
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
