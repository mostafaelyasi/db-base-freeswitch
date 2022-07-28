#!/bin/bash 
LOGFILE=fs-log
rm -rf /backupfs/$LOGFILE-$(date +%a).log
cp /usr/local/freeswitch/log/freeswitch.log /backupfs/$LOGFILE-$(date +%a).log
systemctl kill -s HUP freeswitch.service
 