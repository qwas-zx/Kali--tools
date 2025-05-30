#!/bin/bash

# 硬编码配置参数
GIT_USER="qwas-zx"
GIT_EMAIL="2807224393@qq.com"
INIT_BRANCH="main"
REMOTE_URL="git@github.com:qwas-zx/kali--tools.git"

# 检查必需文件
check_requirements() {
  echo "📝 检查必需文件..."
  # 假设必需文件路径是硬编码的
  for path in "path/to/required/file1" "path/to/required/file2"; do
    if [ ! -f "$path" ]; then
      echo "❌ 文件不存在: $path"
      exit 1
    fi
    if [ "$path" == "path/to/executable/file1" ] || [ "$path" == "path/to/executable/file2" ]; then
      chmod +x "$path"
    fi
  done
  echo "✅ 所有必需文件已找到"
}

# 配置Git信息
configure_git() {
  echo "📝 配置Git用户信息..."
  if [ -z "$(git config --global user.name)" ]; then
    git config --global user.name "$GIT_USER"
    git config --global user.email "$GIT_EMAIL"
  fi
}

# Git推送逻辑
git_push() {
  echo "🚀 正在推送代码到GitHub..."
  for i in {1..3}; do
    if git push -u origin "$INIT_BRANCH"; then
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
  # 移除配置文件检查
  configure_git
  # 移除 create_gitignore 调用
  check_requirements

  if [ ! -d .git ]; then
    git init
    git add .
    git commit -m "Initial automated commit"
    git branch -M "$INIT_BRANCH"
    git remote add origin "$REMOTE_URL"
    git_push || exit 1
  else
    echo "ℹ️  Git仓库已存在，跳过初始化"
    git_push || exit 1
  fi
}

main "$@"
