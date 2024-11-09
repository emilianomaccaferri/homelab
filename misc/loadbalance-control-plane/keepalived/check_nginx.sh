#!/bin/sh
if [ -z "`/bin/pidof nginx`" ]; then
 systemctl stop keepalived.service
 exit 1
fi

# remember to sudo chmod 0755 this script!