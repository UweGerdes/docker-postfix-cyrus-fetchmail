# postfix docker

FROM uwegerdes/baseimage
MAINTAINER Uwe Gerdes <entwicklung@uwegerdes.de>

ARG USERNAME='mailbox'
ARG PASSWORD='mailpass'
ARG MAILDOMAIN='hostname'
ARG SMTPSERVER=smtp.server.com
ARG SENDERCANONICAL=user@server.com

ENV USERNAME=${USERNAME}
ENV PASSWORD=${PASSWORD}
ENV MAILDOMAIN=${MAILDOMAIN}

RUN apt-get update && \
	apt-get install -y \
					libsasl2-modules \
					postfix

# && \
#	apt-get clean && \
#	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY etc/aliases /etc/aliases
COPY etc/postfix/sasl_password /etc/postfix/sasl_password

RUN echo "root:${USERNAME}" >> /etc/aliases && \
	newaliases && \
	chmod 600 /etc/postfix/sasl_password && \
	postmap /etc/postfix/sasl_password && \
	echo "root ${SENDERCANONICAL}" > /etc/postfix/sender_canonical && \
	postmap /etc/postfix/sender_canonical

RUN postconf -e myhostname=$MAILDOMAIN && \
	postconf -e mydestination="$MAILDOMAIN, $MAILDOMAIN.localdomain, localhost.localdomain, localhost" && \
	postconf -e relayhost=$SMTPSERVER && \
	postconf -e mynetworks=0.0.0.0/0 && \
	postconf -e message_size_limit=30720000 && \
	postconf -e inet_protocols=ipv4 && \
	postconf -e smtp_sasl_auth_enable=yes && \
	postconf -e smtp_sasl_security_options=noanonymous && \
	postconf -e smtp_sasl_password_maps=hash:/etc/postfix/sasl_password && \
	postconf -e sender_canonical_maps=hash:/etc/postfix/sender_canonical && \
	postconf -F 'lmtp/*/chroot = n'

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 25/tcp

CMD ["postfix","start-fg"]
