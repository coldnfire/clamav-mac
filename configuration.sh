#! /bin/bash

#Maintainer : coldnfire
#Reporting bug : laboserver@gmail.com

SW_USER=$(id -F 501)
path=$(pwd)

mkdir -p /var/log/clamav/ /var/lib/clamav/ /usr/local/var/run/clamav/ /var/run/freshclam/ /var/jail/
chown -R clamav:clamav /usr/local/etc/clamav/ /var/log/clamav/ /var/lib/clamav/ /usr/local/var/run/clamav/ /var/run/freshclam/
chmod 700 /var/jail/
cd /var/lib/clamav/ && touch whitelist.ign2

cd /usr/local/etc/clamav/
cp freshclam.conf.example freshclam.conf && cp clamd.conf.example clamd.conf

cd /usr/local/etc/clamav/
sed -ie 's/Example/#Example/g' clamd.conf
sed -ie "s/#LogFile \/tmp\/clamd.log/LogFile \/var\/log\/clamav\/clamd.log/g" clamd.conf
sed -ie 's/#LogFileMaxSize 2M/LogFileMaxSize 2M/g' clamd.conf
sed -ie 's/#LogTime yes/LogTime yes/g' clamd.conf
sed -ie 's/#LogClean yes/LogClean yes/g' clamd.conf
sed -ie 's/#LogVerbose yes/LogVerbose yes/g' clamd.conf
sed -ie 's/#LogRotate yes/LogRotate yes/g' clamd.conf
sed -ie 's/#ExtendedDetectionInfo yes/ExtendedDetectionInfo yes/g' clamd.conf
sed -ie "s/#DatabaseDirectory \/var\/lib\/clamav/DatabaseDirectory \/var\/lib\/clamav/g" clamd.conf
sed -ie "s/#LocalSocket \/tmp\/clamd.socket/LocalSocket \/usr\/local\/var\/run\/clamd.sock/g" clamd.conf
sed -ie 's/#LocalSocketMode 660/LocalSocketMode 660/g' clamd.conf
sed -ie 's/#TCPSocket 3310/TCPSocket 3310/g' clamd.conf
sed -ie 's/#MaxThreads 2/MaxThreads 2/g' clamd.conf
sed -ie 's/#MaxDirectoryRecursion 1/MaxDirectoryRecursion 1/g' clamd.conf

sed -ie 's/Example/#Example/g' freshclam.conf
sed -ie "s/#DatabaseDirectory \/var\/lib\/clamav/DatabaseDirectory \/var\/lib\/clamav/g" freshclam.conf
sed -ie "s/#UpdateLogFile \/var\/log\/freshclam.log/UpdateLogFile \/var\/log\/clamav\/freshclam.log/g" freshclam.conf
sed -ie 's/#LogFileMaxSize 2M/LogFileMaxSize 2M/g' freshclam.conf
sed -ie 's/#LogTime yes/LogTime yes/g' freshclam.conf
sed -ie 's/#LogVerbose yes/LogVerbose yes/g' freshclam.conf
sed -ie 's/#LogRotate yes/LogRotate yes/g' freshclam.conf
sed -ie "s/#PidFile \/var\/run\/freshclam.pid/PidFile \/var\/run\/freshclam\/freshclam.pid/g" freshclam.conf
sed -ie 's/#DatabaseOwner clamav/DatabaseOwner clamav/g' freshclam.conf
sed -ie 's/#Checks 24/Checks 3/g' freshclam.conf
sed -ie "s/#NotifyClamd \/path\/to\/clamd.conf/NotifyClamd \/usr\/local\/etc\/clamav\/clamd.conf/g" freshclam.conf

# Configuration clamav_rt.sh
mkdir -p /var/root/.clamav/
chown 700 /var/root/.clamav/

cd $path
sed -ie "s/FOLDER/FOLDER=/home/$SW_USER/g" clamav-rt.sh
read -p "Inform your email address : " mail
sed -ie "s/email/email=$mail/g" clamav-rt.sh
chmod 700 clamav-rt.sh

cp clamav-rt.sh /var/root/.clamav/

# Configuration postfix
cd /etc/postfix/ && touch sasl_password

read -p "Inform your relay host (for example gmail relay will be : smtp.gmail.com:587) : " relayhost
read -s -p "Inform your email password ? " password

relayhost="relayhost=$relayhost"
smtp_sasl_auth_enable="smtp_sasl_auth_enable=yes"
smtp_sasl_password_maps="smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd"
smtp_use_tls="smtp_use_tls=yes"
smtp_tls_security_level="smtp_tls_security_level=encrypt"
tls_random_source="tls_random_source=dev:/dev/urandom"
smtp_sasl_security_options="smtp_sasl_security_options=noanonymous"
smtp_always_send_ehlo="smtp_always_send_ehlo=yes"
smtp_sasl_mechanism_filter="smtp_sasl_mechanism_filter=plain"
sasl_password="$relayhost $email:$password"

for i in $relayhost $smtp_sasl_auth_enable $smtp_sasl_password_maps $smtp_use_tls $smtp_tls_security_level $tls_random_source $smtp_sasl_security_options $smtp_always_send_ehlo $mtp_sasl_mechanism_filter 
do
   echo "$i" >> main.cf
done

echo "$sasl_password" >> sasl_password

#Configuration Daemon
cd $path

chmod 644 com.clamav_tr.plist
sed -ie 's/<string>path<\/string>/<string>\/var\/root\/.clamav\/clamav-rt.sh<\/string>/g' com.clamav_tr.plist
cp com.clamav_tr.plist /Library/LaunchDaemons/
launchctl load -w /Library/LaunchDaemons/com.clamav_tr.plist
launchctl start -w /Library/LaunchDaemons/com.clamav_tr.plist

echo "Bye"
