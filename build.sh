#!/bin/sh
rm -f speedtestcnauto.tar.gz
tar czvf speedtestcnauto.tar.gz speedtestcnauto/ > /dev/null 2>&1
echo "安装包打包成功..."
echo ""

# shellcheck disable=SC2002
oldMd5=$(cat version_info | grep -o -E "\"md5[a-z]{3}\":\"[a-z0-9]{32}\"" | awk -F ":" '{print $2}'| sed 's/\"//g');
echo 旧文件MD5:
echo "$oldMd5"

buildMd5=$(md5sum speedtestcnauto.tar.gz | awk '{print $1}');
echo ""
echo 新文件MD5:
echo "$buildMd5"
echo ""
if [ "$oldMd5" = "$buildMd5" ];then
    echo "新旧文件MD5一致,不修改发布信息"
  else
    #替换版本信息中的MD5
    sed -i 's/"md5sum":".\{32\}"/"md5sum":"'"${buildMd5}"'"/g' version_info
    echo "修改version_info中md5成功"
    echo ""
    echo "如果版本更新了.记得修改版本信息..."
fi