export PS1='   <\[\033[01;31m\]\u| \h - '`/sbin/ifconfig eth0|grep 'inet '|awk '{print $2}' |awk -F':' '{print $2}'`' \[\033[01;31m\] \[\033[01;32m\]\W\[\033[0m\]>\$ '
export PATH=/sbin:/usr/sbin:$PATH:/usr/local/bin:/bin:/usr/bin:$HOME/bin
alias l='ls -lahF'
