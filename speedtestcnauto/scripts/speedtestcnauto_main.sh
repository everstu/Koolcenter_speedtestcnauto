#!/bin/sh
source /koolshare/scripts/base.sh
mkdir -p /tmp/speedtestcnauto/
iplogtxt="/tmp/speedtestcnauto/lastwanip.txt"
runtimelog="/tmp/speedtestcnauto/runtimelog.txt"
tisutimelog="/tmp/speedtestcnauto/tisutimelog.txt"

start_reopen(){
    echo `date '+%Y-%m-%d %H:%M:%S'` >$runtimelog;
    #获取WANIP
    newwanip=`curl ifconfig.me`
    #如接口获取不到ip，本次取消操作
    if [ x"$newwanip" = "x" ]; then
      exit
    fi
    if [ -f $iplogtxt ]; then
      oldwanip=`cat $iplogtxt`
    else
      oldwanip="0.0.0.0"
    fi
    #对比上次IP，如相同则退出，否则执行提速
    if [ "$newwanip" = "$oldwanip" ]; then
      exit
    else
      real_reopen
    fi
    #缓存最新ip地址
    echo $newwanip > $iplogtxt
}

real_reopen(){
#后续再开发这个.
#  canspeed=`curl -s 'https://tisu-api.speedtest.cn/api/v2/speedup/query?source=www-index' | jq .data.status.can_speed`
#  if [ $canspeed ]; then
    curl -s 'https://tisu-api.speedtest.cn/api/v2/speedup/reopen?source=www'
    echo `date '+%Y-%m-%d %H:%M:%S'` >$tisutimelog;
#  else
#    echo '当前网络环境暂时不支持提速' >$tisutimelog;
#  fi
}

add_cron(){
  sed -i '/speedtestcnauto_main/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
  cru a speedtestcnauto_main "*/5 * * * * /bin/sh /koolshare/scripts/speedtestcnauto_main.sh reopen"
}

case $1 in
start)
	# 开机启动
	add_cron
	;;
reopen)
  start_reopen
  ;;
*)#web提交
  if [ "${2}" = "reopen" ];then
      #清理缓存文件
      rm -rf /tmp/speedtestcnauto/*
      #执行提速脚本
      start_reopen
      http_response "手动提速执行成功,请自行确认是否提速成功."
  else
    #查询状态
    runtime=`cat $runtimelog`
    tisutime=`cat $tisutimelog`
    wanipaddr=`cat $iplogtxt`
    http_response "$runtime@$tisutime@$wanipaddr"
  fi
;;
esac