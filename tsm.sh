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
    echo "0. 下载服务器"
    echo "1. 启动服务器"
    echo "2. 停止服务器"
    echo "3. 重启服务器"
    echo "4. 查看配置信息"
    echo "5. 更新"
    echo "6. 卸载"
}

function download_server() {
    url="https://terraria.wiki.gg/wiki/Server#Downloads"

    # 发送GET请求获取HTML页面，并使用grep提取所有带有href属性的链接
    html_content=$(curl -s "$url")
    href_links=$(echo "$html_content" | grep -o '<a[^>]*href="[^"]*"[^>]*>')

    # 保存版本号到数组中
    versions=()
    while IFS= read -r line; do
        url=$(echo "$line" | grep -o 'href="[^"]*"' | cut -d'"' -f2)
        if [[ $url == https://terraria.org/api/download/pc-dedicated-server/* ]]; then
            version=$(echo "$url" | awk -F'/' '{print $NF}' | cut -d'-' -f3)
            versions+=("$version")
        fi
    done <<< "$href_links"

    # 显示前10条最新版本
    echo "可用的服务器版本列表："
    for ((i=0; i<${#versions[@]}; i++)); do
        if [ $i -ge 10 ]; then
            break
        fi
        echo "$((i+1)). 版本 ${versions[$i]}"
    done

    echo "请选择要下载的服务器版本 (输入相应数字):"
    read version_choice

    case $version_choice in
        1)
            server_version="1.0" # 设置服务器版本为 1.0
            ;;
        2)
            server_version="1.1" # 设置服务器版本为 1.1
            ;;
        3)
            server_version="1.2" # 设置服务器版本为 1.2
            ;;
        # 在这里添加更多版本的处理...

        0)
            echo "返回主菜单。"
            return
            ;;
        *)
            echo "无效的选项，请重新输入！"
            download_server # 重新调用下载服务器函数以重新选择版本
            return
            ;;
    esac

    # 在这里添加根据选择的版本进行下载的逻辑
    # 假设服务器文件下载链接按照版本命名，比如 "https://example.com/terraria-server-$server_version.tar.gz"
    # 使用 "wget" 下载服务器文件
    # echo "正在下载服务器版本 $server_version ..."
    # wget -q "https://example.com/terraria-server-$server_version.tar.gz" -P "/path/to/download/directory"

    # # 假设下载的文件名为 "terraria-server-$server_version.tar.gz"
    # # 在实际情况中，您可能需要解压缩文件或进行其他设置
    # # 示例解压缩文件：
    # tar -xzf "/path/to/download/directory/terraria-server-$server_version.tar.gz" -C "/path/to/terraria-server-directory"

    # echo "服务器版本 $server_version 下载完成！"
}


# 主循环
while true; do
    display_menu
    echo "请输入选项:"
    read option
    case $option in
        0)
            download_server # 调用下载服务器函数
            ;;
        1)
            # 启动服务器的功能， 
            ;;
        2)
            # 停止服务器的功能， 
            ;;
        3)
            # 重启服务器的功能， 
            ;;
        4)
            # 查看配置信息的功能， 
            ;;
        5)
            # 更新的功能， 
            ;;
        6)
            # 卸载的功能， 
            ;;
        *)
            echo "无效的选项，请重新输入！"
            ;;
    esac
    echo # 输出一个空行
done

