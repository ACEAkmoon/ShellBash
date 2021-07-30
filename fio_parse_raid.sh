#!/bin/bash
# USAGE EXAMPLE: < ./fio_parse_raid.sh RAID_TXT/ext4.txt >

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

if [ -z $1 ]; then
    FILE="RAID_TXT/def.txt"
    echo -e $BL0 "Defaulting to $FILE for testing" $NOC
else
    FILE="$1"
    echo -e $BL1 "Testing in $FILE" $NOC
fi

RETURN="$(cat $FILE | grep "test: (g=0): rw="  | awk '{print $3 "\t" $5 "\t" $11}' | sed s:,::g)"
OUTPUT="$(cat $FILE | grep -A2 "Run status group 0 (all jobs):" | awk '{print $1 "\t" $3}' | sed s:,::g | sed s:group:Speed:g | sed s:TEST::g | sed s:SUCCESS::g)"

NUMB=0
LINE=4
ITER=0
while IFS= read -r line; do
    echo -e $TSC "TEST:" $(( ++NUMB )) $WA0 $line $NOC
    while [ $ITER -lt $LINE ]; do
        sed -n $(( ++ITER ))p <<< "$OUTPUT"
    done
    LINE=$(( LINE + 4 ))
done < <(printf '%s\n' "$RETURN")
