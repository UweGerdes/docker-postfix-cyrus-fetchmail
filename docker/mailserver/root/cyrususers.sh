#!/bin/bash

while IFS=":" read -r user pass; do
	echo "saslpasswd2 create $user"
	echo "$pass" | saslpasswd2 -p -u ${MAILNAME} -c $user
done < "/root/cyrususers"
