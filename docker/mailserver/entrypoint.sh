#!/bin/bash

if [ -n "$(find "/var/spool/postfix/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
	echo "populating postfix directory"
	cp -rp /var/spool/postfix.init/* /var/spool/postfix
fi

postfix set-permissions >/dev/null 2>&1

rm -f /run/rsyslogd.pid
service rsyslog start
service saslauthd start
service postfix start
service cyrus-imapd restart

if [ -z "$(sasldblistusers2)" ]; then
	while IFS=":" read -r user pass; do
		echo "saslpasswd2 create $user"
		echo "$pass" | saslpasswd2 -p -u ${MAILNAME} -c $user
		if [ $user != "cyrus" ]; then
			echo "cm user.$user" | cyradm --user cyrus -w cyrpasswd --server mailserver > /dev/null
		fi
	done < "/root/cyrususers"
	sasldblistusers2
fi

exec "$@"
