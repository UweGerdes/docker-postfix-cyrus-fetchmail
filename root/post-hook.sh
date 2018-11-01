#!/usr/bin/env bash

CERTBOTFILE="/root/.certbot"

if [ ! -f "$CERTBOTFILE" ]; then
	echo "File $CERTBOTFILE not found. Please add  \"CERTBOT_DOMAIN=your.domain.com\" to that file."
	exit 1
fi

source $CERTBOTFILE

if [ -z "$CERTBOT_DOMAIN" ]; then
	echo "Please add  \"CERTBOT_DOMAIN=your.domain.com\" to $CERTBOTFILE."
	echo "Please execute 'chgrp -R ssl-cert /etc/letsencrypt/live /etc/letsencrypt/archive'"
	exit 2
fi

if [ "$(ls -l /etc/letsencrypt/live/$CERTBOT_DOMAIN/cert.pem | awk '{print $4}')" != "ssl-cert" ] ; then
	echo "$(date -u +'%b %d %H:%M:%S') $0 access rights for letsencrypt need update" | tee /var/log/mailserver.err
	chgrp -R ssl-cert /etc/letsencrypt/live /etc/letsencrypt/archive
	chmod 750 /etc/letsencrypt/live /etc/letsencrypt/archive
fi

/usr/local/bin/mailserverstart.sh
