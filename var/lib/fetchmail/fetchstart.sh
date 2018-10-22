#!/bin/bash
#
DATE=`date +"%b %d %H:%M:%S"`
HOSTNAME=`hostname`
LOGFILE="/var/log/fetchmail.log"

echo -n "${DATE} ${HOSTNAME}" >> ${LOGFILE}

if [ -f "/tmp/fetchstart.lock" ]; then
	echo " - server locked - quit." >> ${LOGFILE}
	exit 0
fi

if [ -z "`/usr/bin/pgrep cyrmaster`" ]; then
	echo " - cyrus-imapd not running - quit." >> ${LOGFILE}
	exit 0
fi

if [ -z "`/usr/bin/pgrep fetchmail`" ] ; then
	echo ", fetchmail starting." >> ${LOGFILE}
	/usr/bin/fetchmail -f /var/lib/fetchmail/fetchmailrc --timeout 30 >> ${LOGFILE} 2>&1
else
	echo ", fetchmail running, PID is `/usr/bin/pgrep fetchmail` - quit." >> ${LOGFILE}
fi
