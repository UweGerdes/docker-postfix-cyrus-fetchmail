#!/bin/bash
#
DATE=`date +"%b %d %H:%M:%S"`
HOSTNAME=`hostname`
MYNAME=`whoami`
LOGFILE="/var/log/fetchmail.log"

echo -n "${DATE} ${HOSTNAME} fetchstart" >> ${LOGFILE}

if [ -f "/tmp/fetchstart.lock" ]; then
	echo " - mailserver locked - quit." >> ${LOGFILE}
	exit 0
fi

if [ -z "`/usr/bin/pgrep cyrmaster`" ]; then
	echo " - cyrus-imapd not running - quit." >> ${LOGFILE}
else
	if [ -z "`/usr/bin/pgrep fetchmail`" ] ; then
		echo ", fetchmail starting." >> ${LOGFILE}
		echo "${DATE} ${HOSTNAME} ${MYNAME} starting" >> /var/log/fetchmail.log
		/usr/bin/fetchmail -f /var/lib/fetchmail/fetchmailrc --timeout 30 >> /var/log/fetchmail.log 2>&1
	else
		echo ", fetchmail running, PID is `/usr/bin/pgrep fetchmail` - quit." >> ${LOGFILE}
	fi
fi
