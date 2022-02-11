#!/bin/sh
# shellcheck disable=SC2039
source /koolshare/scripts/base.sh
runtimeDir="/koolshare/speedtestcnauto/runtime/"
mkdir -p $runtimeDir
lastwaniptxt="${runtimeDir}lastwanip"
waniplogtxt="${runtimeDir}waniplog"
runtimelog="${runtimeDir}runtimelog"
tisutimelog="${runtimeDir}tisutimelog"
querydatalog="${runtimeDir}querydatalog"
tisudatalog="${runtimeDir}tisudatalog"
queryapi="https://tisu-api.speedtest.cn/api/v2/speedup/query?source=www-index"
reopenapi="https://tisu-api.speedtest.cn/api/v2/speedup/reopen?source=www"
LOGFILE="/tmp/upload/speedtestcnauto_log.txt"
can_speed="0"

start_reopen(){
    # shellcheck disable=SC2046
    # shellcheck disable=SC2005
    echo $(date '+%Y-%m-%d %H:%M:%S') >$runtimelog
    tisumessage="<font color='yellow'>当前宽带不支持提速</font>"
    query_data=$(curl -m 20 -s "$queryapi")
    if [ "$query_data" ]; then
        echo "$query_data" >$querydatalog
        #获取是否能提速
        # shellcheck disable=SC2086
        can_speed=$(echo ${query_data} | jq_speed .data.status.can_speed)
        #查询接口返回的wanip
        # shellcheck disable=SC2086
        querywanip=$(echo ${query_data} | jq_speed .data.addr|grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
        echo "$querywanip" >$waniplogtxt
        #如果能提速则执行提速操作否则直接跳走
        if [ "$can_speed" -eq "1" ];then
            #检查是否需要执行提速
            # shellcheck disable=SC2086
            down_expire_t=$(echo "${query_data}" | jq_speed .data.down_expire_t)
            # shellcheck disable=SC2006
            down_expire_trial_t=$(echo "${query_data}" | jq_speed .data.down_expire_trial_t)
            up_expire_t=$(echo "${query_data}" | jq_speed .data.up_expire_t)
            if [ "$down_expire_t" -eq "0" ] && [ "$down_expire_trial_t" -eq "0" ] && [ "$up_expire_t" -eq "0" ];then
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
                  echo "<font color='yellow'>获取wan口IP失败</font>"  >$waniplogtxt
                  exit
                fi
                if [ -f $lastwaniptxt ]; then
                  oldwanip=$(cat $lastwaniptxt)
                else
                  oldwanip="0.0.0.0"
                fi
                #对比上次IP，如相同则退出，否则执行提速
                if [ "$newwanip" = "$oldwanip" ]; then
                  exit
                else
                  tisu_data=$(curl -m 20 -s "$reopenapi")
                  echo "$tisu_data" >$tisudatalog
                  if [ "$tisu_data" ];then
                     tisumessage=$(date '+%Y-%m-%d %H:%M:%S')
                    else
                     tisumessage="<font color='yellow'>提速接口请求失败或请求超时</font>"
                  fi
                fi
                #缓存最新ip地址
                echo "$newwanip" > $lastwaniptxt
              else
                tisumessage="<font color='yellow'>当前宽带支持提速,但是未开通提速套餐.</font>";
            fi
          else
            tisumessage="<font color='yellow'>当前宽带不支持提速</font>";
        fi
      else
          # shellcheck disable=SC2089
          tisumessage="<font color='yellow'>提速接口请求失败或请求超时</font>"
    fi
    # shellcheck disable=SC2090
    echo "$tisumessage"  >$tisutimelog
}

add_cron(){
  sed -i '/speedtestcnauto_main/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
  cru a speedtestcnauto_main "*/5 * * * * /bin/sh /koolshare/scripts/speedtestcnauto_main.sh reopen"
}

self_upgrade(){
  chmod +x /koolshare/scripts/upgrade_speedtestcnauto.sh >/dev/null 2>&1
  start-stop-daemon -S -q -x /koolshare/scripts/upgrade_speedtestcnauto.sh 2>&1
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
  if [ "${2}" = "update" ];then
    echo "" > $LOGFILE
    http_response "$1"
    self_upgrade
    exit;
  fi
  #手动提速
  if [ "${2}" = "reopen" ];then
    #清理缓存文件
    rm -rf ${runtimeDir}*
    #执行提速脚本
    start_reopen
    tisutips="手动提速执行成功,请自行确认是否提速成功."
    if [ "$can_speed" -eq "0" ];then
      tisutips="当前宽带不支持提速<br>目前仅支持电信,联通,具体是否支持,请以此显示结果为准<br>本插件对你来说没有任何作用啦,你可以卸载本插件啦."
    fi
  fi
  #查询状态
  runtime=$(cat $runtimelog)
  tisutime=$(cat $tisutimelog)
  wanipaddr=$(cat $waniplogtxt)
  http_response "$runtime@$tisutime@$wanipaddr@$tisutips"
;;
esac