#!/bin/bash

#  JenkinsScript.sh
#  Binary_option
#
#  Created by heliang on 16/8/29.
#  Copyright © 2016年 heliang. All rights reserved.

xcworkspace="$1" #"Binary_option"
targetName="$2" #"Binary_option" #"Taotaole"
bundle_ID="$3" #"com.nest.ultrabanc"
code_sign_id="$4" #"iPhone Developer: name (**********)"
publish_flag="$5" #如果$5为0。不打外网包.否则打

echo $xcworkspace
echo $targetName
echo $bundle_ID
echo $code_sign_id
echo $publish_flag

projectName="${targetName}_测试包（iOS版）" #"二元期权-测试包(iOS版)"
targetName_Publish="${targetName}_Publish"
buildNumber=`git rev-list HEAD | wc -l | awk '{print $1}'`
echo "buildNumber = ${buildNumber}"
archiveName="${targetName}_${buildNumber}.xcarchive"
archiveName_Publish="${targetName_Publish}_${buildNumber}.xcarchive"
fileName="${JOB_NAME}_v${buildNumber}"
buildDir="${WORKSPACE}/builds/${fileName}"
downloadurl="http://10.0.1.119"
downloadurls="https://10.0.1.119"

function failed() {

	echo "Failed: $@" >&2
	echo "<hr/>(本邮件是程序自动下发的，请勿回复！)<br/><hr/>项目名称：${fileName}<br/><hr/>失败原因: $1<br/><hr/>构建地址：<a href="${BUILD_URL}">${BUILD_URL}</a><br/>" > build.log
	exit 1
}

#檢查git是否有更新
function checkGitUpdate() {

	if [ ! $GIT_PREVIOUS_SUCCESSFUL_COMMIT ];then
		echo "GIT_PREVIOUS_SUCCESSFUL_COMMIT is not exists."
	else
		echo "GIT_COMMIT=[$GIT_COMMIT],GIT_PREVIOUS_SUCCESSFUL_COMMIT=[$GIT_PREVIOUS_SUCCESSFUL_COMMIT]"
	if [ $GIT_PREVIOUS_SUCCESSFUL_COMMIT == $GIT_COMMIT ];then
		echo "GIT_COMMIT is equals to GIT_PREVIOUS_SUCCESSFUL_COMMIT,skip build."
		failed "GIT_COMMIT is equals to GIT_PREVIOUS_SUCCESSFUL_COMMIT,skip build" ＃git沒發生變化，不需要打包，退出
	else
		echo "GIT_COMMIT is not equals to GIT_PREVIOUS_SUCCESSFUL_COMMIT"
	fi
	fi
}

function checkDir() {

	if [ -d "${WORKSPACE}/builds" ]; then
		rm -rf ${WORKSPACE}/builds;
	fi;
	mkdir ${WORKSPACE}/builds;

	if [ -d "${buildDir}" ]; then
		rm -rf "${buildDir}";
	fi;
	mkdir "${buildDir}";
}

function iOSArchive() { #$1 targetName $2 archiveName
#清理
	xcodebuild clean -workspace ${WORKSPACE}/${xcworkspace}.xcworkspace \
	-scheme $1 -configuration Release || failed "xcodebuild clean"

#打包
	xcodebuild archive -workspace ${WORKSPACE}/${xcworkspace}.xcworkspace \
	-scheme $1 \
	-archivePath "${buildDir}/$2" \
	-configuration Release \
	CODE_SIGN_IDENTITY="${code_sign_id}" || failed "xcodebuild archive"

#导出
	xcodebuild -exportArchive $2 \
	-archivePath "${buildDir}/$2" \
	-exportPath "${buildDir}" \
	-exportOptionsPlist "${WORKSPACE}/exportOptionsPlist.plist" || failed "xcodebuild export archive"
}


function makePlist() { #$1 targetName
#plist文件
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>items</key><array><dict><key>assets</key><array><dict><key>kind</key><string>software-package</string><key>url</key><string>${downloadurls}/${fileName}/$1.ipa</string></dict></array><key>metadata</key><dict><key>bundle-identifier</key><string>${bundle_ID}</string><key>kind</key><string>software</string><key>title</key><string>$1</string></dict></dict></array></dict></plist>" > "${buildDir}/$1.plist"
}

function makeHtml(){
#index.html
	echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=yes\"></head><ul><li/><a href=${downloadurl}/server.crt>注意＊＊＊点我下载安装安全证书，再进行下面步骤</a></li><br><li><a href=itms-services://?action=download-manifest&url=${downloadurls}/${fileName}/${targetName}.plist>${fileName}内网包</a></li></ul></html>" > "${buildDir}/index.html"
}

function makeHtml_publish(){
#index.html
	echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=yes\"></head><ul><li/><a href=${downloadurl}/server.crt>注意＊＊＊点我下载安装安全证书，再进行下面步骤</a></li><br><li><a href=itms-services://?action=download-manifest&url=${downloadurls}/${fileName}/${targetName}.plist>${fileName}内网包</a></li><br><li><a href=itms-services://?action=download-manifest&url=${downloadurls}/${fileName}/${targetName_Publish}.plist>${fileName}外网包</a></li></ul></html>" > "${buildDir}/index.html"
}


function copyFile() {

#将文件拷贝到发布目录
#mkdir /Users/Shared/Jenkins/Home/jobs/Build/${fileName};
	if [ -d "/Users/Shared/Jenkins/Home/jobs/Build/${fileName}" ]; then
		rm -rf "/Users/Shared/Jenkins/Home/jobs/Build/${fileName}";
	fi;
	cp -rf "${buildDir}" "/Users/Shared/Jenkins/Home/jobs/Build/"
}

function makeEmail() {

# 邮件
	echo "<hr/>(本邮件是程序自动下发的，请勿回复！)<br/><hr/>项目名称：${projectName}<br/><hr/>构建编号：${BUILD_NUMBER}<br/><hr/>Git地址：${GIT_URL}<br/><hr/>本次编译安装包版本号：${buildNumber}<br/><hr/>构建日志地址：<a href="${BUILD_URL}console">${BUILD_URL}console</a><br/><hr/>构建地址：<a href="${BUILD_URL}">${BUILD_URL}</a><br/><hr/>安装包的下载：<a href="${downloadurl}/${fileName}">${downloadurl}/${fileName}</a> <br/><hr/> 扫描二维码下载(注意微信扫一扫后使用safari打开)：<br/><img src=\"http://qr.liantu.com/api.php?&w=200&text=${downloadurl}/${fileName}\"> <br/> " > build.log
}

function makeiOSPacket() {
	
	iOSArchive ${targetName} ${archiveName} #内网包
	makePlist ${targetName}
	if [ ${publish_flag} == "0" ]; then
		makeHtml
	else
 		iOSArchive ${targetName_Publish} ${archiveName_Publish} #外网包
		makePlist ${targetName_Publish}
		makeHtml_publish
 	fi;
}

function main() {
	checkDir
	makeiOSPacket
	copyFile
	makeEmail
}

main
