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

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

EXPOSE 25/tcp 465/tcp 587/tcp 110/tcp 143/tcp

CMD ["postfix","start-fg"]

