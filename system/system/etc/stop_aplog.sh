#!/bin/sh

# Add by wangwq14 for stop aplog services.
export PS4='+{$LINENO:${FUNCNAME[0]}} '
set -x
# Let /vendor/bin/sh can use tools in '/system/bin'
export PATH=$PATH:/system/bin

umask 022

APLOG_DIR=/data/local/newlog/aplog

Log(){
    log -p d -t stop_aplog $1
}

Log "Start stop_aplog"

# If log service running, should stop them.
for svc in mainlog mainlog_big radiolog radiolog_big kernellog eventslog eventslog_big modemlog tcpDumplog adsplog; do
    eval ${svc}=$(getprop init.svc.${svc})
    if eval [ "\$$svc" = "running" ]; then
        stop $svc
    fi
done

# wait for stop services done.
wait
Log "Stop log services done"

# remove history log.
#rm -rf $APLOG_DIR/tombstones/*
#rm -rf $APLOG_DIR/bluetooth/*
#rm -rf $APLOG_DIR/anr/*
#rm -rf $APLOG_DIR/gps/*
#rm -rf $APLOG_DIR/recovery/*
#rm -rf $APLOG_DIR/wlan/*
#rm -rf $APLOG_DIR/tcps/*
#rm -rf $APLOG_DIR/logcats/*
#rm -rf $APLOG_DIR/dumpsys/*

#Log "Remove history logs done"

# clean logcat system buffer
logcat_ontim -c
logcat_ontim -b radio -c
logcat_ontim -b events -c
Log "clean logcat buffer done"

#clean anr, recovery, tombstones history files
#rm -f /cache/recovery/*
#rm -f /data/anr/*
#rm -f /data/tombstones/*
#rm -rf /data/tombstones/dsps/*
#rm -rf /data/tombstones/lpass/*
#rm -rf /data/tombstones/modem/*
#rm -rf /data/tombstones/wcnss/*
#Log "clean anr, recovery, tombstones history files done"

wait
#Log "clean anr, recovery, tombstones history files done"
Log "stop_aplog done"

export PS4='+{$LINENO:${FUNCNAME[0]}} '
set +x
