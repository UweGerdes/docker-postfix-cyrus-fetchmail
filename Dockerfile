# postfix docker

FROM uwegerdes/baseimage
MAINTAINER Uwe Gerdes <entwicklung@uwegerdes.de>

ARG SMTPSERVER=smtp.server.com
ARG SENDERCANONICAL=user@server.com

ENV MAILNAME=mailserver
ENV FETCHMAILHOME=/root
ENV FETCHMAILUSER=root

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh
COPY etc/aliases /etc/aliases
COPY etc/postfix/sasl_password /etc/postfix/sasl_password
COPY root/cyrususers /root/cyrususers
RUN chmod 600 /root/cyrususers
COPY root/fetchmailrc /root/fetchmailrc
RUN chmod 600 /root/fetchmailrc
COPY usr/lib/sasl2/smtpd.conf /usr/lib/sasl2/smtpd.conf

RUN apt-get update && \
	apt-get install -y \
		cyrus-admin \
		cyrus-clients \
		cyrus-common \
		cyrus-imapd \
		cyrus-pop3d \
		fetchmail \
		libsasl2-modules \
		postfix \
		rsyslog \
		sasl2-bin && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
	adduser cyrus ssl-cert && \
	adduser postfix mail && \
	echo "${MAILNAME}" > /etc/mailname && \
	newaliases && \
	chmod 600 /etc/postfix/sasl_password && \
	postmap /etc/postfix/sasl_password && \
	echo "root ${SENDERCANONICAL}" > /etc/postfix/sender_canonical && \
	postmap /etc/postfix/sender_canonical && \
	cp -rp /var/spool/postfix /var/spool/postfix.init

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
	postconf -F 'smtp/inet/chroot = n' && \
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

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 25/tcp 110/tcp 143/tcp 465/tcp 587/tcp

CMD ["bash"]
