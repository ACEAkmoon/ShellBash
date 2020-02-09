#!/bin/bash
### BEGIN INIT INFO
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

#https://www.cyberciti.biz/faq/bash-while-loop/
TIME=10

while [ $TIME -gt 0 ]
        do
                echo "Time: $TIME"
                TIME=$(( --TIME ))
                sleep 1
        done

curl -s -X POST "https://api.telegram.org/bot<TOKEN:TOKEN>/sendMessage" -F chat_id="CHAT_ID" -F text="BITCH! Some hell restarted your PC"

echo ''
echo Well Done!
exit 0
