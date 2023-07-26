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
    echo "5. 查看配置信息"
    echo "6. 更新"
    echo "7. 卸载"
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

function start_server() {
   cd "$(dirname "$0")"
   chmod +x TerrariaServer/1441/Linux/TerrariaServer.bin.x86_64
   TerrariaServer/1441/Linux/TerrariaServer.bin.x86_64 -config serverconfig.txt
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
            # 更新的功能， 
            ;;
        7)
            # 卸载的功能， 
            ;;
        *)
            echo "无效的选项，请重新输入！"
            ;;
    esac
    echo # 输出一个空行
#done

