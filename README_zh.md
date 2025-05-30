# 渗透测试工具自动下载器

<div align="center">

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg?style=flat-square)](README.md)

[English](README_en.md) | [简体中文](README_zh.md) | [Русский](README_ru.md)

</div>

---

## 简介
本工具专为渗透测试人员和网络安全学习者设计，通过自动化脚本一键下载安装常用渗透测试工具，解决手动搜索、下载、配置的繁琐流程，帮助快速搭建测试环境。支持多语言界面（中文/英文/俄文），兼容Linux和macOS系统。🛠️

## 功能特点
- **自动安装基础依赖**：会预先检查并安装`git`、`curl`、`build-essential`等必要工具（具体依赖列表见`config.sh`）📦
- **多类别工具支持**：覆盖信息收集（如Nmap）、漏洞扫描（如OpenVAS）、Web测试（如Burp Suite）、密码破解（如John the Ripper）等10+主流类别🔍
- **智能错误处理**：安装失败时会提示具体错误代码（如网络超时/权限不足），并保留失败工具的临时文件以便排查⚠️
- **详细安装日志**：所有操作记录保存在`install_log.txt`，包含时间戳、工具名称、安装状态（成功/失败）和关键输出📝
- **自动清理机制**：安装完成后自动删除下载的压缩包/克隆的仓库临时文件，仅保留正式安装目录🗑️

## 使用方法
1. **检查权限**：终端输入`whoami`，确认显示`root`（非root用户需输入`sudo su`切换）⚒️
2. **运行脚本**：打开终端进入脚本目录，执行命令：`sudo ./自动下载渗透工具.sh`（首次运行会自动更新APT源）
3. **选择类别**：看到彩色菜单后（例：1.信息收集 2.漏洞扫描...），输入对应数字回车
4. **安装工具**：在子菜单中选择具体工具（如输入1安装Nmap），等待进度条完成即可
（注：菜单支持中文/英文/俄文切换，运行时按`L`键选择语言）

## 注意事项
- **网络要求**：部分工具需从GitHub/GitLab下载（如Mimikatz），国内用户建议配置代理（可在`config.sh`中设置`PROXY_ADDR`）🌐
- **系统建议**：推荐使用Kali Linux 2024.1及以上版本（已预安装大部分依赖），其他系统可能需要手动安装`libssl-dev`等额外包🔍
- **安装目录**：工具默认安装至`/opt/pentest_tools/[工具名]`，可修改`config.sh`中的`INSTALL_DIR`自定义路径📂
- **日志查看**：安装问题可查看同目录下的`install_log.txt`，用`cat install_log.txt | grep "ERROR"`快速定位错误
