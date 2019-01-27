#!/bin/bash

# Maintainer : coldnfire, laboserver@gmail.com
# Script "ClamAV real time", by coldnfire
# Dependency : fswatch, postfix
 
logfile="/var/log/clamav/clamav_tr_$(date +'%Y-%m-%d').log";
mac=$(ifconfig en0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}');
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
		echo -e "Malware found!!!" "File '$file' file has been mooved to jail !" >> $logfile
		echo -e "Malware found" "File '$file' has been mooved to jail, the user is $user with mac address $mac the result of the scan is in $logfile" | mail -s "$user" $email
        fi
	done
done
