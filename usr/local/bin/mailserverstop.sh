#!/bin/bash

echo "NOT stopping replication mailserver"

if [ "`whoami`" != "cyrus" ] ; then
	echo "script has to be started as user cyrus"
	exit 1
fi
