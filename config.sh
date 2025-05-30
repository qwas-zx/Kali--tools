#!/bin/bash

# 配置文件 config.sh

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 日志文件和工作目录
LOG_FILE="install_log.txt"
WORK_DIR="/opt/pentest_tools"

# 工具配置
declare -A TOOLS=(
    ["Nmap"]="apt-get install -y nmap"
    ["Whois"]="apt-get install -y whois"
    ["Recon-ng"]="git clone --depth 1 https://github.com/lanmaster53/recon-ng.git"
    ["OpenVAS"]="apt-get install -y openvas"
    ["Nikto"]="apt-get install -y nikto"
    ["OWASP_ZAP"]="apt-get install -y zaproxy"
    ["SQLMap"]="apt-get install -y sqlmap"
    ["Burp_Suite"]="apt-get install -y burpsuite"
    ["Aircrack-ng"]="apt-get install -y aircrack-ng"
    ["Wireshark"]="apt-get install -y wireshark"
    ["Kismet"]="apt-get install -y kismet"
    ["SecLists"]="git clone --depth 1 https://github.com/danielmiessler/SecLists.git"
    ["Hydra"]="apt-get install -y hydra"
    ["John_the_Ripper"]="apt-get install -y john"
    ["Hashcat"]="apt-get install -y hashcat && wget -O $WORK_DIR/rockyou.txt.gz https://github.com/praetorian-inc/Hob0Rules/raw/master/wordlists/rockyou.txt.gz && gunzip -c $WORK_DIR/rockyou.txt.gz > $WORK_DIR/rockyou.txt && rm $WORK_DIR/rockyou.txt.gz"
    ["WiFi-Hacker"]="git clone --depth 1 https://github.com/esc0rtd3w/wifi-hacker.git && chmod +x $WORK_DIR/wifi-hacker/wifi-hacker.sh"
    ["RouterSploit"]="git clone --depth 1 https://github.com/threat9/routersploit.git && cd $WORK_DIR/routersploit && python3 -m pip install -r requirements.txt && cd .."
    ["Crunch"]="apt-get install -y crunch"
    ["CUPP"]="git clone --depth 1 https://github.com/Mebus/cupp.git && chmod +x $WORK_DIR/cupp/cupp.py"
    ["RainbowCrack"]="apt-get install -y rainbowcrack"
    ["IDA_Pro"]="git clone --depth 1 https://github.com/idapro/ida-6.9.git"
    ["Ghidra"]="git clone https://github.com/NationalSecurityAgency/ghidra.git && cd $WORK_DIR/ghidra && ./gradlew build && cd .."
    ["Radare2"]="apt-get install -y radare2"
    ["BeRoot"]="git clone --depth 1 https://github.com/AlessandroZ/BeRoot.git"
    ["Linux_Smart_Enumeration"]="git clone --depth 1 https://github.com/diego-treitos/linux-smart-enumeration.git"
    ["Windows-Exploit-Suggester"]="git clone --depth 1 https://github.com/GDSSecurity/Windows-Exploit-Suggester.git"
    ["Metasploit"]="apt-get install -y metasploit-framework"
    ["Empire"]="git clone --depth 1 https://github.com/EmpireProject/Empire.git && cd $WORK_DIR/Empire/setup && ./install.sh && cd .."
    ["Mimikatz"]="git clone --depth 1 https://github.com/gentilkiwi/mimikatz.git && chmod +x $WORK_DIR/mimikatz/mimikatz.exe"
    ["SET"]="apt-get install -y set"
    ["Social-Engineer_Toolkit"]="git clone --depth 1 https://github.com/trustedsec/social-engineer-toolkit.git"
    ["Autopsy"]="apt-get install -y autopsy"
    ["Volatility"]="apt-get install -y volatility"
    ["The_Sleuth_Kit"]="apt-get install -y sleuthkit"
    ["sqlsus"]="apt-get install -y sqlsus"
    ["wpscan"]="git clone --depth 1 https://github.com/wpscanteam/wpscan.git && cd $WORK_DIR/wpscan && bundle install && rake install"
    ["fern-wifi-cracker"]="git clone --depth 1 https://github.com/savio-code/fern-wifi-cracker.git"
    ["netdiscover"]="apt-get install -y netdiscover"
    ["dnsenum"]="apt-get install -y dnsenum"
    ["enum4linux"]="apt-get install -y enum4linux"
    ["smbmap"]="apt-get install -y smbmap"
    ["snmpwalk"]="apt-get install -y snmpwalk"
    ["yersinia"]="apt-get install -y yersinia"
    ["macchanger"]="apt-get install -y macchanger"
    ["nbtscan"]="apt-get install -y nbtscan"
    ["mitmproxy"]="apt-get install -y mitmproxy"
    ["tcpdump"]="apt-get install -y tcpdump"
    ["ettercap"]="apt-get install -y ettercap"
    ["dsniff"]="apt-get install -y dsniff"
    ["tshark"]="apt-get install -y tshark"
    ["sipvicious"]="apt-get install -y sipvicious"
    ["commix"]="apt-get install -y commix"
    ["beef"]="git clone --depth 1 https://github.com/beefproject/beef.git && cd $WORK_DIR/beef && ./install"
    ["theharvester"]="apt-get install -y theharvester"
)

# 工具菜单配置
declare -A TOOL_MENUS=(
    ["1"]="信息收集工具"
    ["2"]="漏洞扫描工具"
    ["3"]="Web应用测试工具"
    ["4"]="无线网络测试工具"
    ["5"]="密码攻击工具"
    ["6"]="逆向工程工具"
    ["7"]="权限提升工具"
    ["8"]="后渗透工具"
    ["9"]="社会工程学工具"
    ["10"]="取证分析工具"
    ["11"]="网络流量分析工具"
)

# 工具详细配置
declare -A TOOL_DETAILS=(
    ["1"]="1.Nmap\n2.Whois\n3.Recon-ng\n4.Amass\n5.Masscan\n6.theharvester\n7.dnsenum\n8.netdiscover\n9.nbtscan"
    ["2"]="1.OpenVAS\n2.Nikto\n3.Nessus\n4.wpscan\n5.sqlsus\n6.commix"
    ["3"]="1.OWASP_ZAP\n2.SQLMap\n3.Burp_Suite\n4.Dirb\n5.Gobuster\n6.BeEF"
    ["4"]="1.Aircrack-ng\n2.Wireshark\n3.Kismet\n4.fern-wifi-cracker\n5.macchanger\n6.Reaver"
    ["5"]="1.SecLists\n2.Hydra\n3.John_the_Ripper\n4.Hashcat\n5.WiFi-Hacker\n6.RouterSploit\n7.Crunch\n8.CUPP\n9.RainbowCrack"
    ["6"]="1.IDA_Pro\n2.Ghidra\n3.Radare2\n4.Volatility"
    ["7"]="1.BeRoot\n2.Linux_Smart_Enumeration\n3.Windows-Exploit-Suggester"
    ["8"]="1.Metasploit\n2.Empire\n3.Mimikatz\n4.CrackMapExec"
    ["9"]="1.SET\n2.Social-Engineer_Toolkit\n3.Mitmproxy"
    ["10"]="1.Autopsy\n2.The_Sleuth_Kit\n3.tshark\n4.tcpdump"
    ["11"]="1.tcpdump\n2.tshark\n3.dsniff\n4.mitmproxy"
)


# 配置文件版本
CONFIG_VERSION="2.1"
CONFIG_UPDATE_URL="https://github.com/qwas-zx/kali--tools/config.sh"

# 版本检查函数
check_config_update() {
    echo -e "${YELLOW}[*] 正在检查配置文件更新...${NC}"
    remote_version=$(curl -s $CONFIG_UPDATE_URL | grep "CONFIG_VERSION=" | cut -d'"' -f2)
    [ "$CONFIG_VERSION" != "$remote_version" ] && {
        echo -e "${RED}[!] 发现新版本配置文件 (v$remote_version)${NC}"
        return 1
    }
    return 0
}