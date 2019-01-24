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
		echo -e "Malware found!!!" "File '$file' file has been mooved to jail !" >> /var/log/clamav/jail.log
		echo -e "Malware found" "File '$file' has been mooved to jail" | mail -s "$user" $email
        fi
	done
done
