#! /bin/bash

#Maintainer : coldnfire
#Reporting bug : laboserver@gmail.com

                ..:::::::::..
           ..:::aad8888888baa:::..
        .::::d:?88888888888?::8b::::.
      .:::d8888:?88888888??a888888b:::.
    .:::d8888888a8888888aa8888888888b:::.
   ::::dP::::::::88888888888::::::::Yb::::
  ::::dP:::::::::Y888888888P:::::::::Yb::::
 ::::d8:::::::::::Y8888888P:::::::::::8b::::
.::::88::::::::::::Y88888P::::::::::::88::::.
:::::Y8baaaaaaaaaa88P:T:Y88aaaaaaaaaad8P:::::
:::::::Y88888888888P::|::Y88888888888P:::::::
::::::::::::::::888:::|:::888::::::::::::::::
`:::::::::::::::8888888888888b::::::::::::::'
 :::::::::::::::88888888888888::::::::::::::
  :::::::::::::d88888888888888:::::::::::::
   ::::::::::::88::88::88:::88::::::::::::
    `::::::::::88::88::88:::88::::::::::'
      `::::::::88::88::P::::88::::::::'
        `::::::88::88:::::::88::::::'
           ``:::::::::::::::::::''
                ``:::::::::''

path=pwd


ROOT_UID=0   # Root has $UID 0.
SW_USER=$(id -F 501)
if [ "$UID" -eq "$ROOT_UID" ]  # Will the real "root" please stand up?
then
	echo "You are root... It is not what i was expect."
	echo "Connection with your standart user in progress."
	su $SW_USER ./install.sh
	exit 130
else
  echo "You are just an ordinary user (but mom loves you just the same)."
fi

function install_source ()
{
program=("brew" "clamd" "fswatch" )
i=0

for list in "${program[@]}"
do
        i+=1
        if ! [ -x "$(command -v $list)" ]; then
       		echo "$list is not installed." >&2
        	read -P "You have to instal install $list. Do you want to install now ? (y/n) : " answer
       		if [ "$i==1" ] && [ "$answer==y" ]; then
                        echo "Installation of brew in progress !"
                        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
                elif [ "$i==2" ] && [ "$answer==y" ]; then
			echo "Installation of clamav in progress !"
                        brew install clamav
		elif [ "$i==3" ] && [ "$answer==y"]; then
			echo "Installation of fswatch in progress !"
			brew install fswatch
		else
			echo "Come back when you will be ready to install $list."
			exit 130
                fi
        else
        echo "$list installed !"
        fi
done

echo "Your password is necessary now to install the rest of the program"
sudo su ./install.sh configuration
exit 130
	
configuration () {
mkdir -p /usr/local/etc/clamav/ /var/log/clamav/ /var/lib/clamav/ /usr/local/var/run/clamav/ /var/run/freshclam/
chown -R clamav:clamav /usr/local/etc/clamav/ /var/log/clamav/ /var/lib/clamav/ /usr/local/var/run/clamav/ /var/run/freshclam/
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
cd $path
read -P "Inform the path of your home folder : " folder
sed -ie "s/FOLDER/FOLDER=$folder/g" clamav-rt.sh

read -P "Inform the name of your user : " user
sed -ie "s/user/user=echo $user/g" clamav-rt.sh

read -P "Inform your email address : " mail
sed -ie "s/email/email=$mail/g" clamav-rt.sh


# Configuration postfix
cd /etc/postfix/ && touch sasl_password

read -P "Inform your relay host (for example gmail relay will be : smtp.gmail.com:587) : " relayhost 
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

for i in $relayhost $smtp_sasl_auth_enable $smtp_sasl_password_maps $smtp_use_tls $smtp_tls_security_level $tls_random_source $smtp_sasl_security_options $smtp_always_send_ehlo $mtp_sasl_mechanism_filter
do
   echo "$i" >> main.cf
done

#Configuration Daemon
}
