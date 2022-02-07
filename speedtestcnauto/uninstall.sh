#!/bin/sh

sed -i '/speedtestcnauto_main/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
rm -rf /koolshare/speedtestcnauto
rm -rf /koolshare/scripts/speedtestcnauto_main.sh
rm -rf /koolshare/webs/Module_speedtestcnauto.asp
rm -rf /koolshare/res/*speedtestcnauto*
rm -rf /tmp/speedtestcnauto/* >/dev/null 2>&1

rm -rf /koolshare/scripts/uninstall_speedtestcnauto.sh
