#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#######################################################
#                       修改ss端口自动脚本
# 使用方法：
#    1、直接修改shadowsocksport的端口号后运行
#    2、或者运行脚本 + 端口参数
#
#######################################################

shadowsocksport="$1"

#修改配置文件端口
function editSSConfig() {

    #port=$(jq '.server_port' /etc/shadowsocks-libev/config.json)
    #添加第三行
    echo "3a \"server_port\":${shadowsocksport},"
    sed -i "3a \"server_port\":${shadowsocksport}," /etc/shadowsocks-libev/config.json
    #删除第三行
    sed -i '3d' /etc/shadowsocks-libev/config.json
}

#修改防火墙只用于centos7
function editFireWall() {
    systemctl status firewalld > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        default_zone=$(firewall-cmd --get-default-zone)
        oldPort=$(jq '.server_port' /etc/shadowsocks-libev/config.json)
        firewall-cmd --permanent --zone=${default_zone} --remove-port=${oldPort}/tcp
        firewall-cmd --permanent --zone=${default_zone} --remove-port=${oldPort}/udp
        firewall-cmd --permanent --zone=${default_zone} --add-port=${shadowsocksport}/tcp
        firewall-cmd --permanent --zone=${default_zone} --add-port=${shadowsocksport}/udp
        firewall-cmd --reload
    else
        echo -e "[${yellow}Warning${plain}] firewalld looks like not running or not installed, please enable port ${shadowsocksport} manually if necessary."
    fi
}

function runSSServer() {
    /etc/init.d/shadowsocks restart
    /etc/init.d/shadowsocks status
}

function main() {
    editFireWall
    editSSConfig
    runSSServer
}

main