#!/bin/sh
# shellcheck disable=SC2039
source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
speedAutoBaseDir="/koolshare/speedtestcnauto/"
runtimeDir="${speedAutoBaseDir}runtime/"
tisuactlogDir="${speedAutoBaseDir}tisuactlog/"
mkdir -p $runtimeDir
mkdir -p $tisuactlogDir
lastwaniptxt="${runtimeDir}lastwanip"
waniplogtxt="${runtimeDir}waniplog"
runtimelog="${runtimeDir}runtimelog"
tisutimelog="${runtimeDir}tisutimelog"
querydatalog="${runtimeDir}querydatalog"
tisudatalog="${runtimeDir}tisudatalog"
isdotisulog="${runtimeDir}isdotisulog"
queryapi="https://tisu-api.speedtest.cn/api/v2/speedup/query?source=www-index"
reopenapi="https://tisu-api.speedtest.cn/api/v2/speedup/reopen?source=www"
LOGFILE="/tmp/upload/speedtestcnauto_log.txt"
tisuactlog="${tisuactlogDir}speedtestcnauto_tisuactlog"
can_speed="0"
query_data=""

# shellcheck disable=SC2120
start_reopen(){
    # shellcheck disable=SC2046
    # shellcheck disable=SC2005
    echo $(date '+%Y-%m-%d %H:%M:%S') >$runtimelog
    tisumessage="<font color='yellow'>当前宽带不支持提速</font>"
    #查询上次是否标记为提速成功
    if [ -f $isdotisulog ]; then
      isdotisu=$(cat $isdotisulog)
    else
      isdotisu="no"
    fi

    #查询接口
    queryStatus
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
            down_expire_trial_t=$(echo "${query_data}" | jq_speed .data.down_expire_trial_t)
            up_expire_t=$(echo "${query_data}" | jq_speed .data.up_expire_t)
            up_h_expire_t=$(echo "${query_data}" | jq_speed .data.up_h_expire_t)

            #检查是否开通提速套餐,上行套餐,下行套餐,试用套餐
            if [ "$down_expire_t" -eq "0" ] && [ "$down_expire_trial_t" -eq "0" ] && [ "$up_expire_t" -eq "0" ]  && [ "$up_h_expire_t" -eq "0" ];then
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
                #对比上次IP，如相同且提速标记为成功则退出，否则执行提速
                if [ "$newwanip" = "$oldwanip" ] && [ "$isdotisu" = "yes" ]; then
                  exit
                else
                  tisu_data=$(curl -m 30 -s "$reopenapi")
                  #写入提速最后执行日志
                  echo "$tisu_data" >$tisudatalog
                  # shellcheck disable=SC2046
                  # shellcheck disable=SC2005
                  if [ "$tisu_data" ];then
                     record_tisuactlog
                     #前端接口查询日志
                     tisumessage=$(date '+%Y-%m-%d %H:%M:%S')
                     #标记为成功提速
                     echo "yes" > $isdotisulog
                    else
                     #前端接口查询日志
                     tisumessage="<font color='yellow'>执行提速接口请求失败或请求超时</font>"
                     #标记为提速失败
                     echo "no" > $isdotisulog
                  fi
                fi
                #缓存最新ip地址
                echo "$newwanip" > $lastwaniptxt
              else
                tisumessage="<font color='yellow'>当前宽带支持提速,但是未开通提速套餐.</font>"
            fi
          else
            tisumessage="<font color='yellow'>当前宽带不支持提速</font>"
        fi
      else
          # shellcheck disable=SC2089
          tisumessage="<font color='yellow'>提速查询接口请求失败或请求超时</font>"
    fi

    #未提速成功才复写提速日志,已经提速成功了不复写提速日志
    if [ "$isdotisu" = "no" ];then
      # shellcheck disable=SC2090
      echo "$tisumessage"  >$tisutimelog
    fi
}

record_tisuactlog(){
  tmptisuactlog=""
  #检查是否已经写入日志
  if [ -f $tisuactlog ];then
      tmptisuactlog=$(cat "$tisuactlog")
  fi
  #写入提速时间记录
  echo_date "本次IP [ ${newwanip} ] 提速成功 >>>" > $tisuactlog
  #如果有写入日志则追加写入
  if [ "$tmptisuactlog" ];then
    #写入追加日志
    echo "$tmptisuactlog" >> $tisuactlog
    #最大记录10条日志
    sed -i '16,999d' $tisuactlog >/dev/null 2>&1
  fi
}

add_cron(){
  sed -i '/speedtestcnauto_main/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
  cru a speedtestcnauto_main "*/5 * * * * /bin/sh /koolshare/scripts/speedtestcnauto_main.sh reopen"
}

self_upgrade(){
   versionapi="https://raw.githubusercontents.com/wengheng/Koolcenter_speedtestcnauto/master/version_info"
   if [ "${1}" ];then
     echo_date "获取最新版本中..." >> $LOGFILE
   else
     echo_date "检查版本更新中...">>$LOGFILE
   fi

   #通过接口获取新版本信息
   version_info=$(curl -s -m 30 "$versionapi")
   new_version=$(echo "${version_info}" | jq_speed .version)
   old_version=$(dbus get "softcenter_module_speedtestcnauto_version")
   # shellcheck disable=SC2154
   # shellcheck disable=SC2046
   #比较版本信息 如果新版本大于当前安装版本或强制更新则执行更新脚本
   if [ $(expr "$new_version" \> "$old_version") -eq 1 ] || [ "${1}" ];then
       local tmpDir="/tmp/upload/speedtestcnauto_upgrade/"
       mkdir -p $tmpDir
       if [ "${1}" ];then
         echo_date "开始强制更新,如有更新后有异常,请重新离线安装插件..." >> $LOGFILE
       else
         echo_date "新版本:${new_version}已发布,开始更新..." >> $LOGFILE
       fi
       echo_date "下载资源新版本资源..." >> $LOGFILE
       versionfile=$(echo "${version_info}"|jq_speed .fileurl |sed 's/\"//g')
       #下载新版本安装包 目前是全量更新
       wget --no-cache -O ${tmpDir}speedtestcnauto.tar.gz "${versionfile}"
       if [ -f "${tmpDir}speedtestcnauto.tar.gz" ];then
         # shellcheck disable=SC2129
         echo_date "新版本下载成功.." >> $LOGFILE
         newFileMd5=$(md5sum ${tmpDir}speedtestcnauto.tar.gz|cut -d ' ' -f1)
         echo_date "下载文件MD5为:" >> $LOGFILE
         echo_date "${newFileMd5}" >> $LOGFILE
         # shellcheck disable=SC2005
         checkMd5=$(echo "${version_info}" |jq_speed .md5sum |sed 's/\"//g')
         # shellcheck disable=SC2129
         echo_date "校验MD5为:" >> $LOGFILE
         echo_date "${checkMd5}" >> $LOGFILE
         # shellcheck disable=SC1009
         #校验MD5是否为打包MD5
         if [ "$newFileMd5" = "$checkMd5" ];then
            echo_date "MD5校验通过..." >> $LOGFILE
            sleep 1
            echo_date "开始更新插件..." >> $LOGFILE
            sleep 1
            echo_date "尝试解压安装包..." >> $LOGFILE
            sleep 1
            cd $tmpDir || exit
            #解压到临时文件夹
            tar -zxvf ${tmpDir}speedtestcnauto.tar.gz
            echo_date "安装包解压成功..." >> $LOGFILE
            sleep 1
            #升级脚本赋权
            chmod +x "${tmpDir}speedtestcnauto/upgrade.sh"

            echo_date "执行更新脚本..." >> $LOGFILE
            sleep 1
            #执行升级脚本
            start-stop-daemon -S -q -x "${tmpDir}speedtestcnauto/upgrade.sh" 2>&1
            sleep 1
            # shellcheck disable=SC2181
            if [ "$?" != "0" ];then
                rm -rf $tmpDir >/dev/null 2>&1
            		echo_date "更新脚本运行出错,退出更新,请离线更新或稍后再更新..." >> $LOGFILE
              else
                echo_date "更新完成,享受新版本吧~~~" >> $LOGFILE
            fi
           else
            echo_date "文件MD5校验失败,退出更新,请离线更新或稍后再更新..." >> $LOGFILE
         fi
       else
         echo_date "新版本资源下载失败,退出更新,请离线更新或稍后再更新..." >> $LOGFILE
       fi
     else
       echo_date "当前版本:v${old_version}是最新版本,无需更新!" >> $LOGFILE
   fi
   echo "SPEEDTNBBSCDE">>$LOGFILE
}

queryStatus(){
  query_data=$(curl -m 30 -s "$queryapi")
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
  tisutips="默认响应说明"
  if [ "${2}" = "update" ];then
    echo "" > $LOGFILE
    http_response "$1"
    if [ "${3}" = '1' ];then
      #强制更新
      self_upgrade 1
    else
      self_upgrade 0
    fi
    exit;
  fi
  #查询宽带提速状态,后端查询
  if [ "${2}" = "query" ];then
    queryStatus
    # shellcheck disable=SC2046
    http_response $(echo "$query_data"|base64_encode)
    exit
  fi
  #查询提速日志
  if [ "${2}" = "tisuactlog" ];then
    # shellcheck disable=SC2046
    http_response $(cat $tisuactlog)
    exit
  fi
  #手动提速
  if [ "${2}" = "reopen" ];then
    #清理缓存文件
    rm -rf ${runtimeDir}
    mkdir -p $runtimeDir
    #执行提速脚本
    start_reopen
    tisutips="手动提速执行成功,请自行确认是否提速成功."
    if [ "$can_speed" -eq "0" ];then
      tisutips="当前宽带不支持提速<br>目前仅支持电信,联通,具体是否支持,请以此显示结果为准<br>本插件对你来说没有任何作用啦,你可以卸载本插件啦."
    fi
  fi
  #手动重新运行
  if [ "${2}" = "dorestart" ];then
	  add_cron
    tisutips="恭喜你，手动重新启动脚本成功！"
  fi
  #查询状态
  #最后运行时间
  runtime=$(cat $runtimelog)
  #最后提速时间
  tisutime=$(cat $tisutimelog)
  #后台查询IP
  wanipaddr=$(cat $waniplogtxt)
  #查询上次是否标记为提速成功
  if [ -f $isdotisulog ]; then
    isdotisu=$(cat $isdotisulog)
  else
    isdotisu="no"
  fi
  http_response "$runtime@$tisutime@$wanipaddr@$tisutips@$isdotisu"
;;
esac