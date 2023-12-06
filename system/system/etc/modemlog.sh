#!/bin/sh

umask 022
export PS4='+{$LINENO:${FUNCNAME[0]}} '
set -x
Log(){
    log -p d -t modemlog $1
}

# User can config modem log by file "/sdcard/log_cfg/cs.cfg"
# System default config file is "/vendor/etc/cs.cfg".
if [ -e /sdcard/log_cfg/cs.cfg ]; then
    setprop "persist.sys.ontim.log.qxdmcfg" "/sdcard/log_cfg/cs.cfg"
    Log "setprop persist.sys.ontim.log.qxdmcfg to /sdcard/log_cfg/cs.cfg"
else
    setprop "persist.sys.ontim.log.qxdmcfg" "/system/etc/cs.cfg"
    Log "setprop persist.sys.ontim.log.qxdmcfg to /system/etc/cs.cfg"
fi

#mkdir -p /data/local/mdlog

setprop "persist.sys.ontim.modemlog.path" "/data/local/newlog/mdlog"
Log "setprop persist.sys.ontim.modemlog.path to /data/local/newlog/mdlog"

CFGFILE=$(getprop persist.sys.ontim.log.qxdmcfg)
LOGFILE=$(getprop persist.sys.ontim.modemlog.path)
MODEMLOG2G=$(getprop persist.sys.modemlog2G_enable)
MODEMLOG10G=$(getprop persist.sys.modemlog10G_enable)
MODEMLOG64G=$(getprop persist.sys.modemlog64G_enable)

Log "start diag_mdlog"
Log "CFGFILE=$CFGFILE"
Log "LOGFILE=$LOGFILE"
Log "MODEMLOG2G=$MODEMLOG2G"
Log "MODEMLOG10G=$MODEMLOG10G"
Log "MODEMLOG64G=$MODEMLOG64G"

#kill the diag_mdlog process at first
/system/bin/diag_mdlog_system -k -c
# -s set the single log size in MB
if [ $MODEMLOG2G = true ]; then
    /system/bin/diag_mdlog_system -s 100 -n 20 -f $CFGFILE -o $LOGFILE
elif [ $MODEMLOG10G = true ]; then
Log "start diag_mdlog MODEMLOG10G"
    /system/bin/diag_mdlog_system -s 100 -n 100 -f $CFGFILE -o $LOGFILE
elif [ $MODEMLOG64G = true ]; then
    /system/bin/diag_mdlog_system -s 100 -n 600 -f $CFGFILE -o $LOGFILE
fi

# scripty will hold in the last line, should never come here.
Log "start diag_mdlog done, exit scripty"

export PS4='+{$LINENO:${FUNCNAME[0]}} '
set +x
