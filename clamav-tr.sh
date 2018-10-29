#!/bin/bash

# Maintainer : coldnfire, laboserver@gmail.com
# Script "ClamAV real time", by coldnfire
# Dependency : fswatch
 
DOSSIER=$HOME
user=echo $USER
QUARANTAINE=/var/jail/
LOG=/Users/jv/clamav-tr/clamav-tr/jail.log
email=$email

/usr/local/sbin/clamd
 
while :
do
 
fswatch -l 1 $DOSSIER |
while read FICHIER; do
	clamdscan -m -v --fdpass "$FICHIER" --move=$QUARANTAINE
        if [ "$?" == "1" ]; then
		echo -e "\033[31mMalware found!!!\033[00m" "File '$FICHIER' file has been mooved to jail !"
		echo -e "Malware found" "File '$FICHIER' has been mooved to jail" | mail -s "$user" $email
        fi
	done
done
