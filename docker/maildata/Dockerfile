# maildata image to share volumes

FROM uwegerdes/baseimage
MAINTAINER Uwe Gerdes <entwicklung@uwegerdes.de>

ARG POSTFIX='/var/spool/postfix'

RUN mkdir -p ${POSTFIX}

VOLUME [ "${POSTFIX}" ]

CMD [ "true" ]
