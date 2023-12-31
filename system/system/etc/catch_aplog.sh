#!/bin/sh

# Add by wangwq14@zuk
# This shell catch system cached log info, system prop, dumpsys.
# The logs will be saved at '/sdcard/log' as a tar, size less than 10M.

# Let /vendor/bin/sh can use tools in '/system/bin'
export PATH=$PATH:/system/bin

umask 022

Log(){
    log -p d -t catch_aplog $1
}

APLOG_DIR=/data/local/newlog/aplog

BUGREPORT_DIR=/data/user_de/0/com.android.shell/files/bugreports
# collect bugreport zip log
if [ $(getprop persist.sys.catch.bugreport) = true ]; then
    Log "Start collecting bugreport logs"
    rm -f $BUGREPORT_DIR/*.tmp
    setprop persist.sys.bugreport.state 1
    setprop ctl.stop bugreport
    sleep 1
    Log "Begin take a bugreport"
    am bug-report
    sleep 5
    while :
    do
        #Log "search tmp files in bugreports folder"
        #files=`ls $BUGREPORT_DIR/*.tmp 2> /dev/null | wc -l`
        #if [ $files -ne 0 ]; then
        #sleep 1
        #Log ".tmp files is exists"
        #else
        Log ".tmp files is not exists,then copy bugreports to aplog"
        cp $BUGREPORT_DIR/*  $APLOG_DIR/bugreports
        break
        fi
    done
    setprop persist.sys.bugreport.state 0
    Log "collecting bugreport logs done"
    rm -rf $BUGREPORT_DIR/*
fi

if false; then
CollectIpinfo(){
    IP_RULES_LOGFILE=${CURLOG_DIR}"/ip_info.txt"

    Log "start to collect ipinfo"
    date > $IP_RULES_LOGFILE

    # iptables -L
    echo "" >> $IP_RULES_LOGFILE
    echo "*-*-*—*-*-*-*—* iptables -L *-*-*—*-*-*-*—*" >> $IP_RULES_LOGFILE
    /system/bin/iptables -L >> $IP_RULES_LOGFILE

    # iptables -S
    echo "" >> $IP_RULES_LOGFILE
    echo "*-*-*—*-*-*-*—* iptables -S *-*-*—*-*-*-*—*" >> $IP_RULES_LOGFILE
    /system/bin/iptables -S >> $IP_RULES_LOGFILE

    #ip rule
    echo "" >> $IP_RULES_LOGFILE
    echo "*-*-*—*-*-*-*—* ip rule *-*-*—*-*-*-*—*" >> $IP_RULES_LOGFILE
    /system/bin/ip rule >> $IP_RULES_LOGFILE

    #ip route
    echo "" >> $IP_RULES_LOGFILE
    echo "*-*-*—*-*-*-*—* ip route *-*-*—*-*-*-*—*" >> $IP_RULES_LOGFILE
    /system/bin/ip route list table 0 >> $IP_RULES_LOGFILE

    Log "end collection info"
}

APLOG_DIR=/data/local/newlog/aplog
CURLOG_DIR=/data/local/newlog/curlog
DUMPSYS_DIR=/data/local/newlog/aplog/dumpsys
TMLOG_DIR=/persist/testmode
GPSLOG_DIR=/data/gps/log
ANR_DIR=/data/anr
RECOVERY_DIR=/cache/recovery
CRASH_DIR=/data/tombstones
BT_DIR=/data/misc/bluedroid
BT_ETC_DIR=/system/etc/bluetooth

Log "Start catch_aplog"

mkdir -p $CURLOG_DIR

# mkdir for dumpsys, this dir will lable by media_rw_data_file
# to make dumpsys can write log to.
mkdir -p $CURLOG_DIR/dumpsys

cat /proc/interrupts > $CURLOG_DIR/interrupts.txt
cat /proc/meminfo > $CURLOG_DIR/meminfo.txt
cat /d/ion/heaps/system > $CURLOG_DIR/ion_system.txt
getprop > $CURLOG_DIR/prop.txt

[ -e /system/build.prop ] && cp /system/build.prop $CURLOG_DIR/
[ -e /system/etc/version.conf ] && cp /system/etc/version.conf $CURLOG_DIR/
[ -d $GPSLOG_DIR ] && cp -a $GPSLOG_DIR/ $CURLOG_DIR/gps
[ -d $ANR_DIR ] &&  cp -a $ANR_DIR/ $CURLOG_DIR/anr
[ -d $RECOVERY_DIR ] && cp -a $RECOVERY_DIR/ $CURLOG_DIR/recovery
[ -d $CRASH_DIR ] && cp -a $CRASH_DIR/ $CURLOG_DIR/tombstones
[ -d $BT_DIR ] && cp -a $BT_DIR/ $CURLOG_DIR/bluetooth
[ -d $BT_ETC_DIR ] && cp -a $BT_ETC_DIR/ $CURLOG_DIR/bluetooth
[ -e $TMLOG_DIR ] && cp -a $TMLOG_DIR $CURLOG_DIR

[ -d $DUMPSYS_DIR ] && cp -a $DUMPSYS_DIR/ $CURLOG_DIR/dumpsys

logcat_ontim -d -b main -b system -b crash -v threadtime -f $CURLOG_DIR/logcat
logcat_ontim -d -b radio -v threadtime -f $CURLOG_DIR/radio
logcat_ontim -d -b events -v threadtime -f $CURLOG_DIR/events
Log "collecting logcat buffer logs done"

KERNEL_LOGFILE=$CURLOG_DIR/kernellog
date  >> $KERNEL_LOGFILE
echo "" >> $KERNEL_LOGFILE
dmesg >> $KERNEL_LOGFILE
[ -e $APLOG_DIR/kernellog ] && cp $APLOG_DIR/kernellog $CURLOG_DIR/kernellog.r
Log "collecting kernel logs done"

TCPDUMP_LOGFILE=$CURLOG_DIR/tcpDumplog.pcap
tcpdump -i any -nnXSs 0 -w $TCPDUMP_LOGFILE
[ -e $APLOG_DIR/tcpDumplog.pcap ] && cp $APLOG_DIR/tcpDumplog.pcap $CURLOG_DIR/tcpDumplog.pcap.r
Log "collecting tcpDump logs done"

# add for settings info.
[ -e /data/system/users/0/settings_global.xml ] && cp /data/system/users/0/settings_global.xml $CURLOG_DIR/
[ -e /data/system/users/0/settings_secure.xml ] && cp /data/system/users/0/settings_secure.xml $CURLOG_DIR/
[ -e /data/system/users/0/settings_system.xml ] && cp /data/system/users/0/settings_system.xml $CURLOG_DIR/
Log "Collecting settings info done"

if [ -e /d/le_rkm ]; then
    date > $LASTKMSG_LOGFILE
    echo "" >> $LASTKMSG_LOGFILE
    cat /d/le_rkm/last_kmsg >> $CURLOG_DIR/last_kmsg
    Log "Collecting last_kmsg done"

    data > $LKMSG_LOGFILE
    echo "" >> $LKMSG_LOGFILE
    cat /d/le_rkm/lk_mesg > $CURLOG_DIR/lk_mesg
    Log "Collecting lk_mesg done"

    data > $XBLMSG_LOGFILE
    echo "" >> $XBLMSG_LOGFILE
    cat /d/le_rkm/sbl1_mesg > $CURLOG_DIR/sbl1_mesg
    Log "Collecting sbl1_mesg done"
fi

# add for reboot log need by bsp
PSTORE_DIR=/sys/fs/pstore
[ -d $PSTORE_DIR ] && cp -a $PSTORE_DIR/ $CURLOG_DIR/pstore

BL_LOGFILE=$CURLOG_DIR/BL
date  >> $BL_LOGFILE
echo "" >> $BL_LOGFILE
cat /dev/block/bootdevice/by-name/logfs >> $BL_LOGFILE
Log "Collecting bootdevice logs done"

#TZ_LOGFILE=$CURLOG_DIR/tzlog
#date  >> $TZ_LOGFILE
#echo "" >> $TZ_LOGFILE
#cat /d/tzdbg/log >> $TZ_LOGFILE
#Log "collecting tzlog done"

#QSEE_LOGFILE=$CURLOG_DIR/qseelog
#date  >> $QSEE_LOGFILE
#echo "" >> $QSEE_LOGFILE
#cat /d/tzdbg/qsee_log >> $QSEE_LOGFILE
#Log "collecting qsee_log done"

df -h > $CURLOG_DIR/df.txt
Log "collecting df done"

ps -A > $CURLOG_DIR/ps.txt
Log "collecting ps done"
# get ipinfo for modem need
CollectIpinfo

## record dumpsys
#Log "Start collecting dumpsys logs"
#dumpsys activity -a > $CURLOG_DIR/dumpsys_activity
#dumpsys netstats --full --uid --tag > $CURLOG_DIR/dumpsys_netstats

#for dumpsyslog in alarm appops package location battery batterystats power audio window notification meminfo display media.audio_policy cpuinfo sensorservice deviceidle; do
#    dumpsys $dumpsyslog > $CURLOG_DIR/dumpsys_$dumpsyslog
#done
#Log "collecting dumpsys logs done"
#wait

mkdir -p /sdcard/log
Log "make tar package start"
FILENAME=curlog_$(date +%Y_%m_%d_%H_%M_%S)
tar zcf /sdcard/log/${FILENAME}.tgz -C $CURLOG_DIR/../ curlog
wait
Log "make tar package done"

rm -rf $CURLOG_DIR
Log "remove currunt history log done"

#clean anr, recovery, tombstones history files
#rm -f /cache/recovery/*
#rm -f /data/anr/*
#rm -f /data/tombstones/*
#rm -rf /data/tombstones/dsps/*
#rm -rf /data/tombstones/lpass/*
#rm -rf /data/tombstones/modem/*
#rm -rf /data/tombstones/wcnss/*
#Log "clean anr, tombstones history files done"
Log "catch_aplog done, tar package is ${FILENAME}.tgz"
fi
