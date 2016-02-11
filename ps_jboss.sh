#!/bin/bash
# by claudio@claudius.com.br

echo "This script uses sudo to analyze ports and pids"
echo

# JBoss 5 detector
ps -ef  | grep org.jboss.Main|grep -v grep |
while read psline; do 
  pid=`echo $psline | awk '{print $2}'` 
  prc_name="EAP 5 - "`echo $psline | awk  -F ' -c ' '{ print $2}' `
  info_prc=`ps -o nlwp,etime,rss h $pid`
  nlwp=`echo $info_prc|awk '{print $1}'`
  etime=`echo $info_prc|awk '{print $2}'`
  rss=`echo $info_prc|awk '{print $3}'`
  echo "$pid - $prc_name ($nlwp threads, elapsed time $etime, RSS memory $(($rss/1024)) MB)"
  jinfo $pid 2>&1|grep -E '^jboss.server.log.dir|^jboss.home.dir'| sort|awk '{print "\t"$3}'
  echo ""
  sudo netstat -antpuew | grep -E "$pid/java" | grep LISTEN | awk '{print "\t"$1" "$4}' | sort
  echo ""
done  


# JBossAS 7 (EAP 6) detector
prcs=`ps -ef|grep '\-D\['|grep -v grep| awk '{print $2}'`
if [[ ! $prcs  ]] ; then
  printf "\tNao ha processos jboss em execucao\n\n"
  exit 0
fi
jps_cmd=`dirname $(ps -ef|grep -v grep | grep '\-D\['|awk '{print $8}'|head -1)`"/jps"
$jps_cmd -v | grep -Ev '^$|Jps' | grep jboss-modules |
while read psline; do 
  pid=`echo $psline | awk '{print $1}'` 
  prc_name="EAP 6/AS 7 "`echo $psline | awk  -F '-D' '{ print $2}' | awk -F ']' '{print $1"]"}' | sed -e 's/\[//g' -e 's/\]//g'`
  conf_name=`echo $psline | awk -F '-c ' '{print $2}'  ` 
  if [ "x" != "x"$conf_name ] ; then
    prc_name=$prc_name" ["$conf_name"]"
  fi
  info_prc=`ps -o nlwp,etime,rss h $pid`
  nlwp=`echo $info_prc|awk '{print $1}'`
  etime=`echo $info_prc|awk '{print $2}'`
  rss=`echo $info_prc|awk '{print $3}'`
  echo "$pid - $prc_name ($nlwp threads, elapsed time $etime, RSS memory $(($rss/1024)) MB)"
  jinfo_cmd=`dirname $(ps -ef|grep $pid|awk '{print $8}'|head -1)`"/jinfo"
  $jinfo_cmd $pid 2>&1|grep -E '^jboss.server.log.dir|^jboss.server.base.dir|^org.jboss.boot.log.file'| sort|awk '{print "\t"$3}'
  echo ""
  LANG=en sudo netstat -antpuew | grep -E "$pid/java" | grep LISTEN | awk '{print "\t"$1" "$4}' | sort
  echo ""
done

