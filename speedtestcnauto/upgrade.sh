#!/bin/sh
source /koolshare/scripts/base.sh
LOGFILE="/tmp/upload/speedtestcnauto_log.txt"
# shellcheck disable=SC2120
real_upgrade(){
    tmpDir="/tmp/speedtestcnauto_up/"
    version_info=$(curl -s -m 10 "https://raw.githubusercontents.com/wengheng/Koolcenter_speedtestcnauto/master/version_info")
    new_version=$(echo "${version_info}" | jq_speed .version)
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
}

real_upgrade