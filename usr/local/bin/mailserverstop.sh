#!/bin/bash

echo "stopping replication mailserver"

if [ "`whoami`" != "root" ] ; then
	echo "script has to be started as user root"
	exit 1
fi

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
fi
