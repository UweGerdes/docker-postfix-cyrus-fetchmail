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
	echo "TODO mailserverstop auf ${TARGETHOST} aufrufen..."
	sudo -u cyrus ssh -p 61022 cyrus@raspihome sudo /usr/local/bin/mailserverstop.sh
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
echo 'TODO sudo -u cyrus /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogz "/var/lib/cyrus/" "raspihome:/srv/docker/cyrus/lib"'
#		/usr/bin/rsync --delete -rtpvogz "/mnt/Daten/cyrus/lib/" "cyrus@${TARGETHOST}:/mnt/Daten/cyrus/lib"

# for all users in replication list
echo 'TODO sudo -u cyrus /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogz "/var/spool/cyrus/mail/u/user/uweimap/" "raspihome:/var/spool/cyrus/mail/u/user/uweimap"'

#sudo -s -H -u cyrus echo 'init key login' && ssh-keygen -t rsa -C cyrus@mailserver -N '' -f ~/.ssh/id_rsa && ssh-copy-id -i ~/.ssh/id_rsa.pub -p 61022 cyrus@mailhost2
		sudo -u cyrus /usr/bin/rsync -e "ssh -p 61022 -l cyrus" --delete -rtpvogz "/var/spool/cyrus/mail/t/user/test/" "raspihome:/var/spool/cyrus/mail/t/user/test"

	echo "starting mailserver"
	service cyrus-imapd restart
	service postfix restart
else
	echo "mailserver not stopped, fetchmail running with PID ${FETCHPID}"
	read -p "this should never happen - please check... [RETURN]"
	echo "starting mailserver"
fi

rm /tmp/fetchstart.lock

exit 0
