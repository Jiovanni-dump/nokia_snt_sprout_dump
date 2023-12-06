#!/bin/sh

# Add by wangwq14 for Clean aplogs
export PS4='+{$LINENO:${FUNCNAME[0]}} '
set -x
# Let /vendor/bin/sh can use tools in '/system/bin'
export PATH=$PATH:/system/bin

umask 022

APLOG_DIR=/data/local/newlog/aplog
CURLOG_DIR=/data/local/newlog/curlog

Log(){
    log -p d -t clean_aplog $1
}

Log "Start clean_aplog"

setprop persist.sys.cleanlog.state 1

# If log service running, should stop them before remove log files, and then restart.
for svc in mainlog radiolog kernellog eventslog modemlog adsplog tcpDumplog; do
    eval ${svc}=$(getprop init.svc.${svc})
    if eval [ "\$$svc" = "running" ]; then
        stop $svc
    fi
done

# wait for stop services done.
wait
Log "Stop log services done"

# remove history log.
rm -rf $APLOG_DIR/tombstones/*
rm -rf $APLOG_DIR/bluetooth/*
rm -rf $APLOG_DIR/anr/*
rm -rf $APLOG_DIR/gps/*
rm -rf $APLOG_DIR/recovery/*
rm -rf $APLOG_DIR/wlan/*
rm -rf $APLOG_DIR/tcps/*
rm -rf $APLOG_DIR/logcats/*
rm -rf $APLOG_DIR/dumpsys/*
rm -f  $APLOG_DIR/*
rm -f  $CURLOG_DIR/*
rm -rf $APLOG_DIR/bugreports/*


# clean logcat system buffer
logcat_ontim -c
logcat_ontim -b radio -c
logcat_ontim -b events -c
Log "clean logcat buffer done"

#clean anr, recovery, tombstones history files
#rm -f /cache/recovery/*
rm -f /data/anr/*
rm -f /data/tombstones/*
rm -rf /data/tombstones/dsps/*
rm -rf /data/tombstones/lpass/*
rm -rf /data/tombstones/modem/*
rm -rf /data/tombstones/wcnss/*
Log "clean anr, recovery, tombstones history files done"

rm -rf /data/local/newlog/mdlog/*
rm -rf /data/local/newlog/adsplog/*

for svc in mainlog radiolog kernellog eventslog modemlog adsplog tcpDumplog; do
    if eval [ "\$$svc" = "running" ]; then
        start $svc
    fi
done

# wait for start services done
wait
setprop persist.sys.cleanlog.state 0
Log "Restart log services done"
Log "clean_aplog done"

set +x

