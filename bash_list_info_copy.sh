#!/bin/bash
#start: ssh root@you.host 'bash -s' < bash_list_info_copy.sh
#start: ssh -i ~/.ssh/id_rsa_you.rsa.key root@you.host 'bash -s' < bash_list_info_copy.sh

NAME=root
HOST=host.ub18
CMND="$NAME""@""$HOST"

NOC="\033[0m"
OKC="\033[32m"
ERC="\033[31m"
WAC="\033[33m"
TSC="\033[34m"
PRC="\033[35m"

UPR=NULL

printf '\n\a'

echo -e "============================================= "$PRC"HELLO"$NOC" ==============================================="

printf '\n'

echo -e "=========================================== "$PRC"Connecting"$NOC" ============================================"

echo $CMND
printf '\n'

echo -e "============================================ "$PRC"SYS INFO"$NOC" ============================================="

printf ""$TSC"CPU"$NOC"\t"  && lscpu | grep "Model name"
printf ""$TSC"RAM"$NOC"\t"  && free -h | grep Mem | awk '{printf "total " $2 "\t" "used " $3 "\t" "free " $4 "\n"}'
printf ""$TSC"HDD"$NOC"\t"  && df -HT | grep udev | awk '{printf "total " $3 "\t" "used " $4 "\t" "free " $5 "\t" "type " $2 "\t" $1 "\n"}'
printf ""$TSC"VM"$NOC"\t"   && hostnamectl status | grep "Virtualization" | awk '{printf $2 "\n"}'
printf ""$TSC"NAME"$NOC"\t" && hostname | awk '{printf $1 "\n"}'
printf ""$TSC"IP"$NOC"\t"   && ifconfig | grep "inet " | awk '{printf $2 "\n"}' | grep -v '127.0.0.1'

	UPR=$(cat /proc/uptime | cut -d '.' -f 1)
	if [ $UPR \< 86400 ] #this seconds in 24h
		then
		printf ""$TSC"UPT"$NOC"\t"$ERC""  && uptime -p
	else
		printf ""$NOC""$TSC"UPT"$NOC"\t"  && uptime -p
		fi

printf ""$NOC"\n"

echo -e "========================================== "$PRC"INSTALL APP"$NOC" ============================================"

printf ""$TSC" UPDATE"$NOC"\t"  && apt-get update
printf ""$TSC" Install HTOP"$NOC"\t"  && apt-get install htop
printf ""$TSC" Install DNSutils"$NOC"\t"  && apt-get install dnsutils
printf '\n\a\a\a'

echo -e "========================================== "$PRC"THE END BRO"$NOC" ============================================"

