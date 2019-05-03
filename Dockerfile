# postfix docker

FROM uwegerdes/baseimage
MAINTAINER Uwe Gerdes <entwicklung@uwegerdes.de>

ARG CRONTAB_MIN="0-55/5"
ARG MAILNAME=mailserver.localdomain

ENV MAILNAME=${MAILNAME}

RUN apt-get update && \
	echo $(grep $(hostname) /etc/hosts | cut -f1) ${MAILNAME} >> /etc/hosts && \
	apt-get dist-upgrade -y && \
	apt-get install -y \
		cron \
		cyrus-admin \
		cyrus-clients \
		cyrus-common \
		cyrus-imapd \
		cyrus-pop3d \
		fetchmail \
		libsasl2-modules \
		locales \
		logrotate \
		postfix \
		rsync \
		rsyslog \
		sasl2-bin \
		amavisd-new \
		clamav-daemon \
		pyzor\
		razor \
		spamassassin && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY etc /etc
COPY root /root
COPY usr /usr
COPY var /var

RUN sed -i -e 's/\(printerror "could not determine current runlevel"\)/#\1/' /usr/sbin/invoke-rc.d && \
	sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d \
	chmod 600 /etc/postfix/sasl_password && \
	chmod 644 /etc/ssl/certs/ssl-cert-snakeoil.pem && \
	chown root:root /etc/ssl/certs/ssl-cert-snakeoil.pem && \
	chmod 640 /etc/ssl/private/ssl-cert-snakeoil.key && \
	chown root:ssl-cert /etc/ssl/private/ssl-cert-snakeoil.key && \
	chmod 755 /root/*.sh && \
	chmod 600 /root/cyrususers && \
	chmod 755 /usr/local/bin/* && \
	chown -R fetchmail:nogroup /var/lib/fetchmail && \
	chmod 600 /var/lib/fetchmail/fetchmailrc && \
	chmod 755 /var/lib/fetchmail/fetchstart.sh && \
	echo "${CRONTAB_MIN} * * * * fetchmail /var/lib/fetchmail/fetchstart.sh" >> /etc/crontab && \
	touch /var/log/fetchmail.log && \
	chmod 666 /var/log/fetchmail.log && \
	adduser cyrus ssl-cert && \
	usermod --shell /bin/bash cyrus && \
	adduser postfix mail && \
	adduser postfix sasl && \
	adduser postfix ssl-cert && \
	echo "${MAILNAME}" > /etc/mailname && \
	newaliases && \
	postmap /etc/postfix/sasl_password && \
	postmap /etc/postfix/sender_canonical && \
	cp -rp /var/spool/postfix /var/spool/postfix.init && \
	cp -rp /var/spool/cyrus/mail /var/spool/cyrus/mail.init && \
	touch /var/lib/cyrus/tls_sessions.db && \
	chown cyrus:mail /var/lib/cyrus/tls_sessions.db && \
	cp -rp /var/lib/cyrus /var/lib/cyrus.init && \
	adduser clamav amavis && \
	adduser amavis clamav && \
	sudo -H -u amavis razor-admin -create && \
	sudo -H -u amavis razor-admin -register && \
	freshclam

RUN postconf -e myorigin=/etc/mailname && \
	postconf -e myhostname=$MAILNAME && \
	postconf -e mydestination="$MAILNAME, localhost.localdomain, localhost" && \
	postconf -e relayhost=$(awk '{print $1}' /etc/postfix/sasl_password) && \
	postconf -e mynetworks="127.0.0.0/8 192.168.0.0/16" && \
	postconf -e message_size_limit=30720000 && \
	postconf -e inet_protocols=ipv4 && \
	postconf -e smtp_sasl_auth_enable=yes && \
	postconf -e smtp_sasl_security_options=noanonymous && \
	postconf -e smtp_sasl_password_maps=hash:/etc/postfix/sasl_password && \
	postconf -e smtp_tls_loglevel=1 && \
	postconf -e smtp_tls_CAfile="/etc/ssl/certs/ca-certificates.crt" && \
	postconf -e sender_canonical_maps=hash:/etc/postfix/sender_canonical && \
	postconf -e mailbox_transport=lmtp:unix:/var/run/cyrus/socket/lmtp && \
	postconf -e smtpd_sasl_path=smtpd && \
	postconf -e smtpd_sasl_auth_enable=yes && \
	postconf -e smtpd_sasl_security_options=noanonymous && \
	postconf -e broken_sasl_auth_clients=yes && \
	postconf -e smtpd_recipient_restrictions="permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination" && \
	postconf -e content_filter="smtp-amavis:[127.0.0.1]:10024" && \
	sed -i -r \
		-e 's/^#(smtps\s+inet.+smtpd)$/\1/' \
		-e 's/^#(submission\s+inet.+smtpd)$/\1/' /etc/postfix/master.cf && \
	postconf -F 'smtp/inet/chroot = n' && \
	postconf -F 'smtps/inet/chroot = n' && \
	postconf -F 'submission/inet/chroot = n' && \
	postconf -F 'lmtp/unix/chroot = n' && \
	sed -i -r \
		-e 's/(\s)#(idled\s)/\1\2/' \
		-e 's/(\s)#(imaps\s+cmd="imapd -s -U 30")/\1\2/' \
		-e 's/(\s)#(pop3s\s+cmd="pop3d -s -U 30")/\1\2/' \
		-e 's/(\s)(nntp\s)/\1#\2/' \
		-e 's/(\s)(http\s)/\1#\2/' \
		-e 's/(\s)(delprune\s)/\1#\2/' \
		-e 's/(\ssieve\s.+)localhost:/\1/' /etc/cyrus.conf && \
	sed -i -r \
		-e 's/#(admins: cyrus)/\1/' \
		-e 's/#(sasl_mech_list: PLAIN)/\1/' \
		-e 's/^sasl_pwcheck_method: auxprop/sasl_pwcheck_method: saslauthd/' \
		-e 's/#(tls_server_cert:)/\1/' \
		-e 's/#(tls_server_key:)/\1/' /etc/imapd.conf && \
	sed -i -r \
		-e 's/^(module\(load="imklog")/#\1/' /etc/rsyslog.conf && \
	sed -i -r \
		-e 's/^(.+delaycompress)/\1\n\t\tcopytruncate/' /etc/logrotate.d/rsyslog && \
	sed -i -r \
		-e 's/^(.+delaycompress)/\1\n\t\tcopytruncate/' /etc/logrotate.d/clamav-daemon && \
	sed -i -r \
		-e 's/^(.+delaycompress)/\1\n\t\tcopytruncate/' /etc/logrotate.d/clamav-freshclam && \
	sed -i -r \
		-e 's/^START=no/START=yes/' \
		-e 's/^MECHANISMS=".+"/MECHANISMS="sasldb"/' /etc/default/saslauthd && \
	sed -i -r \
		-e 's/#(@bypass_virus_checks_maps)/\1/' \
		-e 's/#(.+%bypass_virus_checks)/\1/' \
		-e 's/#(@bypass_spam_checks_maps)/\1/' \
		-e 's/#(.+%bypass_spam_checks)/\1/' /etc/amavis/conf.d/15-content_filter_mode && \
	sed -i -r \
		-e 's/^(pickup.+)/\1\n    -o content_filter=\n    -o receive_override_options=no_header_body_checks/' /etc/postfix/master.cf && \
	echo "smtp-amavis     unix    -       -       -       -       2       smtp" >> /etc/postfix/master.cf && \
	echo "	-o smtp_data_done_timeout=1200" >> /etc/postfix/master.cf && \
	echo "	-o smtp_send_xforward_command=yes" >> /etc/postfix/master.cf && \
	echo "	-o disable_dns_lookups=yes" >> /etc/postfix/master.cf && \
	echo "	-o max_use=20" >> /etc/postfix/master.cf && \
	echo "	-o smtp_tls_security_level=none" >> /etc/postfix/master.cf && \
	echo "" >> /etc/postfix/master.cf && \
	echo "127.0.0.1:10025 inet    n       -       -       -       -       smtpd" >> /etc/postfix/master.cf && \
	echo "	-o content_filter=" >> /etc/postfix/master.cf && \
	echo "	-o local_recipient_maps=" >> /etc/postfix/master.cf && \
	echo "	-o relay_recipient_maps=" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_restriction_classes=" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_delay_reject=no" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_client_restrictions=permit_mynetworks,reject" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_helo_restrictions=" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_sender_restrictions=" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_recipient_restrictions=permit_mynetworks,reject" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_data_restrictions=reject_unauth_pipelining" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_end_of_data_restrictions=" >> /etc/postfix/master.cf && \
	echo "	-o mynetworks=127.0.0.0/8" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_error_sleep_time=0" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_soft_error_limit=1001" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_hard_error_limit=1000" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_client_connection_count_limit=0" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_client_connection_rate_limit=0" >> /etc/postfix/master.cf && \
	echo "	-o receive_override_options=no_header_body_checks,no_unknown_recipient_checks" >> /etc/postfix/master.cf && \
	echo "	-o smtpd_tls_security_level=may" >> /etc/postfix/master.cf && \
	sed -i -r \
		-e 's/(sa_tag_level_deflt\s+=).+;/\1 3;/' \
		-e 's/(sa_tag2_level_deflt\s+=).+;/\1 3;/' \
		-e 's/(sa_kill_level_deflt\s+=).+;/\1 2000;/' /etc/amavis/conf.d/20-debian_defaults

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

#      ssh    smtp   pop3    imap    smtps   smtp_cl imaps   pop3s   sieve
EXPOSE 22/tcp 25/tcp 110/tcp 143/tcp 465/tcp 587/tcp 993/tcp 995/tcp 4190/tcp

CMD ["/usr/local/bin/start.sh"]
