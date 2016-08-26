#!/bin/sh

#  BuildPack.sh
#  Taotaole
#
#  Created by heliang on 16/7/21.
#  Copyright © 2016年 heliang. All rights reserved.



workspaceName="Taotaole"
targetName="$1" #"Taotaole"
branch="$2" #dev / master
echo "${targetName}"
echo "${branch}"
archiveOutputDir="/Users/$USER/work"
ipaOutputDir="/Users/$USER/iOS"
echo "${archiveOutputDir}"
echo "${ipaOutputDir}"

#xcode打包命名规范一致
archiveName="${targetName} $(date +%y)-$(printf '%1d' $(date +%m))-$(date +%d) $(date +%H).$(date +%M).xcarchive"
echo "${archiveName}"


security unlock-keychain -p "0" "/Users/heliang/Library/Keychains/login.keychain" || failed "unlock-keygen"

function failed() {
    echo "Failed: $@" >&2
    exit 1
}

function checkDir() {
    echo "checkDir $1 ?"
    #如果资源文件夹不存在，创建文件夹
    if [ ! -d "$1" ]; then
        mkdir "$1"
        echo "$1 is not exist, create it"
    fi
}

#Git OP
function updateCode() {  #dev\ #master
    #切换分支
    git checkout $1 || failed "切换分支失败"
    git pull || failed "拉取最新代码失败"
}


function clean() {
    # 清理工程
    xcodebuild clean -workspace ${workspaceName}.xcworkspace -scheme ${targetName} -configuration Release || failed "xcodebuild clean"
}

function archive(){
    # ARCHIVE
    xcodebuild archive -workspace ${workspaceName}.xcworkspace \
    -scheme ${targetName} \
    -archivePath "${archiveOutputDir}"/"${archiveName}" \
    -configuration Release || failed "xcodebuild archive"
}

#Taotaole 2016-07-21 15-19-21
function exportIpa() {
    # EXPORT IPA
    xcodebuild -exportArchive "${archiveName}" \
    -archivePath "${archiveOutputDir}"/"${archiveName}" \
    -exportPath "${ipaOutputDir}" \
    -exportOptionsPlist exportOptionsPlist.plist || failed "xcodebuild export archive"
}

function generalHtml() {
    echo "<hr/>(本邮件是程序自动下发的，请勿回复！)<br/><hr/>项目名称：淘淘乐(安卓版)<br/><hr/>构建编号：%BUILD_NUMBER%<br/><hr/>Git地址：%giturl%<br/><hr/>本次编译安装包版本号：%version%<br/><hr/>构建日志地址：<a href="%BUILD_URL%console">%BUILD_URL%console</a><br/><hr/>构建地址：<a href="%BUILD_URL%">%BUILD_URL%</a><br/><hr/>所有包的下载（test是测试public是正式）：<a href="%downloadurl%/apk/%outputfolder%/">%downloadurl%/apk/%outputfolder%/</a><hr/>"  >..\\build.log
}


checkDir "${archiveOutputDir}"
checkDir "${ipaOutputDir}"
#updateCode "${branch}"
buildNumber=`git rev-list HEAD | wc -l | awk '{print $1}'`
echo "$buildNumber"
clean
archive
exportIpa

