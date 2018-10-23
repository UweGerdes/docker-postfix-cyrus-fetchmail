#!/bin/bash

echo "NOT starting replication mailserver"

if [ "`whoami`" != "cyrus" ] ; then
	echo "script has to be started as user cyrus"
	exit 1
fi
