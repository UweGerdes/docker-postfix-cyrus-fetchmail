#!/bin/bash

while IFS=":" read -r user pass; do
	echo "saslpasswd2 create $user"
	echo "$pass" | saslpasswd2 -c $user -p
done < "/home/cyrus/cyrususers"