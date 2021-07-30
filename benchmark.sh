#!/bin/bash
ext_ip=$(curl -s ipinfo.io/ip)
proto="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"
# remove the protocol
url="$(echo $1 |awk -F '//' '{print $2}')"
# extract the host
host="$(echo $1|awk -F "//" '{print $2}'|awk -F "/" '{print $1}' |awk -F ":" '{print $1}')"
# by request - try to extract the port
ext_port="$(echo $1 |awk -F ":" '{print $3}'|awk -F "/" '{print $1 }')"
# extract the path (if any)
path="$(echo $url | grep / | cut -d/ -f2-)"
# extract the IP
ping="$(echo $2)"
ip=$(echo $3)
# extract the IP\URL
traceroute="$(echo $4)"
package=$(echo $5)
tr_port=$(echo $6)
ip_url=$(echo $7)

### DEBUG ###
#echo "URL: $url"
#echo "PATH: $path"
#echo "HOST: $host"
#echo "PORT: $ext_port"
#echo "PROTO: $proto"
#echo "ping: $ping"
#echo "traceroute: $traceroute"

echo -e "\n-----------------------CHECK IF DOMAIN EXIST----------------------"

if [ -n "$host" ];
then
	nslookup $host |grep -v 127.0.0.1
else 
	echo "host not defined"
fi

echo -e "\n-----------------------CHECK IF PORT IS OPEN----------------------"
if [ -n "$ext_port" ];
then
nmap -p $ext_port $host
elif [ "$proto" == "https://" ];
then
nmap -p 443 $host
else
nmap -p 80 $host
fi

if [ "$ping" == "true" ];
then
	echo -e "\n-----------------------ICPM PING HOST CHECK-----------------------"
	ping -n -c 10 -s 1000 -W 1 $ip
fi

if [ "$traceroute" == "true" ];
then
	echo -e "\n-----------------------ICPM TRACEROUTE HOST CHECK-----------------"
	traceroute $package -p $tr_port -w 1 -n $ip_url
fi

echo -e "\n-----------------------CURL BENCHMARK-----------------------------"
if [ -n "$ext_port" ];
then
echo "URL: $proto$host:$ext_port/$path"
	curl --connect-timeout 20 -w "\n    http_code:  %{http_code}\n    time_namelookup:  %{time_namelookup}\n    time_connect:  %{time_connect}\n    time_appconnect:  %{time_appconnect}\n    time_pretransfer:  %{time_pretransfer}\n    time_redirect:  %{time_redirect}\n    time_starttransfer:  %{time_starttransfer}\n    ----------\n    time_total:  %{time_total}\n" -o /dev/null -s $proto$host:$ext_port/$path
else
echo "URL: $proto$host/$path"
	curl --connect-timeout 20 -w "\n    http_code:  %{http_code}\n    time_namelookup:  %{time_namelookup}\n    time_connect:  %{time_connect}\n    time_appconnect:  %{time_appconnect}\n    time_pretransfer:  %{time_pretransfer}\n    time_redirect:  %{time_redirect}\n    time_starttransfer:  %{time_starttransfer}\n    ----------\n    time_total:  %{time_total}\n" -o /dev/null -s $proto$host/$path
fi

echo -e "\n-----------------------APACHE BENCHMARK---------------------------"
echo -e "Test is URL: $proto$host/$path"
ab -n 10 -k -H "User-Agent: Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.13) Gecko/20101206 Ubuntu/10.10 (maverick) Chrome/85.0.4183.121" $proto$host/$path

echo -e "\n-----------------------EXTERNAL IP--------------------------------"
echo "BOX EXT IP IS: $ext_ip"
exit 0;
