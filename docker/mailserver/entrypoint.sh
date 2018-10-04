#!/bin/bash

if [ -n "$(find "/var/spool/postfix/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
    echo "populating postfix directory"
    cp -rp /var/spool/postfix.init/* /var/spool/postfix
fi

postfix set-permissions >/dev/null 2>&1

service rsyslog start
service saslauthd restart
service postfix start
service cyrus-imapd restart

exec "$@"
