#!/usr/bin/bash

# 导入配置文件
source config.sh

# 显示ASCII艺术标志
show_banner() {
    clear
    echo -e "${GREEN}"
    echo '   ██████╗██╗   ██╗██████╗ ███████╗██████╗ '
    echo '  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗'
    echo '  ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝'
    echo '  ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗'
    echo '  ╚██████╗   ██║   ██████╔╝███████╗██║  ██║'
    echo '   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝'
    echo -e "${NC}"
    echo -e "${YELLOW}==== 渗透测试工具自动下载器 v2.0 ====${NC}\n"
}

# 添加错误处理函数
handle_error() {
    local exit_code=$?
    local error_message=$1
    echo -e "${RED}[!] 错误: ${error_message} (错误代码: ${exit_code})${NC}" | tee -a "$LOG_FILE"
}

# 改进的安装依赖函数
install_dependencies() {
    echo -e "${YELLOW}[*] 正在安装基本依赖...${NC}" | tee -a "$LOG_FILE"
    if ! apt-get update; then
        handle_error "更新包列表失败"
        while true; do
            read -p "是否重试更新包列表 (y/n)? " retry
            case $retry in
                y|Y)
                    if apt-get update; then
                        break
                    else
                        handle_error "更新包列表失败"
                    fi
                    ;;
                n|N)
                    echo -e "${YELLOW}[!] 跳过更新包列表，尝试更新或替换软件源...${NC}" | tee -a "$LOG_FILE"
                    update_or_replace_sources
                    if ! apt-get update; then
                        handle_error "更新包列表失败，无法继续安装依赖"
                        return 1
                    fi
                    break
                    ;;
                *)
                    echo -e "${RED}[!] 无效的选择，请输入 y 或 n${NC}"
                    ;;
            esac
        done
    fi

    local deps=(git wget curl build-essential python3 python3-pip)
    for dep in "${deps[@]}"; do
        echo -e "${BLUE}[*] 正在安装 ${dep}...${NC}" | tee -a "$LOG_FILE"
        if ! apt-get install -y "$dep"; then
            handle_error "安装 ${dep} 失败"
            return 1
        fi
    done
    echo -e "${GREEN}[+] 基本依赖安装完成${NC}" | tee -a "$LOG_FILE"
}

# 更新或替换软件源函数
update_or_replace_sources() {
    echo -e "${YELLOW}[*] 尝试更新或替换软件源...${NC}" | tee -a "$LOG_FILE"
    
    # 备份原始 sources.list 文件
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    echo -e "${GREEN}[+] 备份原始 sources.list 文件完成${NC}" | tee -a "$LOG_FILE"
    
    # 移除有问题的仓库
    if grep -q "https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/kali-rolling pgadmin4 main" /etc/apt/sources.list; then
        sudo sed -i 's|https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/kali-rolling pgadmin4 main|#&|g' /etc/apt/sources.list
        echo -e "${GREEN}[+] 有问题的 pgadmin4 仓库已移除${NC}" | tee -a "$LOG_FILE"
    fi

    if [[ -f /etc/apt/sources.list.d/pgadmin4.list ]]; then
        sudo sed -i 's|https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/kali-rolling pgadmin4 main|#&|g' /etc/apt/sources.list.d/pgadmin4.list
        echo -e "${GREEN}[+] 有问题的 pgadmin4 仓库已移除${NC}" | tee -a "$LOG_FILE"
    fi

    # 替换软件源为默认的 Kali Linux 软件源
    echo -e "${YELLOW}[*] 替换软件源为默认的 Kali Linux 软件源...${NC}" | tee -a "$LOG_FILE"
    cat <<EOF | sudo tee /etc/apt/sources.list
deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware
deb-src http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware
EOF
    echo -e "${GREEN}[+] 软件源替换完成${NC}" | tee -a "$LOG_FILE"
}

# 添加工具安装前的检查函数
check_prerequisites() {
    # 检查是否为root用户
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[!] 此脚本需要root权限运行${NC}" | tee -a "$LOG_FILE"
        exit 1
    fi
    
    # 检查工作目录
    if [[ ! -d "$WORK_DIR" ]]; then
        echo -e "${YELLOW}[*] 创建工作目录 ${WORK_DIR}${NC}" | tee -a "$LOG_FILE"
        mkdir -p "$WORK_DIR"
        echo -e "${GREEN}[+] 工作目录创建完成${NC}" | tee -a "$LOG_FILE"
    fi
    
    # 检查网络连接
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${YELLOW}[!] 警告: 网络连接可能不稳定${NC}" | tee -a "$LOG_FILE"
    fi
}

# 添加日志记录函数
log_action() {
    local message=$1
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" | tee -a "$LOG_FILE"
}

# 添加清理函数
cleanup() {
    echo -e "${YELLOW}[*] 正在清理临时文件...${NC}" | tee -a "$LOG_FILE"
    rm -f /tmp/*.tmp
    echo -e "${GREEN}[+] 清理完成${NC}" | tee -a "$LOG_FILE"
}

# 通用工具安装函数
install_tool() {
    local tool_name=$1
    local install_command=${TOOLS[$tool_name]}

    echo -e "${YELLOW}[*] 正在安装 ${tool_name}...${NC}" | tee -a "$LOG_FILE"
    cd "$WORK_DIR" || { handle_error "无法进入工作目录"; return 1; }
    if ! eval "$install_command"; then
        handle_error "${tool_name} 安装失败"
        return 1
    fi
    echo -e "${GREEN}[+] ${tool_name} 安装完成${NC}" | tee -a "$LOG_FILE"
}

# 显示主菜单
show_menu() {
    echo -e "\n${BLUE}=== 工具类别 ===${NC}"
    for key in "${!TOOL_MENUS[@]}"; do
        echo "$key. ${TOOL_MENUS[$key]}"
    done
    echo "0. 退出"
}

# 显示工具菜单
show_tool_menu() {
    local category=$1
    echo -e "\n${BLUE}=== ${TOOL_MENUS[$category]} ===${NC}"
    echo -e "${TOOL_DETAILS[$category]}"
    echo "0. 返回主菜单"
}

# 处理用户输入
handle_user_input() {
    local prompt=$1
    read -p "$prompt" choice
    echo "$choice"
}

# 获取工具名称
get_tool_name() {
    local category=$1
    local tool_index=$2
    echo -e "${TOOL_DETAILS[$category]}" | sed "${tool_index}q;d" | awk '{print $2}'
}

# 安装工具
install_tools_in_category() {
    local category=$1
    while true; do
        show_tool_menu "$category"
        tool=$(handle_user_input "请选择要安装的工具 (0-9): ")

        if [[ $tool == "0" ]]; then
            break
        else
            tool_name=$(get_tool_name "$category" "$tool")
            if [[ -n "${TOOLS[$tool_name]}" ]]; then
                install_tool "$tool_name"
                log_action "安装了 ${TOOL_MENUS[$category]} 工具 #$tool"
            else
                echo -e "${RED}[!] 无效的选择${NC}" | tee -a "$LOG_FILE"
            fi
        fi
    done
}

# 主函数
main() {
    show_banner
    check_prerequisites
    install_dependencies || exit 1
    
    trap cleanup EXIT
    
    while true; do
        show_menu
        category=$(handle_user_input "请选择工具类别 (0-10): ")

        if [[ $category == "0" ]]; then
            break
        elif [[ -n "${TOOL_MENUS[$category]}" ]]; then
            install_tools_in_category "$category"
        else
            echo -e "${RED}[!] 无效的选择${NC}" | tee -a "$LOG_FILE"
        fi
    done
}

# 启动脚本
main

# 添加上传功能选项
TOOL_MENUS["12"]="项目上传管理"
TOOL_DETAILS["12"]="1.上传到GitHub仓库\n2.配置仓库信息\n3.查看上传状态"

echo "12) 项目上传管理"
