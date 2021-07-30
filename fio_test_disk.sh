#!/bin/bash

# Кольорова палітра
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

# Скільки разів запускати кожен тест.
# При повторі 500 разів більш точний результат. 
# Так як похибка показників між 5 і 100 сутєва, а між 100 і 500 не вагома.
LOOPS=500

# Розмір кожного тесту, кратний 32, рекомендованим для тестів Q32 для отримання найбільш точних результатів.
# Рекомендовані налаштування розміру для різних дисків:
# (SATA) SSD: 1024 (за замовчуванням)
# (ЛЮБИЙ) HDD: 256
# (High End NVME) SSD: 4096
# (Low-Mid End NVME) SSD: 1024 (за замовчуванням)
SIZE=256

# Встановіть, чи слід писати нулі або випадкові числа для тестового файлу 
# (випадкове значення за замовчуванням і для fio, і для кристалдискмарка); 
# Тести dd зазвичай пишуть лише нулі, тому може бути різниця в швидкості.
WRITEZERO=0 

QSIZE=$(($SIZE / 32)) # Розмір тестів Q32Seq
SIZE+=m
QSIZE+=m

# Під час запуску скрипта можна вказувати директорію тестування
# Примір: ./hdd_test.sh /hddtest/
if [ -z $1 ]; then
    TARGET=$HOME
    echo "Defaulting to $TARGET for testing"
else
    TARGET="$1"
    echo "Testing in $TARGET"
fi

DRIVE=$(df $TARGET | grep /dev | cut -d/ -f3 | cut -d" " -f1 | rev | cut -c 2- | rev)
DRIVEMODEL=$(cat /sys/block/$DRIVE/device/model)
DRIVESIZE=$(($(cat /sys/block/$DRIVE/size)*512/1024/1024/1024))GB

echo -e "Configuration: Size:$ERC$SIZE$NOC Loops:$ERC$LOOPS$NOC Write Only Zeroes:$ERC$WRITEZERO$NOC
Running Benchmark on: $OKC/dev/$DRIVE$NOC, $DRIVEMODEL ($OKC$DRIVESIZE$NOC), please wait...
"

# Для належної роботи потрібно встановити fio
# sudo apt install fio
fio --loops=$LOOPS --size=$SIZE --filename=$TARGET/.fiomark.tmp --stonewall --ioengine=libaio --direct=1 --zero_buffers=$WRITEZERO --output-format=json \
  --name=Bufread --loops=1 --bs=$SIZE --iodepth=1 --numjobs=1 --rw=readwrite \
  --name=Seqread --bs=$SIZE --iodepth=1 --numjobs=1 --rw=read \
  --name=Seqwrite --bs=$SIZE --iodepth=1 --numjobs=1 --rw=write \
  --name=SeqQ32T1read --bs=$QSIZE --iodepth=32 --numjobs=1 --rw=read \
  --name=SeqQ32T1write --bs=$QSIZE --iodepth=32 --numjobs=1 --rw=write > $TARGET/.fiomark.txt

fio --loops=$LOOPS --size=512k --filename=$TARGET/.fiomark-512k.tmp --stonewall --ioengine=libaio --direct=1 --zero_buffers=$WRITEZERO --output-format=json \
  --name=512kread --bs=512k --iodepth=1 --numjobs=1 --rw=read \
  --name=512kwrite --bs=512k --iodepth=1 --numjobs=1 --rw=write > $TARGET/.fiomark-512k.txt

fio --loops=$LOOPS --size=4k --filename=$TARGET/.fiomark-4k.tmp --stonewall --ioengine=libaio --direct=1 --zero_buffers=$WRITEZERO --output-format=json \
  --name=4kread --bs=4k --iodepth=1 --numjobs=1 --rw=randread \
  --name=4kwrite --bs=4k --iodepth=1 --numjobs=1 --rw=randwrite \
  --name=4kQ32T1read --bs=4k --iodepth=32 --numjobs=1 --rw=randread \
  --name=4kQ32T1write --bs=4k --iodepth=32 --numjobs=1 --rw=randwrite \
  --name=4kQ8T8read --bs=4k --iodepth=8 --numjobs=8 --rw=randread \
  --name=4kQ8T8write --bs=4k --iodepth=8 --numjobs=8 --rw=randwrite > $TARGET/.fiomark-4k.txt

SEQR="$(($(cat $TARGET/.fiomark.txt | grep -A15 '"name" : "Seqread"' | grep bw_bytes | cut -d: -f2 | sed s:,::g)/1024/1024))MB/s IOPS=$(cat $TARGET/.fiomark.txt | grep -A15 '"name" : "Seqread"' | grep -m1 iops | cut -d: -f2 | cut -d. -f1 | sed 's: ::g')"
SEQW="$(($(cat $TARGET/.fiomark.txt | grep -A80 '"name" : "Seqwrite"' | grep bw_bytes | sed '2!d' | cut -d: -f2 | sed s:,::g)/1024/1024))MB/s IOPS=$(cat $TARGET/.fiomark.txt | grep -A80 '"name" : "Seqwrite"' | grep iops | sed '7!d' | cut -d: -f2 | cut -d. -f1 | sed 's: ::g')"
F12KR="$(($(cat $TARGET/.fiomark-512k.txt | grep -A15 '"name" : "512kread"' | grep bw_bytes | cut -d: -f2 | sed s:,::g)/1024/1024))MB/s IOPS=$(cat $TARGET/.fiomark-512k.txt | grep -A15 '"name" : "512kread"' | grep -m1 iops | cut -d: -f2 | cut -d. -f1 | sed 's: ::g')"
F12KW="$(($(cat $TARGET/.fiomark-512k.txt | grep -A80 '"name" : "512kwrite"' | grep bw_bytes | sed '2!d' | cut -d: -f2 | sed s:,::g)/1024/1024))MB/s IOPS=$(cat $TARGET/.fiomark-512k.txt | grep -A80 '"name" : "512kwrite"' | grep iops | sed '7!d' | cut -d: -f2 | cut -d. -f1 | sed 's: ::g')"
SEQ32R="$(($(cat $TARGET/.fiomark.txt | grep -A15 '"name" : "SeqQ32T1read"' | grep bw_bytes | cut -d: -f2 | sed s:,::g)/1024/1024))MB/s IOPS=$(cat $TARGET/.fiomark.txt | grep -A15 '"name" : "SeqQ32T1read"' | grep -m1 iops | cut -d: -f2 | cut -d. -f1 | sed 's: ::g')"
SEQ32W="$(($(cat $TARGET/.fiomark.txt | grep -A80 '"name" : "SeqQ32T1write"' | grep bw_bytes | sed '2!d' | cut -d: -f2 | sed s:,::g)/1024/1024))MB/s IOPS=$(cat $TARGET/.fiomark.txt | grep -A80 '"name" : "SeqQ32T1write"' | grep iops | sed '7!d' | cut -d: -f2 | cut -d. -f1 | sed 's: ::g')"
FKR="$(($(cat $TARGET/.fiomark-4k.txt | grep -A15 '"name" : "4kread"' | grep bw_bytes | cut -d: -f2 | sed s:,::g)/1024/1024))MB/s IOPS=$(cat $TARGET/.fiomark-4k.txt | grep -A15 '"name" : "4kread"' | grep -m1 iops | cut -d: -f2 | cut -d. -f1 | sed 's: ::g')"
FKW="$(($(cat $TARGET/.fiomark-4k.txt | grep -A80 '"name" : "4kwrite"' | grep bw_bytes | sed '2!d' | cut -d: -f2 | sed s:,::g)/1024/1024))MB/s IOPS=$(cat $TARGET/.fiomark-4k.txt | grep -A80 '"name" : "4kwrite"' | grep iops | sed '7!d' | cut -d: -f2 | cut -d. -f1 | sed 's: ::g')"
FK32R="$(($(cat $TARGET/.fiomark-4k.txt | grep -A15 '"name" : "4kQ32T1read"' | grep bw_bytes | cut -d: -f2 | sed s:,::g)/1024/1024))MB/s IOPS=$(cat $TARGET/.fiomark-4k.txt | grep -A15 '"name" : "4kQ32T1read"' | grep -m1 iops | cut -d: -f2 | cut -d. -f1 | sed 's: ::g')"
FK32W="$(($(cat $TARGET/.fiomark-4k.txt | grep -A80 '"name" : "4kQ32T1write"' | grep bw_bytes | sed '2!d' | cut -d: -f2 | sed s:,::g)/1024/1024))MB/s IOPS=$(cat $TARGET/.fiomark-4k.txt | grep -A80 '"name" : "4kQ32T1write"' | grep iops | sed '7!d' | cut -d: -f2 | cut -d. -f1 | sed 's: ::g')"
FK8R="$(($(cat $TARGET/.fiomark-4k.txt | grep -A15 '"name" : "4kQ8T8read"' | grep bw_bytes | sed 's/        "bw_bytes" : //g' | sed 's:,::g' | awk '{ SUM += $1} END { print SUM }')/1024/1024))MB/s IOPS=$(cat $TARGET/.fiomark-4k.txt | grep -A15 '"name" : "4kQ8T8read"' | grep iops | sed 's/        "iops" : //g' | sed 's:,::g' | awk '{ SUM += $1} END { print SUM }' | cut -d. -f1)"
FK8W="$(($(cat $TARGET/.fiomark-4k.txt | grep -A80 '"name" : "4kQ8T8write"' | grep bw_bytes | sed 's/        "bw_bytes" : //g' | sed 's:,::g' | awk '{ SUM += $1} END { print SUM }')/1024/1024))MB/s IOPS=$(cat $TARGET/.fiomark-4k.txt | grep -A80 '"name" : "4kQ8T8write"' | grep '"iops" '| sed 's/        "iops" : //g' | sed 's:,::g' | awk '{ SUM += $1} END { print SUM }' | cut -d. -f1)"

echo -e "
Results from /dev/$DRIVE, $DRIVEMODEL ($DRIVESIZE):  
$WA0
Sequential Read: $SEQR
Sequential Write: $SEQW
$OKC
512KB Read: $F12KR
512KB Write: $F12KW
$BL0
Sequential Q32T1 Read: $SEQ32R
Sequential Q32T1 Write: $SEQ32W
$BL1
4KB Q8T8 Read: $FK8R
4KB Q8T8 Write: $FK8W
$WA1
4KB Q32T1 Read: $FK32R
4KB Q32T1 Write: $FK32W
$PUR
4KB Q1T1 Read: $FKR
4KB Q1T1 Write: $FKW
$NOC
"

rm "$TARGET/.fiomark.txt" "$TARGET/.fiomark-512k.txt" "$TARGET/.fiomark-4k.txt"
rm "$TARGET/.fiomark.tmp" "$TARGET/.fiomark-512k.tmp" "$TARGET/.fiomark-4k.tmp"
