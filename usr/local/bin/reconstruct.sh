#!/bin/bash
#
# reconstruct the cyrus mail folders after accessing from outside cyrus (deleted files, restored backup)
#

if [ "$(id -u)" != "0" ]; then
    echo "script has to be started with root permissions"
    exit
fi

echo "stop" > /tmp/fetchstart.lock

FETCHPID=`/usr/bin/pgrep fetchmail`
if [ -z "${FETCHPID}" ] ; then
	cd /var/spool/cyrus/mail/
	for uletter in * ; do
		if [ -e /var/spool/cyrus/mail/$uletter/user ] ; then
			cd /var/spool/cyrus/mail/$uletter/user/
			for user in * ; do
				echo -n "reconstruct: $user"
				su -c "/usr/lib/cyrus/bin/reconstruct -r -f user.$user" - cyrus >/dev/null
				  echo -n " done - "
				  date
			done
		fi
	done
else
	echo "mailserver not stopped, fetchmail running with PID ${FETCHPID}"
fi

rm /tmp/fetchstart.lock

exit 0

