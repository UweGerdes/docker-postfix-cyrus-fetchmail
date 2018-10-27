#!/bin/bash

if [ "`whoami`" != "root" ] ; then
	echo "$0 has to be started as user root"
	exit 1
fi

echo "$(date -u +'%b %d %H:%M:%S') $0 starting mailserver" | tee -a /var/log/mail.log
service cyrus-imapd restart
service postfix start
rm /tmp/fetchstart.lock
