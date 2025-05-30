# ฅ(＾・ω・＾ฅ) 渗透工具安装急救手册

| 症状特征               | 解决方法喵~                                                                 |
|------------------------|--------------------------------------------------------------------------|
| `E: 无法找到包`        | 1. 执行 `sudo apt update` 更新缓存✨<br>2. 使用 `apt search 包名` 查找正确名称  |
| `Connection timed out` | 🚀 临时换国内源：`sudo sed -i 's/http.kali.org/mirrors.aliyun.com/g' /etc/apt/sources.list` |
| `error: make failed`    | 📦 安装编译依赖：`sudo apt install build-essential libssl-dev`                             |
| `E: 无法修正错误，因为您要求某些软件包保持现状` | 🧩 智能修复：`sudo aptitude install 包名` （按n选择降级方案）|
| `W: 校验数字签名时出错` | 🔑 更新密钥：`wget -q -O - https://archive.kali.org/archive-key.asc | sudo apt-key add` |
| `磁盘空间不足` | 🧹 快速清理：`sudo apt clean && sudo journalctl --vacuum-size=100M` |
| `sudo: command not found` | 🐾 切root用户：先执行 `su -` 输入密码后再操作 |
| `segmentation fault (core dumped)` | 🔧 内存检测：`memtester 1G` 运行30分钟查坏内存条 |
| `E: Sub-process /usr/bin/dpkg returned an error code (1)` | 🛠 修复dpkg：`sudo dpkg --configure -a` |
| `E: 无法下载文件` | 🌐 检查网络连接：`ping http.kali.org` 确保网络正常，或更换源 |
| `E: 依赖关系问题` | 🔗 解决依赖：`sudo apt --fix-broken install` |
| `E: 软件包损坏` | 💥 重新安装软件包：`sudo apt reinstall 包名` |
| `E: 无法获取锁` | ⏳ 等待锁释放：`sudo fuser -v /var/lib/dpkg/lock` 查看锁定进程 |
| `E: 启动脚本失败` | 📚 检查日志：`sudo journalctl -xe` 查看详细日志信息 |
| `E: 无法找到命令` | 📜 更新环境变量：`source ~/.bashrc` 或 `source ~/.profile` |
| `E: 无法验证软件包的来源` | 🔗 添加软件源密钥：`sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 密钥ID` |
| `E: 无法找到文件` | 🗂 检查文件路径：确保文件路径正确，或重新下载文件 |
| `E: 文件损坏` | 🛠 修复文件：`sudo apt-get install --reinstall 包名` |
| `E: 无法找到依赖` | 📦 安装依赖：`sudo apt-get build-dep 包名` |
| `E: 无法找到软件包的版本` | 📜 指定版本：`sudo apt-get install 包名=版本号` |

新增彩蛋功能喵~ ヽ(✿ﾟ▽ﾟ)ノ
```bash
# 在troubleshooting.sh末尾追加
echo "\n💌 小贴士：定期执行『sudo apt autoremove』可以清理无用依赖哦~"
