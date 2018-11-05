#!/bin/bash

# Maintainer : coldnfire, laboserver@gmail.com
# Script "ClamAV real time", by coldnfire
# Dependency : fswatch, postfix
# Google calandar
# Add popup
 
folder=
user=
jail=
email=

freshclam
/usr/local/sbin/clamd
postfix start
 
while :
do
 
fswatch -l 1 $folder |
while read file; do
	clamdscan -m -v --fdpass "$file" --move=$jail
        if [ "$?" == "1" ]; then
		echo -e "\033[31mMalware found!!!\033[00m" "File '$file' file has been mooved to jail !"
		echo -e "Malware found" "File '$file' has been mooved to jail" | mail -s "$user" $email
        fi
	done
done
