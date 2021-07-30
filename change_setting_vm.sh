#!/bin/bash
#start: ssh admin95@192.168.33.06 'bash -s' < change_setting_vm.sh
#start: ssh -i ~/.ssh/id_rsa_you.rsa.key admin95@you.host 'bash -s' < change_setting_vm.sh
set echo off
echo ''
NOC="\033[0m"
OKC="\033[32m"
ERC="\033[31m"
WAC="\033[33m"
TSC="\033[34m"
PRC="\033[35m"
echo ''
# leave uncommented when sending over SSH
NAME="dbmXX-name-v"
SBNT=35
ADDR=215
MASK=24
IPAD=192.168.
# uncomment when running locally
echo -e '\n'$WAC"Enter name: "$NOC && read NAME
echo -e '\n'$WAC"Enter subnet $IPAD$ERC'XX'$NOC$WAC.0: "$NOC && read -n 3 SBNT
echo -e '\n'$WAC"Enter address $IPAD$SBNT.$ERC'XX'$NOC$WAC: "$NOC && read -n 15 ADDR
echo -e '\n'$WAC"Enter mask $IPAD$SBNT.$ADDR/$ERC'XX'$NOC: "$NOC && read -n 3 MASK
echo ''
echo -e "Name VM is - "$OKC $NAME $NOC
echo -e "Subnet  is - "$OKC $SBNT $NOC
echo -e "Address is - "$OKC $ADDR $NOC
echo -e "Mask    is - "$OKC $MASK $NOC
echo ''
userinput=""
echo -e $WAC"Press 'ESC' key to quit, or 'C' to continue"$NOC
while read -r -n1 key
	do
	if [[ $key == $'\e' ]]; then 
		break;
	elif [[ $key == c ]]; then
		echo -e "============================= "$PRC"Change TCP-interfaces"$NOC" ============================="
		sed -i "s/address *.*.*.*\/*/address $IPAD$SBNT.$ADDR\/$MASK/" /etc/network/interfaces
		sed -i "s/gateway *.*.*.*/gateway 192.168.$SBNT.250/" /etc/network/interfaces
		sed -i "s/dns-nameservers *.*.*.* *.*.*.*/dns-nameservers $IPAD$SBNT.247 $IPAD$SBNT.248/" /etc/network/interfaces
		sed -n 13,16p /etc/network/interfaces | awk '{ printf $1 "\t" $2 "\t" $3 "\n" }' | sed '/#/d'
		echo ''
		echo -e "============================= "$PRC"Change HostName"$NOC" ==================================="
		hostnamectl set-hostname $NAME
		hostname 
		echo ''
		echo -e "============================= "$PRC"Change Hosts"$NOC" ======================================"
		sed -i "2s/$IPAD*.5*/$IPAD$SBNT.$ADDR\t$NAME\t$NAME/" /etc/hosts
		sed -n 2p /etc/hosts
		echo ''
		echo -e "============================= "$PRC"Change Networks"$NOC" ==================================="
		sed -i "s/$IPAD*.0/$IPAD$SBNT.0/" /etc/networks
		cat /etc/networks | grep localnet
		echo ''
		echo -e "============================= "$PRC"Change DNS"$NOC" ========================================"
		sed -i "s/$IPAD*.247/$IPAD$SBNT.247/" /etc/resolv.conf
		sed -i "s/$IPAD*.248/$IPAD$SBNT.248/" /etc/resolv.conf
		cat /etc/resolv.conf | grep nameserver
		echo ''
		echo -e "============================= "$PRC"Change HostName in daemon Collectd"$NOC" ================"
		sed -i "s/Hostname \"deb8\"/Hostname \"$NAME\"/" /etc/collectd/collectd.conf
		sed -i "s/Hostname \"deb9\"/Hostname \"$NAME\"/" /etc/collectd/collectd.conf
		sed -i "s/Hostname \"deb10\"/Hostname \"$NAME\"/" /etc/collectd/collectd.conf
#		sed -i '/Hostname/d' /etc/collectd/collectd.conf
#		sed -i '1 i Hostname "$NAME"' /etc/collectd/collectd.conf
		cat /etc/collectd/collectd.conf | grep Hostname
		echo ''
		echo -e $OKC "Well Done. Press 'ESC' key to quit" $NOC
	fi
	printf $TSC"\nYou have typed : $userinput\n"$NOC
	userinput+=$key
done
exit 0