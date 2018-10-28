#!/usr/bin/env bash

TARGETHOST="$1"

if [ -z "${TARGETHOST}" ] ; then
	echo "${0} missing argument: targethost"
	exit 1
fi

echo "Try connection to ${TARGETHOST}"

LOCAL_TIME=`date +%s`
REMOTE_TIME=`sudo -u cyrus ssh -p 61022 cyrus@${1} date +%s`

if [ -z "${REMOTE_TIME}" ] ; then
	read -p "${TARGETHOST} host not found - exiting"
	exit 2
fi

DIFF_TIME=$((REMOTE_TIME-LOCAL_TIME))

if [[ ("${DIFF_TIME}" > 8) ]] ; then
	read -p "install key based login to ${TARGETHOST}? [RETURN]"
	sudo -H -u cyrus sh -c "ssh-keygen -t rsa -C cyrus@mailserver -N '' -f ~/.ssh/id_rsa && ssh-copy-id -i ~/.ssh/id_rsa.pub -p 61022 cyrus@${TARGETHOST}"
fi
