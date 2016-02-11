#!/bin/bash

if [ $# -lt 1 ] ; then
    echo "Usage: "
    echo "     threads_per_process.sh PID | process name [count] "
    echo ""
    echo "Example"
    echo "  PID: 36434 or"
    echo "  process string: NumThreads (this script will do a ps -ef|grep NumThreads to get the PID)" 
    echo "  The last number is the number of times the command will run"
    echo ""
    echo "     threads_per_process.sh 36434 20"
    echo "     threads_per_process.sh 36434 "
    echo "     threads_per_process.sh NumThreads"
    echo "     threads_per_process.sh NumThreads 20"
    echo ""
    exit 1
fi

echo "========================================================"
echo "The number of threads is displayed under the column NLWP"
echo "========================================================"

PROCESS_ID=$1
COLUMNS=140

DELAY=3
if [ $# -gt 1 ] ; then
    DELAY=$2
    shift
fi

DEFAULT_COUNT=1
COUNT=1
if [ $# -gt 1 ] ; then
    COUNT=$2
    DEFAULT_COUNT=0
fi

PATTERN=`echo $1 | sed 's/[0-9]//g'`

if [ ! -z $PATTERN  ] ; then
    # string
    PROCESS_ID=`ps -ef |egrep -v 'grep|threads_per' |grep $1|awk '{print $2}'`
    echo "The PID to lookup is: "$PROCESS_ID
fi

CMD="COLUMNS=$COLUMNS  ps -p $PROCESS_ID   -o pid,%cpu,rss,etime,nlwp,args"
CMD2="COLUMNS=$COLUMNS ps -p $PROCESS_ID h -o pid,%cpu,rss,etime,nlwp,args"

PATTERN=`echo $PROCESS_ID | sed 's/\ /@/g' | sed 's/[0-9]//g'`
n=0
HEADER_COUNT=15
if [ -z $PATTERN ] ; then
    if [ $COUNT -ge 1 ] ; then
        while [ $n -lt $COUNT ] ; do
            PROCESS_ID=`ps -e |awk '{print $1}' | grep $PROCESS_ID`
            if [ -z $PROCESS_ID  ] ; then
                echo "The monitored PID no longer exists. Exiting."
                exit 0;
            fi
            if [ $HEADER_COUNT == 0 ] ; then
                HEADER_COUNT=15
            fi
            if [ $HEADER_COUNT == 15 ]; then
                eval $CMD|awk '{now=strftime("%Y-%m-%d %T  "); print now $0}'
            else
                eval $CMD2|awk '{now=strftime("%Y-%m-%d %T  "); print now $0}'
            fi
            HEADER_COUNT=$(expr $HEADER_COUNT - 1)
            if [ $DEFAULT_COUNT -eq 1 ] ; then
                n=0
            else 
                n=$(expr $n + 1)
            fi
            if [ $n -lt $COUNT ] ; then
                sleep $DELAY
            fi
        done
    fi
else
    echo "The keyword \"$1\" return more than one PID. Please consider constraining the keyword"
fi 

