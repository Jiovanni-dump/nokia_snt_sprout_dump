#!/bin/sh
export PS4='+{$LINENO:${FUNCNAME[0]}} '
set -x
# start modem offline log

mdmlog_stat="stopped"
enable_mdm_log=0

Log(){
    log -p d -t modemlog_setup $1
}
# We do not start modem log in user version when system boot.
user=`cat /system/etc/version.conf | grep USER | grep -v -c BLC`
if [ $user -gt 0 ]; then
    echo "this is a user version"
    exit
fi

if [ $(getprop persist.sys.modemlog2G_enable) = true -o $(getprop persist.sys.modemlog10G_enable) = true -o $(getprop persist.sys.modemlog64G_enable) = true ]; then
    Log "start modem log 200"
    modemlog_enable=true;
fi
modemlog_enable=$modemlog_enable
Log "modemlog_enable=$modemlog_enable"

if [ "$enable_mdm_log" == "0" ]; then
    for i in $(seq 0 9)
    do
        if [ $(getprop persist.sys.aplogsettings) = true -a  $modemlog_enable = true ]; then
            enable_mdm_log=1
            Log "modemlog is enable"
            break
        else
            sleep 1
        fi
    done
fi

# If enable_mdm_log == 1, start modem log
if [ "$enable_mdm_log" == "1" ]; then
    Log "try to start modem offline log"

    setprop "ctl.start" modemlog

fi

set +x