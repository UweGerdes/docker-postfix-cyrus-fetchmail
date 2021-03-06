#!/bin/bash

if [ "`whoami`" != "root" ] ; then
	echo "$0 has to be started as user root"
	exit 1
fi

CERTBOTFILE="/root/.certbot"

if [ ! -f "$CERTBOTFILE" ]; then
	echo "File $CERTBOTFILE not found. Please place .certbot file in appropriate location."
	exit 2
fi

source $CERTBOTFILE

if [ -z "$CERTBOT_DOMAIN" ] ; then
	echo "Variable \$CERTBOT_DOMAIN not found. Please set CERTBOT_DOMAIN=(your domain name) in $CERTBOTFILE, e.g."
	echo
	echo "CERTBOT_DOMAIN=foobar.domain.com"
	exit 3
fi

if [ -x "/root/hook.sh" ] ; then
	echo "$0 about to install certbot"
	apt-get update
	apt-get install -y software-properties-common
	add-apt-repository -y ppa:certbot/certbot
	apt-get update
	apt-get install -y bind9-host certbot
	PREV_DIR="$(pwd)"
	cd /root
	certbot --manual --text --preferred-challenges dns \
		--non-interactive \
		--agree-tos \
		--register-unsafely-without-email \
		--manual-public-ip-logging-ok \
		 --manual-auth-hook ./hook.sh \
		 --manual-cleanup-hook ./hook.sh \
		--pre-hook /root/pre-hook.sh \
		--post-hook /root/post-hook.sh \
		-d "$CERTBOT_DOMAIN" \
		certonly
	sed -i -r \
		-e "s/^(tls_server_cert:).+/\1 \/etc\/letsencrypt\/live\/$CERTBOT_DOMAIN\/fullchain.pem/" \
		-e "s/^(tls_server_key:).+/\1 \/etc\/letsencrypt\/live\/$CERTBOT_DOMAIN\/privkey.pem/" \
		/etc/imapd.conf
	sed -i -r \
		-e "s/^(0 \*\/12 \* \* \* root test -x \/usr\/bin\/certbot).+/#\1 -a \\! -d \/run\/systemd\/system \&\& perl -e 'sleep int(rand(3600))' \&\& cd \/root\/ \&\& certbot -q --manual-public-ip-logging-ok renew/" \
		/etc/cron.d/certbot
	postconf -e smtpd_tls_security_level=may
	postconf -e smtp_tls_security_level=may
	postconf -e smtp_tls_note_starttls_offer=yes
	postconf -e smtpd_tls_loglevel=1
	postconf -e smtpd_tls_received_header=yes
	postconf -e smtpd_tls_CAfile=/etc/ssl/certs/ca-certificates.crt
	postconf -e smtpd_tls_cert_file=/etc/letsencrypt/live/$CERTBOT_DOMAIN/fullchain.pem
	postconf -e smtpd_tls_key_file=/etc/letsencrypt/live/$CERTBOT_DOMAIN/privkey.pem
	cd "${PREV_DIR}"
else
	echo "/root/hook.sh not found"
	exit 4
fi
