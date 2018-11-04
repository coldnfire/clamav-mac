#! /bin/bash

#Maintainer : coldnfire
#Reporting bug : laboserver@gmail.com

path=$(pwd)

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

program=("brew" "clamd" "fswatch" )
i=0

for list in "${program[@]}"
do
        ((i++))
        if ! [ -x "$(command -v $list)" ]; then
       		echo "$list is not installed." >&2
        	read -p "You have to instal install $list. Do you want to install now ? (y/n) : " answer
       		if [ $i = "1" ] && [ $answer = "y" ]; then
                        echo "Installation of brew in progress !"
                        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
                elif [ $i = "2" ] && [ $answer = "y" ]; then
			echo "Installation of clamav in progress !"
                        brew install clamav
		elif [ $i = "3" ] && [ $answer = "y" ]; then
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

sudo $path/configuration.sh 

