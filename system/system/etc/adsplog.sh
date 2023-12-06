#!/bin/sh

umask 022
export PS4='+{$LINENO:${FUNCNAME[0]}} '
set -x
Log(){
    log -p d -t adsplog $1
}

# User can config modem log by file "/sdcard/log_cfg/cs.cfg"
# System default config file is "/vendor/etc/cs.cfg".
if [ -e /sdcard/log_cfg/cs.cfg ]; then
    setprop "persist.sys.ontim.log.adspcfg" "/sdcard/log_cfg/diag.cfg"
    Log "setprop persist.sys.ontim.log.adspcfg to /sdcard/log_cfg/diag.cfg"
else
    setprop "persist.sys.ontim.log.adspcfg" "/system/etc/diag.cfg"
    Log "setprop persist.sys.ontim.log.adspcfg to /system/etc/diag.cfg"
fi

#mkdir -p /sdcard/diag_logs

setprop "persist.sys.ontim.adsplog.path" "/data/local/newlog/adsplog"
Log "setprop persist.sys.ontim.adsplog.path to data/local/newlog/adsplog"

CFGFILE=$(getprop persist.sys.ontim.log.adspcfg)
LOGFILE=$(getprop persist.sys.ontim.adsplog.path)

Log "start diag_adsplog"
Log "CFGFILE=$CFGFILE"
Log "LOGFILE=$LOGFILE"

#kill the diag_mdlog process at first
/system/bin/diag_mdlog_system -k -c
# -s set the single log size in MB
/system/bin/diag_mdlog_system -s 100 -n 20 -f $CFGFILE -o $LOGFILE

# scripty will hold in the last line, should never come here.
Log "start diag_adsplog done, exit scripty"

export PS4='+{$LINENO:${FUNCNAME[0]}} '
set +x
