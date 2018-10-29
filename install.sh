#! /bin/bash

#Maintainer : coldnfire
#Reporting bug : laboserver@gmail.com



DIRECTORY=/usr/local/Homebrew
function install_source ()
{
	if [ -d "$DIRECTORY" ]; then
		brew install clamav		
		brew install fswatch
	else
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		brew install clamav
		brew install fswatch
	fi
}
	
function install_configuration
{
mkdir -p /usr/local/etc/clamav/ /var/log/clamav/ /var/lib/clamav/ /usr/local/var/run/clamav/ /var/run/freshclam/
chown -R clamv:clamv /usr/local/etc/clamav/ /var/log/clamav/ /var/lib/clamav/ /usr/local/var/run/clamav/ /var/run/freshclam/
cd /var/lib/clamav/ && touch whitelist.ign2

cd /usr/local/etc/clamav/
cp freshclam.conf.example freshclam.conf && cp clamd.conf.example clamd.conf

cd /usr/local/etc/clamav/
sed -ie 's/Example/#Example/g' clamd.conf
sed -i -e "s/#LogFile \/tmp\/clamd.log/LogFile \/var\/log\/clamav\/clamd.log/g" clamd.conf
sed -ie 's/#LogFileMaxSize 2M/LogFileMaxSize 2M/g' clamd.conf
sed -ie 's/#LogTime yes/LogTime yes/g' clamd.conf
sed -ie 's/#LogClean yes/LogClean yes/g' clamd.conf
sed -ie 's/#LogVerbose yes/LogVerbose yes/g' clamd.conf
sed -ie 's/#LogRotate yes/LogRotate yes/g' clamd.conf
sed -ie 's/#ExtendedDetectionInfo yes/ExtendedDetectionInfo yes/g' clamd.conf
sed -i -e "s/#DatabaseDirectory \/var\/lib\/clamav/DatabaseDirectory \/var\/lib\/clamav/g" clamd.conf
sed -i -e "s/#LocalSocket \/tmp\/clamd.socket/LocalSocket \/usr\/local\/var\/run\/clamd.sock/g" clamd.conf
sed -ie 's/#LocalSocketMode 660/LocalSocketMode 660/g' clamd.conf
sed -ie 's/#TCPSocket 3310/TCPSocket 3310/g' clamd.conf
sed -ie 's/#MaxThreads 2/MaxThreads 2/g' clamd.conf
sed -ie 's/#MaxDirectoryRecursion 1/MaxDirectoryRecursion 1/g' clamd.conf

sed -ie 's/Example/#Example/g' freshclam.conf
sed -i -e "s/#DatabaseDirectory \/var\/lib\/clamav/DatabaseDirectory \/var\/lib\/clamav/g" freshclam.conf
sed -i -e "s/#UpdateLogFile \/var\/log\/freshclam.log/UpdateLogFile \/var\/log\/clamav\/freshclam.log/g" freshclam.conf
sed -ie 's/#LogFileMaxSize 2M/LogFileMaxSize 2M/g' freshclam.conf
sed -ie 's/#LogTime yes/LogTime yes/g' freshclam.conf
sed -ie 's/#LogVerbose yes/LogVerbose yes/g' freshclam.conf
sed -ie 's/#LogRotate yes/LogRotate yes/g' freshclam.conf
sed -i -e "s/#PidFile \/var\/run\/freshclam.pid/PidFile \/var\/run\/freshclam\/freshclam.pid/g" freshclam.conf
sed -ie 's/#DatabaseOwner clamav/DatabaseOwner clamav/g' freshclam.conf
sed -ie 's/#Checks 24/Checks 3/g' freshclam.conf
sed -i -e "s/#NotifyClamd \/path\/to\/clamd.conf/NotifyClamd \/usr\/local\/etc\/clamav\/clamd.conf/g" freshclam.conf
}

function install_clamav_deamon
{
cp com.clamav_tr.plist /Library/LaunchDaemons/ && chmod 750 com.clamav_tr.plist
}

