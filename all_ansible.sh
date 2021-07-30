#!/bin/bash
## !!! Need put in the root of the project Ansible with the "inventory" directory !!!
# ---
## The script is designed to run SHELL commands using Ansible on a group of hosts.
##	a) update the host list (put char 'u')
##	b) run shell command (use for one command: ./all_ansible.sh uptime)
##	c) run many shell commands (use for many commands: ./all_ansible.sh many)
# ---
NOC="\033[0m"
OKC="\033[32m"
ERC="\033[31m"
WA0="\033[0;33m"
WA1="\033[1;33m"
TSC="\033[34m"
PRC="\033[35m"
PUR="\033[1;35m"
BL0="\033[0;36m"
BL1="\033[1;36m"
echo ''
HST="all_hosts"
LOG="all_logs"
echo ''
check_overload() {
	if [[ $1 == *reboot* || $1 == restart || $1 == *shutdown* || $1 == *poweroff* ]]; then
		echo -e $ERC "\nNO OVERLOADS: $1" $NOC
		exit 1
	fi
}
check_user () {
	USER=$(whoami)
	userpress=""
	echo -e $WA0"\nPress 'Y' if your user is "$OKC$USER$WA0" otherwise enter another"$NOC
	while read -r -n1 key; do
		if [[ $key == $'\e' ]]; then
			break
		elif [[ $key == y ]]; then
			return
		elif [[ $key == '' ]]; then
			echo -e $WA1 "\nEnter your username:" $NOC
			read -r -n10 USER
			echo -e $TSC "You have entered a USER: $WA0$USER" $NOC
			sleep 2
			return
		fi
		printf $TSC "\nYou have typed: $WA0$userpress\n" $NOC
		userpress+=$key
	done
}
string_input () {
	if [ -z $1 ]; then
		ANSIBLE_COMMANDS="hostname"
		echo -e $BL0 "\nDefaulting to $ANSIBLE_COMMANDS for testing" $NOC
	elif [[ $1 && $1 != many ]]; then
		ANSIBLE_COMMANDS="hostname && $1"
		echo -e $BL1 "\nStart in $ANSIBLE_COMMANDS" $NOC
	elif [ $1 == many ]; then
		echo -e $WA1 "\nEnter the command you want: \
			\n$PRC Example: command; command ...\n Example: command && command ..." $NOC
		read -r -n999 input
		check_overload "$input"
		ANSIBLE_COMMANDS="hostname && $input"
		echo -e $BL1 "\nStart in $ANSIBLE_COMMANDS" $NOC
	fi
}
string_output () {
	NUMB=0
	while IFS= read -r line; do
		STRING=$(awk '{printf $2 $3}' <<< "$line")
		STRING=$(sed "s:\::=:" <<< "$STRING")
		   echo -e "HOST_"$(( ++NUMB )) $STRING >> $HST
	done < <(printf '%s\n' "$1")
}
echo ''
userinput=""
echo -e $WA0"\nPress 'ESC' key to quit, or 'U' to update hosts and 'C' to continue Ansible" $NOC
while read -r -n1 key; do
	if [[ $key == $'\e' ]]; then
		break
	elif [[ $key == u ]]; then
		rm $HST
		RETURN="$(grep "ansible_ssh_host:" inventory/*)"
		echo ''
		string_output "$RETURN"
		echo -e $OKC"\nUpdate: Well Done! \nHostfile" $HST \
			"\nPress 'ESC' key to quit" $NOC
	elif [[ $key == c ]]; then
		rm $LOG
		check_overload $1
		check_user
		string_input $1
		ANSIBLE_HOST_KEY_CHECKING=False \
		ansible -u $USER -i $HST all -b -m shell -a "$ANSIBLE_COMMANDS" -e "serial=1" >> $LOG
		echo -e $OKC"\nAnsible: Well Done! \nConsole output information in" $LOG \
			"\nPress 'ESC' key to quit" $NOC
	fi
	printf $TSC "\nYou have typed: $WA0$userinput\n" $NOC
	userinput+=$key
done
echo -e '\n'
exit 0
