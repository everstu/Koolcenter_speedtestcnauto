#!/bin/sh
source /koolshare/scripts/base.sh
mkdir -p /koolshare/speedtestcnauto/runtime/
lastwaniptxt="/koolshare/speedtestcnauto/runtime/lastwanip"
waniplogtxt="/koolshare/speedtestcnauto/runtime/waniplog"
runtimelog="/koolshare/speedtestcnauto/runtime/runtimelog"
tisutimelog="/koolshare/speedtestcnauto/runtime/tisutimelog"
querydatalog="/koolshare/speedtestcnauto/runtime/querydatalog"
queryapi="https://tisu-api.speedtest.cn/api/v2/speedup/query?source=www-index"
reopenapi="https://tisu-api.speedtest.cn/api/v2/speedup/reopen?source=www"
can_speed="1"

start_reopen(){
    echo `date '+%Y-%m-%d %H:%M:%S'` >$runtimelog;
    query_data=`curl -s ${queryapi}`
    echo $query_data >$querydatalog
    #获取是否能提速
    can_speed=`echo ${query_data} | jq_speed .data.status.can_speed`
    #查询接口返回的wanip
    querywanip=`echo ${query_data} | jq_speed .data.addr|grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'`
    echo $querywanip >$waniplogtxt
    #如果能提速则执行提速操作否则直接跳走
    if [ $can_speed -eq "1" ];then
      #检查是否需要执行提速
      down_expire_t=`echo ${query_data} | jq_speed .data.down_expire_t`
      down_expire_trial_t=`echo ${query_data} | jq_speed .data.down_expire_trial_t`
      up_expire_t=`echo ${query_data} | jq_speed .data.up_expire_t`
      if [ $down_expire_t -eq "0" ] && [ $down_expire_trial_t -eq "0" ] && [ $up_expire_t -eq "0" ];then
        need_speed="0"
      else
        need_speed="1"
      fi
      #执行提速操作
      if [ $need_speed -eq "1" ];then
        #获取WANIP
        newwanip=$querywanip
        #如接口获取不到ip，本次取消操作
        if [ x"$newwanip" = "x" ]; then
          exit
        fi
        if [ -f $lastwaniptxt ]; then
          oldwanip=`cat $lastwaniptxt`
        else
          oldwanip="0.0.0.0"
        fi
        #对比上次IP，如相同则退出，否则执行提速
        if [ "$newwanip" = "$oldwanip" ]; then
          exit
        else
          curl -s $reopenapi
          echo `date '+%Y-%m-%d %H:%M:%S'` >$tisutimelog;
        fi
        #缓存最新ip地址
        echo $newwanip > $lastwaniptxt
      else
        echo "<font color='yellow'>当前宽带支持提速,但是未开通提速套餐.</font>" >$tisutimelog;
      fi

    else
      echo "<font color='yellow'>当前宽带不支持提速</font>"  >$tisutimelog;
    fi
}

add_cron(){
  sed -i '/speedtestcnauto_main/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
  cru a speedtestcnauto_main "*/5 * * * * /bin/sh /koolshare/scripts/speedtestcnauto_main.sh reopen"
}

case $1 in
start)
	# 开机启动
	add_cron
  start_reopen
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
    tisutips="手动提速执行成功,请自行确认是否提速成功."
    if [ $can_speed -eq "0" ];then
      tisutips="当前宽带不支持提速<br>目前仅支持电信,联通,具体是否支持,请以此显示结果为准<br>本插件对你来说没有任何作用啦,你可以卸载本插件啦."
    fi
  fi
  #查询状态
  runtime=`cat $runtimelog`
  tisutime=`cat $tisutimelog`
  wanipaddr=`cat $waniplogtxt`
  http_response "$runtime@$tisutime@$wanipaddr@$tisutips"
;;
esac