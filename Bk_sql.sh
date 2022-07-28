#!/bin/bash 
db_name=fsdir 
DIR=`date +%d-%m-%y` 
DEST=/backups/$DIR 
mkdir $DEST 
zipfile=$DEST/$db_name-$(date +%d-%m-%Y_%H-%M-%S).zip
echo $zipfile 
sudo -u postgres /usr/bin/pg_dump -Fc  --port=5432 fsdir > $zipfile 
echo Backup Stored at $(date) >> $DEST/psqlbk_log.txt 
