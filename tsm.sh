#!/bin/bash

# 初始化
server_statue="running"

# 函数：显示菜单
function display_menu() {
    # ANSI颜色码
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    NC='\033[0m' # 重置颜色

    echo "                                "
    echo "-------------  Terraria Script v1.0 -------------"
    case "$server_statue" in
        "stop")
            echo -e "Server statue: ${RED}Stop${NC}"
            ;;
        "running")
            echo -e "Server statue: ${GREEN}Running${NC}"
            ;;
        "restart")
            echo -e "Server statue: ${YELLOW}Restart${NC}"
            ;;
        *)
            echo "Server statue: Unknown"
            ;;
    esac
    echo 
    echo "1. 下载服务器"
    echo "2. 启动服务器"
    echo "3. 停止服务器"
    echo "4. 重启服务器"
    echo "5. 查看配置"
    echo "6. 修改配置"
    echo "7. 卸载"
}

function update_config() {
    info=(
        "最大玩家数"
        "端口号"
        "服务器密码"
        "当前存档"
    )
    echo "-------------- Update --------------"
    # 打印选项列表
    for ((i = 0; i < ${#info[@]}; i++)); do
        echo "$((i+1)). ${info[$i]}"
    done

    echo -n "输入选项的编号："
    read choice

    case $choice in
        1)
            echo -n "请输入新的最大玩家数: "
            read max_players
            # 检查输入是否为1到255之间的整数
            if ! [[ "$max_players" =~ ^[1-9][0-9]{0,2}$ || "$max_players" -le 255 ]]; then
                echo "错误：请输入1到255之间的整数作为最大玩家数。"
                exit 1
            fi
            echo "已将最大玩家数更新为：$max_players"
            ;;
        2)
            echo -n "请输入新的端口号: "
            read port
            # 检查输入是否为1到65535之间的整数
            if ! [[ "$port" =~ ^[1-9][0-9]{0,4}$ || "$port" -le 65535 ]]; then
                echo "错误：请输入1到65535之间的整数作为端口号。"
                exit 1
            fi
            echo "已将端口号更新为：$port"
            ;;
        3)
            echo -n "请输入新的服务器密码（回车代表没有密码）: "
            read server_password
            # 在这里处理更新服务器密码的逻辑，比如写入配置文件
            echo "已将服务器密码更新为：$server_password"
            ;;
        4)
            echo -n "请输入新的存档: "
            read world_name
            # 在这里处理更新世界名字的逻辑，比如写入配置文件
            echo "已将世界名字更新为：$world_name"
            ;;
        *)
            echo "无效的选项，请重新运行脚本并选择正确的编号。"
            ;;
    esac
}



function show_config() {
    file="config.txt"

    if [ ! -f "$file" ]; then
        echo "Config file not found!"
        return 1
    fi

    info=(
        "最大玩家数 (maxplayers)    "
        "载入世界 (world)           "
        "端口号 (port)              "
        "服务器密码 (password)      "
        "Message of the day (motd)  "
        "反作弊 (secure)            "
        "语言 (language)            "
    )

    echo "-------------- Config --------------"

    while IFS= read -r line
    do
        if [[ $line == \#*-* ]]; then
            comment="$(echo "${line#'#'}" | cut -d'-' -f1 | xargs)"
        elif [[ $line != \#* ]] && [[ $line != "" ]]; then
            name="${line%%=*}"
            value="${line#*=}"
            for i in "${info[@]}"; do
                if [[ "$i" == *"$name"* ]]; then
                    printf "%s = %s\n" "$i" "$value"
                fi
            done
        fi
    done < "$file"
}

function download_server() {
    echo "正在获取版本..."
    url="https://terraria.wiki.gg/wiki/Server#Downloads"

    html_content=$(curl -s "$url")
    terraria_server_links=$(echo "$html_content" | grep -o '<a[^>]*href="[^"]*"[^>]*>' | grep -o 'href="[^"]*"')

    # 用于存储所有符合条件的链接
    matched_links=()

    download_links=()

    # 使用循环遍历所有链接，并提取包含terraria-server-的链接
    for link in $terraria_server_links; do
        if echo "$link" | grep -q 'terraria-server-'; then
            server_version=$(echo "$link" | grep -o 'terraria-server-[^"]*')
            matched_links+=("$server_version")
            download_link=$(echo "$link" | sed -e 's/href="//' -e 's/"$//')
            download_links+=("$download_link")
        fi
    done

     
    total=${#matched_links[@]}
    last_10="${matched_links[@]:$((total-10)):10}"

    # 输出最后十个版本供选择
    PS3="请选择一个版本:"
    select version_choice in ${last_10[@]}; do
        if [ -n "$version_choice" ]; then
            echo "您选择的版本是: $version_choice"
            index=0
            for version in "${matched_links[@]}"; do
                if [ "$version" == "$version_choice" ]; then
                    download_url="${download_links[$index]}"
                    echo "下载链接：$download_url"
                    wget -c "$download_url" -O "${version_choice}"
                    echo "下载完成"
                    break
                fi
                ((index++))
            done
            break
        else
            echo "无效的选项，请重新输入!"
        fi
    done

    echo "正在解压"
    unzip "$version_choice" -d TerrariaServer
    echo "解压完成"

    echo "服务器版本 $server_version 下载完成！"
}

function delete_server() {
    echo 1
}

function get_latest_version() {
    # 切换到TerrariaServer目录
    cd TerrariaServer

    # 找到该目录下的所有文件名中的数字，并将其排序（按照文件名升序排序）
    latest_version=$(ls | grep -Eo '[0-9]+' | sort -n | tail -1)

    # 返回最新版本号
    echo "$latest_version"
}

function start_server() {
    latest_version=$(get_latest_version)
   
    # 确保服务器二进制文件有执行权限
    chmod +x "TerrariaServer/$latest_version/Linux/TerrariaServer.bin.x86_64"

    # 启动服务器并在后台运行
    "./TerrariaServer/$latest_version/Linux/TerrariaServer.bin.x86_64" -config /root/project/tsm.sh/config.txt &
    
    # 输出服务器已经启动
    echo "TerrariaServer is now running in the background."
}



# 主循环
#while true; do
    display_menu
    echo -n "请输入选项:"
    read option
    case $option in
        1)
            download_server # 调用下载服务器函数
            ;;
        2)
            start_server # 启动服务器的功能， 
            ;;
        3)
            # 停止服务器的功能， 
            ;;
        4)
            # 重启服务器的功能， 
            ;;
        5)
            show_config # 查看配置信息的功能， 
            ;;
        6)
            update_config # 更新的功能， 
            ;;
        7)
            delete_server # 卸载的功能， 
            ;;
        *)
            echo "无效的选项，请重新输入！"
            ;;
    esac
    echo # 输出一个空行
#done

