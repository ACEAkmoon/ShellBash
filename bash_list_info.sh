#!/bin/bash
#start: ./bash_list_info.sh

NAME=root
HOST=cloud.gordon.host
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

printf ""$TSC"CPU"$NOC"\t"  && ssh $CMND lscpu | grep "Model name"
printf ""$TSC"RAM"$NOC"\t"  && ssh $CMND free -h | grep Mem | awk '{printf "total " $2 "\t" "used " $3 "\t" "free " $4 "\n"}'
printf ""$TSC"HDD"$NOC"\t"  && ssh $CMND df -HT | grep SITES | awk '{printf "total " $3 "\t" "used " $4 "\t" "free " $5 "\t" "type " $2 "\t" $1 "\n"}'
printf ""$TSC"VM"$NOC"\t"   && ssh $CMND lscpu | grep Virtualization | awk '{printf $2 "\n"}'
printf ""$TSC"NAME"$NOC"\t" && ssh $CMND hostname | awk '{printf $1 "\n"}'
printf ""$TSC"IP"$NOC"\t"   && ssh $CMND ifconfig | grep "inet " | awk '{printf $2 "\n"}'

	UPR=$(ssh $CMND cat /proc/uptime | cut -d '.' -f 1)
	if [ $UPR \< 86400 ] #this seconds in 24h
		then
		printf ""$TSC"UPT"$NOC"\t"$ERC""  && ssh $CMND uptime -p
	else
		printf ""$NOC""$TSC"UPT"$NOC"\t"  && ssh $CMND uptime -p
		fi

printf ""$NOC"\n"

echo -e "========================================== "$PRC"INSTALL APP"$NOC" ============================================"

printf ""$TSC" UPDATE"$NOC"\t"  && ssh $CMND apt-get update
printf ""$TSC" Install HTOP"$NOC"\t"  && ssh $CMND apt-get install htop
printf ""$TSC" Install DNSutils"$NOC"\t"  && ssh $CMND apt-get install dnsutils
printf '\n\a\a\a'

echo -e "========================================== "$PRC"THE END BRO"$NOC" ============================================"

