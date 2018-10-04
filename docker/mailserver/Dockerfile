# postfix docker

FROM uwegerdes/baseimage
MAINTAINER Uwe Gerdes <entwicklung@uwegerdes.de>

ARG USERNAME='mailbox'
ARG PASSWORD='mailpass'
ARG MAILNAME='hostname'
ARG SMTPSERVER=smtp.server.com
ARG SENDERCANONICAL=user@server.com

ENV USERNAME=${USERNAME}
ENV PASSWORD=${PASSWORD}
ENV MAILNAME=${MAILNAME}

COPY etc/aliases /etc/aliases
COPY etc/postfix/sasl_password /etc/postfix/sasl_password
COPY cyrususers /root/cyrususers
COPY cyrususers.sh /root/cyrususers.sh
RUN chmod 755 /root/cyrususers.sh

RUN echo "root:${USERNAME}" >> /etc/aliases && \
	apt-get update && \
	apt-get install -y \
					cyrus-admin \
					cyrus-clients \
					cyrus-common \
					cyrus-imapd \
					cyrus-pop3d \
					fetchmail \
					libsasl2-modules \
					postfix \
					sasl2-bin

#					 && \
#	apt-get clean && \
#	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "${MAILNAME}" > /etc/mailname && \
	newaliases && \
	chmod 600 /etc/postfix/sasl_password && \
	postmap /etc/postfix/sasl_password && \
	echo "root ${SENDERCANONICAL}" > /etc/postfix/sender_canonical && \
	postmap /etc/postfix/sender_canonical

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
	postconf -F 'smtp/inet/chroot = n' && \
	postconf -F 'lmtp/*/chroot = n' && \
	cp -rp /var/spool/postfix /var/spool/postfix.init && \
	sed -i -E 's/#(munge8bit: no)/\1/' /etc/imapd.conf && \
	sed -i -E 's/#(admins: cyrus)/\1/' /etc/imapd.conf && \
	sed -i -E 's/#(sasl_mech_list: PLAIN)/\1/' /etc/imapd.conf && \
	sed -i -E 's/^sasl_pwcheck_method: auxprop/sasl_pwcheck_method: saslauthd/' /etc/imapd.conf && \
	sed -i -E 's/^START=no/START=yes/' /etc/default/saslauthd && \
	sed -i -E 's/^MECHANISMS=".+"/MECHANISMS="sasldb"/' /etc/default/saslauthd && \
	/root/cyrususers.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 25/tcp
#EXPOSE 110/tcp 143/tcp 465/tcp 587/tcp

CMD ["postfix","start-fg"]
