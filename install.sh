#! /bin/bash

#Maintainer : coldnfire
#Reporting bug : laboserver@gmail.com

RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m'
path=$(pwd)

ROOT_UID=0 
SW_USER=$(id -F 501)
if [ "$UID" -eq "$ROOT_UID" ]  # Will the real "root" please stand up?
then
	echo -e "${RED}You are log in root... It is not what i was expect.${NC}"
	echo -e "${RED}Connection with your standart user in progress.${NC}"
	su $SW_USER ./install.sh
	exit 130
else
  echo -e "${PURPLE}You are just an ordinary user (but mom loves you just the same).${NC}"
fi

program=("brew" "clamd" "fswatch" )
i=0

for list in "${program[@]}"
do
        ((i++))
        if ! [ -x "$(command -v $list)" ]; then
       		echo -e "${PURPLE}$list is not installed.${NC}" >&2
        	read -p -e "${PURPLE}You have to instal install $list. Do you want to install now ? (y/n) :${NC} " answer
       		if [ $i = "1" ] && [ $answer = "y" ]; then
                        echo -e "${GREEN}Installation of brew in progress !${NC}"
                        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
                elif [ $i = "2" ] && [ $answer = "y" ]; then
			echo -e "${GREEN}Installation of clamav in progress !${NC}"
                        brew install clamav
		elif [ $i = "3" ] && [ $answer = "y" ]; then
			echo -e "${GREEN}Installation of fswatch in progress !${NC}"
			brew install fswatch
		else
			echo -e "${RED}Come back when you will be ready to install $list.${NC}"
			exit 130
                fi
        else
        echo -e "${GREEN}$list installed !${NC}"
        fi
done

sudo $path/configuration.sh 
