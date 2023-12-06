#!bin/sh
LOG_TAG="poweroff_normal"
LOG_NAME="${0}:"

logi ()
{
    /system/bin/log -t $LOG_TAG -p i "$LOG_NAME $@"
}

logi "poweroff_normal--->"
am start -a com.android.internal.intent.action.REQUEST_SHUTDOWN

exit 0
