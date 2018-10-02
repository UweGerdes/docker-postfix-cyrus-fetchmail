#!/bin/bash
while IFS=":" read -r user pass; do
	case "$key" in
		'#'*) ;;
		*)
			echo "saslpasswd2 create $user"
			echo "$pass" | saslpasswd2 -c $user -p
	esac
done < "/home/cyrus/cyrususers"
