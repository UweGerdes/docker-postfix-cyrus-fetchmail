#!/usr/bin/env bash

CERTBOTFILE="/root/.certbot"

if [ ! -f "$CERTBOTFILE" ]; then
	echo "File $CERTBOTFILE not found. Please place .certbot file in appropriate location."
	exit 2
fi

source $CERTBOTFILE

if [ "$(ls -l /etc/letsencrypt/live/$CERTBOT_DOMAIN/cert.pem | awk '{print $4}')" != "ssl-cert" ] ; then
	echo "$(date -u +'%b %d %H:%M:%S') $0 access rights for letencrypt need update" | tee /var/log/mailserver.err
	chgrp -R ssl-cert /etc/letsencrypt/live /etc/letsencrypt/archive
fi

/usr/local/bin/mailserverstart.sh
