# postfix docker

FROM uwegerdes/baseimage
MAINTAINER Uwe Gerdes <entwicklung@uwegerdes.de>

ARG SMTPSERVER=smtp.server.com
ARG SENDERCANONICAL=user@server.com

ENV MAILNAME=mailserver
ENV FETCHMAILHOME=/root
ENV FETCHMAILUSER=root

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY etc/aliases /etc/aliases
COPY etc/logrotate.d/fetchmail.log /etc/logrotate.d/fetchmail.log
COPY etc/postfix/sasl_password /etc/postfix/sasl_password
COPY root/cyrususers /root/cyrususers
COPY var/lib/fetchmail/fetchmailrc /var/lib/fetchmail/fetchmailrc
COPY var/lib/fetchmail/fetchstart.sh /var/lib/fetchmail/fetchstart.sh
COPY usr/lib/sasl2/smtpd.conf /usr/lib/sasl2/smtpd.conf

RUN chmod 600 /etc/postfix/sasl_password && \
	chmod 600 /root/cyrususers && \
	chmod 755 /usr/local/bin/entrypoint.sh && \
	chmod 600 /var/lib/fetchmail/fetchmailrc && \
	touch /var/log/fetchmail.log && \
	chmod 666 /var/log/fetchmail.log && \
	chmod 755 /var/lib/fetchmail/fetchstart.sh

RUN apt-get update && \
	apt-get install -y \
		cron \
		cyrus-admin \
		cyrus-clients \
		cyrus-common \
		cyrus-imapd \
		cyrus-pop3d \
		fetchmail \
		libsasl2-modules \
		logrotate \
		postfix \
		rsyslog \
		sasl2-bin && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
	adduser cyrus ssl-cert && \
	usermod --shell /bin/bash cyrus && \
	adduser postfix mail && \
	adduser postfix sasl && \
	echo "${MAILNAME}" > /etc/mailname && \
	newaliases && \
	postmap /etc/postfix/sasl_password && \
	echo "root ${SENDERCANONICAL}" > /etc/postfix/sender_canonical && \
	postmap /etc/postfix/sender_canonical && \
	cp -rp /var/spool/postfix /var/spool/postfix.init && \
	chown fetchmail:nogroup /var/lib/fetchmail/fetchmailrc && \
	echo "4-59/5 * * * * fetchmail /var/lib/fetchmail/fetchstart.sh" >> /etc/crontab

RUN postconf -e myorigin=/etc/mailname && \
	postconf -e myhostname=$MAILNAME && \
	postconf -e mydestination="$MAILNAME, $MAILNAME.localdomain, localhost.localdomain, localhost" && \
	postconf -e relayhost=$SMTPSERVER && \
	postconf -e mynetworks=0.0.0.0/0 && \
	postconf -e message_size_limit=30720000 && \
	postconf -e inet_protocols=ipv4 && \
	postconf -e smtp_sasl_auth_enable=yes && \
	postconf -e smtp_sasl_security_options=noanonymous && \
	postconf -e smtp_sasl_password_maps=hash:/etc/postfix/sasl_password && \
	postconf -e sender_canonical_maps=hash:/etc/postfix/sender_canonical && \
	postconf -e mailbox_transport=lmtp:unix:/var/run/cyrus/socket/lmtp && \
	postconf -e smtpd_sasl_path=smtpd && \
	postconf -e smtpd_sasl_auth_enable=yes && \
	postconf -e smtpd_sasl_security_options=noanonymous && \
	postconf -e broken_sasl_auth_clients=yes && \
	postconf -e smtpd_recipient_restrictions="permit_sasl_authenticated, reject_unauth_destination" && \
	postconf -e smtpd_enforce_tls=yes && \
	postconf -e smtpd_tls_security_level=encrypt && \
	sed -i -r \
		-e 's/^#(smtps\s+inet.+smtpd)$/\1/' \
		-e 's/^#(submission\s+inet.+smtpd)$/\1/' /etc/postfix/master.cf && \
	postconf -F 'smtp/inet/chroot = n' && \
	postconf -F 'smtps/inet/chroot = n' && \
	postconf -F 'submission/inet/chroot = n' && \
	postconf -F 'lmtp/unix/chroot = n' && \
	sed -i -r \
		-e 's/(\s)#(imaps\s+cmd="imapd -s -U 30")/\1\2/' \
		-e 's/(\s)(nntp\s)/\1#\2/' \
		-e 's/(\s)(http\s)/\1#\2/' \
		-e 's/(\s)(sieve\s)/\1#\2/' /etc/cyrus.conf && \
	sed -i -r \
		-e 's/#(admins: cyrus)/\1/' \
		-e 's/#(sasl_mech_list: PLAIN)/\1/' \
		-e 's/^sasl_pwcheck_method: auxprop/sasl_pwcheck_method: saslauthd/' \
		-e 's/#(tls_server_cert:)/\1/' \
		-e 's/#(tls_server_key:)/\1/' /etc/imapd.conf && \
	sed -i -r \
		-e 's/^(module\(load="imklog")/#\1/' /etc/rsyslog.conf && \
	sed -i -r \
		-e 's/^START=no/START=yes/' \
		-e 's/^MECHANISMS=".+"/MECHANISMS="sasldb"/' /etc/default/saslauthd && \
	touch /var/lib/cyrus/tls_sessions.db && \
	chown cyrus:mail /var/lib/cyrus/tls_sessions.db

COPY etc/ssl /etc/ssl/
RUN chmod 644 /etc/ssl/certs/ssl-cert-snakeoil.pem && \
	chown root:root /etc/ssl/certs/ssl-cert-snakeoil.pem && \
	chmod 640 /etc/ssl/private/ssl-cert-snakeoil.key && \
	chown root:ssl-cert /etc/ssl/private/ssl-cert-snakeoil.key

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 22/tcp 25/tcp 110/tcp 143/tcp 465/tcp 587/tcp 993/tcp

CMD ["bash"]
