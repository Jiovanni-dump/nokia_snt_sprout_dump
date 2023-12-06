#!/bin/sh

umask 022
export PS4='+{$LINENO:${FUNCNAME[0]}} '
set -x
APLOG_DIR=/data/local/newlog/aplog

TCPDUMP_LOGFILE=${APLOG_DIR}"/tcpDumplog.pcap"
TCPDUMP_LOGFILE_MAX_SIZE=1048576000
# mv files.x-1 to files.x
mv_files()
{
    if [ -z "$1" ]; then
      echo "No file name!"
      return
    fi

    if [ -z "$2" ]; then
      fileNum=$(getprop persist.sys.aplogfiles)
      if [ $fileNum -gt 0 ]; then
        LAST_FILE=20
      else
        LAST_FILE=5
      fi
    else
      LAST_FILE=$2
    fi

    i=$LAST_FILE
    while [ $i -gt 0 ]; do
      prev=$(($i-1))
      if [ -e "$1.$prev" ]; then
        mv $1.$prev $1.$i
      fi
      i=$(($i-1))
    done

    if [ -e $1 ]; then
      mv $1 $1.1
    fi
}

mv_files $TCPDUMP_LOGFILE
Log "start tcpdump log"
while [ 1 ]
do
    tcpdump -i any -p -vv -s 0 -w $TCPDUMP_LOGFILE
    Log "start tcpdump"
    LOGFILE_size=`stat -c "%s" $TCPDUMP_LOGFILE`
    if [ $LOGFILE_size -gt $TCPDUMP_LOGFILE_MAX_SIZE ]; then
        mv_files $TCPDUMP_LOGFILE
    fi

    sleep 2
done

set +x
