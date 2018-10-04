#!/bin/bash

if [ -n "$(find "/var/spool/postfix/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
    echo "populating postfix directory"
    cp -rp /var/spool/postfix.init/* /var/spool/postfix
fi

echo "postfix set-permissions"
postfix set-permissions >/dev/null 2>&1

exec "$@"
