#!/bin/bash

while IFS=":" read -r user pass; do
	echo "saslpasswd2 create $user ${MAILNAME}"
	echo "$pass" | saslpasswd2 -c $user -p -u hostname
done < "/home/cyrus/cyrususers"
