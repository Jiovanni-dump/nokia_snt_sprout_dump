#!/bin/sh
export PS4='+{$LINENO:${FUNCNAME[0]}} '
set -x
# start modem offline log

adsplog_stat="stopped"
enable_adsp_log=0

Log(){
    log -p d -t adsplog $1
}

# We do not start modem log in user version when system boot.
user=`cat /system/etc/version.conf | grep USER | grep -v -c BLC`
if [ $user -gt 0 ]; then
    echo "this is a user version"
    exit
fi


if [ "$enable_adsp_log" == "0" ]; then
    for i in $(seq 0 9)
    do
        if [ $(getprop persist.sys.aplogsettings) = true -a $(getprop persist.sys.adsplog_enable) = true ]; then
            enable_adsp_log=1
            Log "adsplog is enable"
            break
        else
            sleep 1
        fi
    done
fi

# If enable_adsp_log == 1, start adsp log
if [ "$enable_adsp_log" == "1" ]; then
    Log "try to start adsp offline log"

    setprop "ctl.start" adsplog

fi

set +x
