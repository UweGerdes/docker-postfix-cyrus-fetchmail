# postfix docker

FROM uwegerdes/baseimage
MAINTAINER Uwe Gerdes <entwicklung@uwegerdes.de>

ARG USERNAME='mailbox'
ARG PASSWORD='mailpass'
ARG MAILDOMAIN='mailpass'
ARG SMTPSERVER=smtp.server.com
ARG SMTPUSERNAME=user@server.com
ARG SMTPPASSWORD=mysecretpassword

ENV USERNAME=${USERNAME}
ENV PASSWORD=${PASSWORD}
ENV MAILDOMAIN=${MAILDOMAIN}
ENV SMTPSERVER=${SMTPSERVER}
ENV SMTPUSERNAME=${SMTPUSERNAME}
ENV SMTPPASSWORD=${SMTPPASSWORD}

RUN apt-get update && \
	apt-get install -y \
					postfix

# && \
#	apt-get clean && \
#	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY etc/aliases /etc/aliases

RUN echo "root:${USERNAME}" >> /etc/aliases && \
	newaliases

RUN postconf -e myhostname=$MAILDOMAIN && \
	postconf -e mydestination="$MAILDOMAIN, localhost.localdomain, localhost" && \
	postconf -e relayhost=$SMTPSERVER && \
	postconf -e mynetworks=0.0.0.0/0 && \
	postconf -e message_size_limit=30720000 && \
	postconf -e inet_protocols=ipv4 && \
	postconf -F 'lmtp/*/chroot = n'

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 25/tcp 465/tcp 587/tcp 110/tcp 143/tcp

CMD ["postfix","start-fg"]
