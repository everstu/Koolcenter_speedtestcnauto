#!/bin/sh

sed -i '/speedtestcnauto_main/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
rm -rf /koolshare/speedtestcnauto
rm -rf /koolshare/scripts/speedtestcnauto_main.sh
rm -rf /koolshare/webs/Module_speedtestcnauto.asp
rm -rf /koolshare/res/*speedtestcnauto*
rm -rf /koolshare/init.d/*speedtestcnauto.sh
rm -rf /tmp/speedtestcnauto/* >/dev/null 2>&1
rm -rf /koolshare/bin/jq_speed >/dev/null 2>&1

rm -rf /koolshare/scripts/uninstall_speedtestcnauto.sh
