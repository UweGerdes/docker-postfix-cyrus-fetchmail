#!/bin/bash

if [ "`whoami`" != "root" ] ; then
	echo "$0 has to be started as user root"
	exit 1
fi

echo "stop" > /tmp/fetchstart.lock
sleep 1
FETCHPID=`/usr/bin/pgrep fetchmail`
while [ -n "${FETCHPID}" ] ; do
	sleep 5
	read -p "$(date -u +'%b %d %H:%M:%S') $0 fetchmail is running - [RETURN]" | tee -a /var/log/mailserverstop.log
	FETCHPID=`/usr/bin/pgrep fetchmail`
done
sleep 2
FETCHPID=`/usr/bin/pgrep fetchmail`
if [ -z "${FETCHPID}" ] ; then
	MAILSERVERRUN=`/bin/ps ax | egrep 'postfix/sbin/.?master|cyr.?master'`
	if [ -n "${MAILSERVERRUN}" ] ; then
		echo "$(date -u +'%b %d %H:%M:%S') $0 stopping replication mailserver" | tee -a /var/log/mail.log
		/usr/sbin/postfix stop
		sleep 2
		service cyrus-imapd stop
		sleep 2
	else
		echo "kein Stop des Mail-Systems"
	fi
fi
