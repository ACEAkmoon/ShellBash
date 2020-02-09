#!/bin/bash
#https://www.cyberciti.biz/faq/bash-while-loop/
TIME=300

while [ $TIME -gt 0 ]
        do
                echo "Time: $TIME"
                TIME=$(( --TIME ))
                sleep 1
        done

curl -s -X POST "https://api.telegram.org/bot1094799241:AAEJNvcAKuS4VvRvwN1ysjQHAT0srbQaCSQ/sendMessage" -F chat_id="843569800" -F text="BITCH! Some hell restarted your PC"

echo ''
echo Well Done!
