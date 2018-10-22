#!/bin/bash

if [ -n "$(find "/var/spool/postfix/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
	echo "populating /var/spool/postfix directory"
	cp -rp /var/spool/postfix.init/* /var/spool/postfix/
	chown postfix:root /var/spool/postfix
fi

if [ -n "$(find "/var/spool/cyrus/mail/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
	echo "populating /var/spool/cyrus/mail directory"
	cp -rp /var/spool/cyrus/mail.init/* /var/spool/cyrus/mail/
	chown cyrus:mail /var/spool/cyrus/mail
fi

if [ -n "$(find "/var/lib/cyrus/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
	echo "populating /var/lib/cyrus directory"
	cp -rp /var/lib/cyrus.init/* /var/lib/cyrus/
	chown cyrus:mail /var/lib/cyrus
fi

if [ ! -f "/var/lib/cyrus/tls_sessions.db" ]; then
	touch /var/lib/cyrus/tls_sessions.db
	chown cyrus:mail /var/lib/cyrus/tls_sessions.db
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
	CYRUSPASS=cyrpasswd
	while IFS=" " read -r user pass; do
		echo "create user $user"
		echo "$pass" | saslpasswd2 -p -u ${MAILNAME} -c $user
		if [ $user = "cyrus" ]; then
			echo "set login password for $user"
			echo "${user}:$pass" | chpasswd
			CYRUSPASS=$pass
		fi
		if [ $user != "cyrus" -a ! -d "/var/spool/cyrus/mail/${user:0:1}/user/${user}" ]; then
			echo "create mailbox for $user"
			echo "cm user.${user}" | cyradm --user cyrus -w ${CYRUSPASS} --server mailserver > /dev/null
		fi
	done < "/root/cyrususers"
fi

exec "$@"
