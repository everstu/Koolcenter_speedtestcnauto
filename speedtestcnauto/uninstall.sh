#!/bin/sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

echo_date "插件自带脚本开始运行..."
echo_date "正在移除定时任务..."
sed -i '/speedtestcnauto_main/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
echo_date "定时任务移除成功..."
echo_date "正在删除插件资源文件..."
rm -rf /koolshare/speedtestcnauto
rm -rf /koolshare/scripts/speedtestcnauto_main.sh
rm -rf /koolshare/webs/Module_speedtestcnauto.asp
rm -rf /koolshare/res/*speedtestcnauto*
rm -rf /koolshare/init.d/*speedtestcnauto.sh
rm -rf /koolshare/bin/jq_speed >/dev/null 2>&1
echo_date "插件资源文件删除成功..."

rm -rf /koolshare/scripts/uninstall_speedtestcnauto.sh
echo_date "已成功移除插件... Bye~Bye~"