#!/bin/bash
set -x
master=$1;shift
this_host=$1;shift
rabbit_list=$1;shift

epmd_pid=`ps -ef |grep "epmd"|grep -v grep |awk '{print $2}'`
beam_pid=`ps -ef |grep "beam"|grep -v grep |awk '{print $2}'`

service rabbitmq-server stop
epmd -kill
pkill -9 beam
pkill -9 epmd

check_pid () {
  pid=$1
  x=1
  while [ $x -le 5 ]; do
    ps -ef | grep $pid |grep -v grep
    if [ $? -eq 0 ]; then
      (( x = x+1 ))
    else
      return
    fi
  done
  exit 1
}

check_pid $epmd_pid
check_pid $beam_pid

rm -rf /var/lib/rabbitmq/mnesia
service supervisor-support-service restart
#service rabbitmq-server restart

echo ${rabbit_list[@]}
for rabbit_host in ${rabbit_list[@]}; do
    rabbitmqctl cluster_status | grep $rabbit_host
    added_to_cluster=$?
    if [ $added_to_cluster != 0 ]; then
	exit 1
    fi
done

