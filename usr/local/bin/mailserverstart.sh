#!/bin/bash

echo "NOT starting replication mailserver"

if [ "`whoami`" != "root" ] ; then
	echo "script has to be started as user root"
	exit 1
fi

echo "starting mailserver"
service cyrus-imapd restart
service postfix start
rm /tmp/fetchstart.lock
