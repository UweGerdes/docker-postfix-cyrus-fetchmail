#!/bin/bash

if [ -n "$(find "/var/spool/postfix/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
	echo "populating postfix directory"
	cp -rp /var/spool/postfix.init /var/spool/postfix
fi

if [ -n "$(find "/var/spool/cyrus/mail/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
	echo "populating postfix directory"
	cp -rp /var/spool/cyrus/mail.init /var/spool/cyrus/mail
fi

if [ -n "$(find "/var/lib/cyrus/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
	echo "populating postfix directory"
	cp -rp /var/lib/cyrus.init /var/lib/cyrus
fi

postfix set-permissions >/dev/null 2>&1

rm -f /run/rsyslogd.pid
service rsyslog start
service cron start
service ssh start
service saslauthd start
service postfix start
service cyrus-imapd restart

if [ -z "$(sasldblistusers2)" ]; then
	while IFS=" " read -r user pass; do
		echo "create user $user"
		echo "$pass" | saslpasswd2 -p -u ${MAILNAME} -c $user
		if [ $user = "cyrus" ]; then
			echo "set login password for $user"
			echo "${user}:$pass" | chpasswd
		fi
		if [ $user != "cyrus" -a ! -d "/var/spool/cyrus/mail/${user:0:1}/user/${user}" ]; then
			echo "create mailbox for $user"
			echo "cm user.${user}" | cyradm --user cyrus -w cyrpasswd --server mailserver > /dev/null
		fi
	done < "/root/cyrususers"
fi

exec "$@"
