#!/bin/bash

# initial blocking of fetchmail
echo "stop" > /tmp/fetchstart.lock

if [ -n "$(find "/var/spool/postfix/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
	echo "populating /var/spool/postfix directory"
	cp -rp /var/spool/postfix.init/* /var/spool/postfix/
fi

if [ -n "$(find "/var/spool/cyrus/mail/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
	echo "populating /var/spool/cyrus/mail directory"
	cp -rp /var/spool/cyrus/mail.init/* /var/spool/cyrus/mail/
fi

if [ -n "$(find "/var/lib/cyrus/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
	echo "populating /var/lib/cyrus directory"
	cp -rp /var/lib/cyrus.init/* /var/lib/cyrus/
fi

if [ ! -f "/var/lib/cyrus/tls_sessions.db" ]; then
	touch /var/lib/cyrus/tls_sessions.db
fi

chown -R postfix:mail /var/spool/postfix
chown -R cyrus:mail /var/spool/cyrus/mail /var/spool/sieve /var/lib/cyrus

if [ ! -f "/var/log/syslog" ]; then
	chmod 777 /var/log
	touch /var/log/syslog
	chown syslog:adm /var/log/syslog
	touch /var/log/fetchmail.log
	chmod 666 /var/log/fetchmail.log
fi

if [ ! -d "/var/log/clamav" ]; then
	mkdir /var/log/clamav
	chown clamav:clamav /var/log/clamav
fi

postfix set-permissions >/dev/null 2>&1

rm -f /run/rsyslogd.pid
service rsyslog start
service cron start
service ssh start
service saslauthd start
service cyrus-imapd start
service postfix start
service clamav-daemon start
freshclam
service amavis start

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

# remove initial blocking of fetchmail
rm /tmp/fetchstart.lock

exec "$@"
