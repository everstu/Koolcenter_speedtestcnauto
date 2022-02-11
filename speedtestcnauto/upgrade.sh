#!/bin/sh
source /koolshare/scripts/base.sh
LOGFILE="/tmp/upload/speedtestcnauto_log.txt"

# shellcheck disable=SC2120
real_upgrade(){
  echo_date "检查版本更新中...">>$LOGFILE
  version_info=$(curl -s -m 10 "https://raw.githubusercontents.com/wengheng/Koolcenter_speedtestcnauto/master/version_info")
  new_version=$(echo "${version_info}" | jq_speed .version)
  old_version=$(dbus get "softcenter_module_speedtestcnauto_version")
  # shellcheck disable=SC2154
  # shellcheck disable=SC2046
  if [ $(expr "$new_version" \> "$old_version") -eq 1 ];then
      tmpDir="/tmp/speedtestcnauto_up/"
      mkdir -p $tmpDir
      echo_date "新版本:${new_version}已发布,开始更新..." >> $LOGFILE
      echo_date "下载资源新版本资源..."
      wget -O ${tmpDir}speedtestcnauto.tar.gz https://raw.githubusercontents.com/wengheng/Koolcenter_speedtestcnauto/master/speedtestcnauto.tar.gz >> $LOGFILE
      if [ -f "${tmpDir}speedtestcnauto.tar.gz" ];then
        # shellcheck disable=SC2129
        echo_date "新版本下载成功.." >> $LOGFILE
        newFileMd5=$(md5sum ${tmpDir}speedtestcnauto.tar.gz|cut -d ' ' -f1)
        echo_date "下载文件MD5为:${newFileMd5}" >> $LOGFILE
        # shellcheck disable=SC2005
        checkMd5=$(echo "${version_info}" |jq_speed .md5sum |sed 's/\"//g')
        # shellcheck disable=SC2129
        echo_date "校验MD5为:${checkMd5}" >> $LOGFILE
        # shellcheck disable=SC1009
        if [ "$newFileMd5" = "$checkMd5" ];then
            echo_date "MD5校验通过,开始更新..." >> $LOGFILE
            echo_date "停止运行中脚本..." >> $LOGFILE
            sed -i '/speedtestcnauto_main/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
            echo_date "开始替换旧文件..." >> $LOGFILE
            rm -rf /koolshare/speedtestcnauto
            rm -rf /koolshare/scripts/speedtestcnauto_main.sh
            rm -rf /koolshare/webs/Module_speedtestcnauto.asp
            rm -rf /koolshare/res/*speedtestcnauto*
            rm -rf /koolshare/init.d/*speedtestcnauto.sh
            rm -rf /koolshare/bin/jq_speed >/dev/null 2>&1
            echo_date "开始复制新文件..." >> $LOGFILE
            cp -f ${tmpDir}speedtestcnauto/bin/jq_speed /koolshare/bin/
            chmod 755 /koolshare/bin/jq_speed >/dev/null 2>&1
            cp -rf ${tmpDir}speedtestcnauto/res/* /koolshare/res/
            cp -rf ${tmpDir}speedtestcnauto/scripts/* /koolshare/scripts/
            cp -rf ${tmpDir}speedtestcnauto/webs/* /koolshare/webs/
            cp -rf ${tmpDir}speedtestcnauto/uninstall.sh /koolshare/scripts/uninstall_speedtestcnauto.sh
            echo_date "复制成功,开始写入版本号:${new_version}..." >> $LOGFILE
            dbus remove softcenter_module_speedtestcnauto_version
            dbus set softcenter_module_speedtestcnauto_version="${new_version}"
            echo_date "版本号写入完成,启用插件中..." >> $LOGFILE
            /bin/sh /koolshare/scripts/speedtestcnauto_main.sh start >/dev/null 2>&1
            echo_date "插件启用成功..." >> $LOGFILE
            echo_date "更新完成,享受新版本吧~~~" >> $LOGFILE
          else
            echo_date "文件MD5校验失败,退出更新,请离线更新或稍后再更新..." >> $LOGFILE
        fi
      else
        echo_date "新版本资源下载失败,退出更新,请离线更新或稍后再更新..." >> $LOGFILE
      fi
    else
      echo_date "当前版本:v${old_version}newV${new_version}是最新版本,无需更新!" >> $LOGFILE
  fi
  echo "SPEEDTNBBSCDE">>$LOGFILE
}

real_upgrade