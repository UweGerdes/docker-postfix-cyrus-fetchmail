#!/bin/bash
#

echo USERNAME=${USERNAME}
echo PASSWORD=${PASSWORD}
echo MAILDOMAIN=${MAILDOMAIN}
echo SMTPSERVER=${SMTPSERVER}
echo SMTPUSERNAME=${SMTPUSERNAME}
echo SMTPPASSWORD=${SMTPPASSWORD}

echo postconf -e myhostname=$MAILDOMAIN
echo postconf -F 'lmtp/*/chroot = n'

if [ -n /etc/aliases ]; then
	echo "no aliases"
#	echo "root:${USERNAME}" >> /etc/aliases
#	newaliases
else
	ls -l /etc/aliases*
	cat /etc/aliases
fi
