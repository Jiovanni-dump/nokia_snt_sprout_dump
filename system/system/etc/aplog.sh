#!/bin/sh
export PS4='+{$LINENO:${FUNCNAME[0]}} '
set -x
APLOG_DIR=/data/local/newlog/aplog

mkdir -p /data/local/newlog/aplog/logcats 0777 system system

# Set log files max numnber
# If userdebug and eng version, set max log file larger to record more logs.
# If user version, you can set this prop by log APK with a hide activity.
#if [ $(getprop ro.debuggable) = 1 ]; then
#    if [ $(getprop persist.sys.aplogsettings) = true ]; then
        setprop persist.sys.aplogfiles  1000
#    fi
#fi

# setup log service
if [ $(getprop persist.sys.aplogsettings) = true ]; then
    for svc in kernellog; do
        if [ $(getprop persist.sys.kernellog_enable) = true ]; then
            setprop ctl.start $svc
        else
            setprop ctl.stop $svc
        fi
    done

    if [ $(getprop persist.sys.mainlog_enable) = true ]; then
        setprop ctl.start closechatty
        wait
        setprop ctl.start mainlog
    else
        setprop ctl.stop mainlog
    fi

    if [ $(getprop persist.sys.radiolog_enable) = true ]; then
        setprop ctl.start radiolog
    else
        setprop ctl.stop radiolog
    fi

    if [ $(getprop persist.sys.eventslog_enable) = true ]; then
        setprop ctl.start eventslog
    else
        setprop ctl.stop eventslog
    fi

    for svc in tcpDumplog; do
        if [ $(getprop persist.sys.tcpDumplog_enable) = true ]; then
            setprop ctl.start $svc
        else
            setprop ctl.stop $svc
        fi
    done

#elif [ $(getprop ro.debuggable) = 1 ]; then
#    setprop ctl.start closechatty
#    wait
#    setprop ctl.start mainlog
#    setprop ctl.start radiolog
#    setprop ctl.start eventslog
#    setprop ctl.start kernellog
#    setprop persist.sys.dloadmode.config 1
#    setprop persist.bluetooth.btsnoopenable true

# start log services once,
# for after factoryreset, qfile burn, or upgrade from Android M.
#elif [ -z "$(getprop persist.sys.firstbootfinish)" ]; then
#    setprop ctl.start mainlog
#    setprop ctl.start kernellog
#    wait
#
#    # start a service to auto save and stop the log services
#    setprop ctl.start assalog
#
#    setprop persist.sys.dloadmode.config 0
#else
#    setprop persist.sys.dloadmode.config 0
fi

set +x
