# cyrus docker

FROM uwegerdes/baseimage
MAINTAINER Uwe Gerdes <entwicklung@uwegerdes.de>

ARG USERNAME='cyrus'
ARG PASSWORD='cyruspass'

ENV USERNAME=${USERNAME}
ENV PASSWORD=${PASSWORD}

RUN apt-get update && \
	apt-get install -y \
					cyrus-admin \
					cyrus-clients \
					cyrus-common \
					cyrus-imapd \
					cyrus-pop3d \
					sasl2-bin

# && \
#	apt-get clean && \
#	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#EXPOSE 110/tcp 143/tcp 465/tcp 587/tcp

CMD ["bash"]
