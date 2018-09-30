#!/bin/bash

if [ -n "$(find "/var/spool/postfix/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
    echo "Empty postfix directory"
else
    echo "Not empty or NOT a directory"
fi

if [ -n "$(find "/var/spool/postfix/active/" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
    echo "Empty postfix/active directory"
else
    echo "Not empty or NOT a directory"
fi

