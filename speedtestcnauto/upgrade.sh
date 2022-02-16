#!/bin/sh
# shellcheck disable=SC2039
source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOGFILE="/tmp/upload/speedtestcnauto_log.txt"
versionapi="https://raw.githubusercontents.com/wengheng/Koolcenter_speedtestcnauto/master/version_info"
MODEL=
UI_TYPE=ASUSWRT
FW_TYPE_CODE=
# shellcheck disable=SC2034
FW_TYPE_NAME=

get_model(){
	# shellcheck disable=SC2155
	local ODMPID=$(nvram get odmpid)
	# shellcheck disable=SC2155
	local PRODUCTID=$(nvram get productid)
	if [ -n "${ODMPID}" ];then
		MODEL="${ODMPID}"
	else
		MODEL="${PRODUCTID}"
	fi
}

get_ui_type(){
	# default value
	[ "${MODEL}" == "RT-AC86U" ] && local ROG_RTAC86U=0
	[ "${MODEL}" == "GT-AC2900" ] && local ROG_GTAC2900=1
	[ "${MODEL}" == "GT-AC5300" ] && local ROG_GTAC5300=1
	[ "${MODEL}" == "GT-AX11000" ] && local ROG_GTAX11000=1
	[ "${MODEL}" == "GT-AXE11000" ] && local ROG_GTAXE11000=1
	# shellcheck disable=SC2155
	local KS_TAG=$(nvram get extendno|grep koolshare)
	# shellcheck disable=SC2155
	local EXT_NU=$(nvram get extendno)
	# shellcheck disable=SC2155
	local EXT_NU=$(echo ${EXT_NU%_*} | grep -Eo "^[0-9]{1,10}$")
	# shellcheck disable=SC2155
	local BUILDNO=$(nvram get buildno)
	[ -z "${EXT_NU}" ] && EXT_NU="0"
	# RT-AC86U
	# shellcheck disable=SC2166
	if [ -n "${KS_TAG}" -a "${MODEL}" == "RT-AC86U" -a "${EXT_NU}" -lt "81918" -a "${BUILDNO}" != "386" ];then
		# RT-AC86U的官改固件，在384_81918之前的固件都是ROG皮肤，384_81918及其以后的固件（包括386）为ASUSWRT皮肤
		ROG_RTAC86U=1
	fi
	# GT-AC2900
	# shellcheck disable=SC2166
	if [ "${MODEL}" == "GT-AC2900" ] && [ "${FW_TYPE_CODE}" == "3" -o "${FW_TYPE_CODE}" == "4" ];then
		# GT-AC2900从386.1开始已经支持梅林固件，其UI是ASUSWRT
		ROG_GTAC2900=0
	fi
	# GT-AX11000
	# shellcheck disable=SC2166
	if [ "${MODEL}" == "GT-AX11000" -o "${MODEL}" == "GT-AX11000_BO4" ] && [ "${FW_TYPE_CODE}" == "3" -o "${FW_TYPE_CODE}" == "4" ];then
		# GT-AX11000从386.2开始已经支持梅林固件，其UI是ASUSWRT
		ROG_GTAX11000=0
	fi
	# ROG UI
	# shellcheck disable=SC2166
	if [ "${ROG_GTAC5300}" == "1" -o "${ROG_RTAC86U}" == "1" -o "${ROG_GTAC2900}" == "1" -o "${ROG_GTAX11000}" == "1" -o "${ROG_GTAXE11000}" == "1" ];then
		# GT-AC5300、RT-AC86U部分版本、GT-AC2900部分版本、GT-AX11000部分版本、GT-AXE11000全部版本，骚红皮肤
		UI_TYPE="ROG"
	fi
	# TUF UI
	if [ "${MODEL}" == "TUF-AX3000" ];then
		# 官改固件，橙色皮肤
		UI_TYPE="TUF"
	fi
}


install_ui(){
	# intall different UI
	get_ui_type
	if [ "${UI_TYPE}" == "ROG" ];then
		echo_date "安装ROG皮肤！" >> $LOGFILE
		sed -i '/asuscss/d' /koolshare/webs/Module_speedtestcnauto.asp >/dev/null 2>&1
	fi
	if [ "${UI_TYPE}" == "TUF" ];then
		echo_date "安装TUF皮肤！" >> $LOGFILE
		sed -i '/asuscss/d' /koolshare/webs/Module_speedtestcnauto.asp >/dev/null 2>&1
		sed -i 's/3e030d/3e2902/g;s/91071f/92650F/g;s/680516/D0982C/g;s/cf0a2c/c58813/g;s/700618/74500b/g;s/530412/92650F/g' /koolshare/webs/Module_speedtestcnauto.asp >/dev/null 2>&1
	fi
	if [ "${UI_TYPE}" == "ASUSWRT" ];then
		echo_date "安装ASUSWRT皮肤！" >> $LOGFILE
		sed -i '/rogcss/d' /koolshare/webs/Module_speedtestcnauto.asp >/dev/null 2>&1
	fi
}

install_now(){
  tmpDir="/tmp/upload/speedtestcnauto_upgrade/"
  version_info=$(curl -s -m 10 "$versionapi")
  new_version=$(echo "${version_info}" | jq_speed .version)
  echo_date "停止运行中脚本..." >> $LOGFILE
  sed -i '/speedtestcnauto_main/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
  echo_date "开始处理旧文件..." >> $LOGFILE
  rm -rf /koolshare/speedtestcnauto
  rm -rf /koolshare/scripts/speedtestcnauto_main.sh
  rm -rf /koolshare/webs/Module_speedtestcnauto.asp
  rm -rf /koolshare/res/*speedtestcnauto*
  rm -rf /koolshare/init.d/*speedtestcnauto.sh
  rm -rf /koolshare/bin/jq_speed >/dev/null 2>&1
  echo_date "开始替换新文件..." >> $LOGFILE
  cp -f ${tmpDir}speedtestcnauto/bin/jq_speed /koolshare/bin/
  chmod 755 /koolshare/bin/jq_speed >/dev/null 2>&1
  cp -rf ${tmpDir}speedtestcnauto/res/* /koolshare/res/
  cp -rf ${tmpDir}speedtestcnauto/scripts/* /koolshare/scripts/
  cp -rf ${tmpDir}speedtestcnauto/webs/* /koolshare/webs/
  cp -rf ${tmpDir}speedtestcnauto/uninstall.sh /koolshare/scripts/uninstall_speedtestcnauto.sh
  echo_date "替换成功,开始写入版本号:${new_version}..." >> $LOGFILE
  dbus set softcenter_module_speedtestcnauto_version="${new_version}"
  echo_date "版本号写入完成,启用插件中..." >> $LOGFILE
  /bin/sh /koolshare/scripts/speedtestcnauto_main.sh start >/dev/null 2>&1
  echo_date "插件启用成功..." >> $LOGFILE
  echo_date "更新完成,享受新版本吧~~~" >> $LOGFILE
	install_ui
  rm -rf $tmpDir >/dev/null 2>&1
}

install(){
	get_model
	get_ui_type
	install_now
}

install