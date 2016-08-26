#!/bin/sh

#  HandleResource.sh
#  Taotaole
#
#  Created by heliang on 16/6/3.
#  Copyright © 2016年 heliang. All rights reserved.

echo "Handling Assets start"
buildResource="${PROJECT_DIR}/BuildResource"
appName="${TARGET_NAME%_Publish*}"
echo "$appName"
lanName="$1"
echo "$lanName" # En

file_exist() {
    echo "file_exist"
    #如果资源文件夹不存在，创建文件夹
    if [ ! -d "$buildResource" ]; then
        mkdir "$buildResource"
    fi
}

handle_image_replace() {
    echo "handle_image_replace"
    buildBaseAssetsFile="${buildResource}/BuildAssets.xcassets"
    assetsFile="${PROJECT_DIR}/HappyBuy/Assets.xcassets"
    if [ -z "$lanName" ]; then
        echo "use default Assets"
    else
        echo "use custom Assets"
    fi

    replaceAssetsFile="${PROJECT_DIR}/${appName}/Assets${lanName}.xcassets"
    echo "$buildBaseAssetsFile"
    echo "$assetsFile"
    echo "$replaceAssetsFile"
    echo "clearn file"
    rm -rf "$buildBaseAssetsFile"
    if [ -d "$assetsFile" ]; then
        echo "copy $assetsFile"
        cp -r "$assetsFile/" "$buildBaseAssetsFile"
    fi
    if [ -d "$replaceAssetsFile" ]; then
        echo "copy $replaceAssetsFile"
        cp -r "$replaceAssetsFile/" "$buildBaseAssetsFile"
    fi
}

handle_language_replace() {
    echo "handle_language_replace"
    buildBaseLanguageFile="${buildResource}/InfoPlist.strings"
    languageFile="${PROJECT_DIR}/HappyBuy/InfoPlist.strings"
    if [ -z "$lanName" ]; then
        echo "use default language"
    else
        echo "use custom language"
    fi
    replaceLanguageFile="${PROJECT_DIR}/${appName}/InfoPlist${lanName}.strings"
    echo "$replaceLanguageFile"
    rm -rf "$buildBaseLanguageFile"
    if [ -a "$languageFile" ]; then
        echo "copy $languageFile"
        cat "$languageFile" >> "$buildBaseLanguageFile"
    fi
    if [ -a "$replaceLanguageFile" ]; then
        echo "copy $replaceLanguageFile"
        cat "$replaceLanguageFile" >> "$buildBaseLanguageFile"
    fi
}

file_exist
handle_image_replace
handle_language_replace

echo "Handle Language end"