#!/bin/bash

if [ -n "$(find "/var/spool/postfix/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
	echo "populating postfix directory"
	cp -rp /var/spool/postfix.init/* /var/spool/postfix
fi

if [ -z "$(sasldblistusers2)" ]; then
	while IFS=":" read -r user pass; do
		echo "saslpasswd2 create $user"
		echo "$pass" | saslpasswd2 -p -u ${MAILNAME} -c $user
	done < "/root/cyrususers"
	sasldblistusers2
fi

postfix set-permissions >/dev/null 2>&1

rm -f /run/rsyslogd.pid
service rsyslog start
service saslauthd start
service postfix start
service cyrus-imapd restart

exec "$@"
