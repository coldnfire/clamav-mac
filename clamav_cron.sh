#! /bin/bash

# Maintainer : coldnfire, laboserver@gmail.com
# Script "Clamscan by Launchd", coldnfire
# Dependency : postfix

user=
logfile="/var/log/clamav/clamscan-$(date +'%Y-%m-%d').log";
email_msg="Malware found !!!"
email=
folder=
jail=/var/jail/
mac=$(ifconfig en0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}');
log_path=/var/log/clamav/
retention=10

freshclam
postfix start

function clean_log_file() {
  local dir=$1 retention=$2

  ## Deleting old defined log file
  find ${log_path} -mtime +${retention} -type f -delete
}

for S in ${folder}; do
	
	DIRSIZE=$(du -sh "$S" 2>/dev/null | cut -f1);
	
	#Launch the deleting function
	clean_log_file ${log_path} ${retention}
	
	clamscan -ri "$S" >> "$logfile"

	# get the value of "Infected lines"
	MALWARE=$(tail "$logfile" | grep Infected | cut -d " " -f3);

	# Send an email if a some malware was found
	if [ "$MALWARE" -ne "0" ]; then
		
		echo "Scanning on $folder for total size $DIRSIZE, user is $user with mac address $mac, $email_msg the result of scan is in $logfile" | mail -s "$user $mac" "$email"
	fi
done

exit 0
