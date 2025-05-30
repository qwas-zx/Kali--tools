#!/bin/bash

# 检查jq依赖
check_dependencies() {
  if ! command -v jq &> /dev/null; then
    echo "❌ 检测到缺少依赖: jq"
    read -p "是否立即安装? [Y/n] " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
      apt-get update && apt-get install -y jq
    else
      echo "✋ 请手动安装jq后重试: sudo apt-get install jq"
      exit 1
    fi
  fi
}

# 配置文件路径
CONFIG_PATH="upload_config.json"

# 读取JSON配置
read_config() {
  jq -r '.' "$CONFIG_PATH"
}

# 检查必需文件
check_requirements() {
  echo "📝 检查必需文件..."
  jq -r '.files.required[] | .path' "$CONFIG_PATH" | while read -r path; do
    if [ ! -f "$path" ]; then
      echo "❌ 文件不存在: $path"
      exit 1
    fi
    if jq -e --arg path "$path" '.files.required[] | select(.path == $path and .executable == true)' "$CONFIG_PATH" > /dev/null; then
      chmod +x "$path"
    fi
  done
  echo "✅ 所有必需文件已找到"
}

# 配置Git信息
configure_git() {
  echo "📝 配置Git用户信息..."
  if [ -z "$(git config --global user.name)" ]; then
    read -p "请输入Git用户名: " username
    git config --global user.name "$username"
  fi
  if [ -z "$(git config --global user.email)" ]; then
    read -p "请输入Git邮箱: " email
    git config --global user.email "$email"
  fi
}

# 创建.gitignore
create_gitignore() {
  echo "📝 创建.gitignore..."
  jq -r '.ignore_patterns[]' "$CONFIG_PATH" > .gitignore
}

# Git推送逻辑
git_push() {
  echo "🚀 正在推送代码到GitHub..."
  for i in {1..3}; do
    if git push -u origin "$(jq -r '.git.initial_branch' "$CONFIG_PATH")"; then
      echo "✅ 推送成功"
      return 0
    else
      echo "⚠️ 第$i次推送失败，10秒后重试"
      sleep 10
    fi
  done
  echo "❌ 推送失败，请检查网络连接或权限"
  return 1
}

# 主执行流程
main() {
  check_dependencies
  config=$(read_config) || exit 1
  check_requirements
  configure_git
  create_gitignore
  
  if [ ! -d .git ]; then
    git init
    git add .
    git commit -m "$(jq -r '.git.commit_message' "$CONFIG_PATH")"
    git branch -M "$(jq -r '.git.initial_branch' "$CONFIG_PATH")"
    git remote add "$(jq -r '.git.remote.name' "$CONFIG_PATH")" \
      "$(jq -r '.git.remote.url' "$CONFIG_PATH" | sed 's/\/$//')"
    git_push || exit 1
  else
    echo "ℹ️  Git仓库已存在，跳过初始化"
    git_push || exit 1
  fi
}

main "$@"