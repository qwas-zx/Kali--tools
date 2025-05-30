#!/usr/bin/env python3

import json
import os
import sys
import subprocess
from pathlib import Path
import stat

class RepoUploader:
    def __init__(self, config_path="upload_config.json"):
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                self.config = json.load(f)
        except FileNotFoundError:
            print(f"❌ 配置文件 {config_path} 不存在")
            sys.exit(1)
        except json.JSONDecodeError:
            print(f"❌ 配置文件 {config_path} 格式错误")
            sys.exit(1)

    def check_requirements(self):
        """检查所有必需文件是否存在"""
        print("📝 检查必需文件...")
        for file in self.config['files']['required']:
            path = Path(file['path'])
            print(f"检查文件: {path} (是否存在: {path.exists()})")
            if not path.exists():
                raise FileNotFoundError(f"必需文件不存在: {path}")
            if file.get('executable', False):
                self.make_executable(path)
        print("✅ 所有必需文件已找到")

    def make_executable(self, path):
        """设置文件为可执行"""
        current = stat.S_IMODE(os.lstat(path).st_mode)
        os.chmod(path, current | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    def configure_git(self):
        """配置 Git 用户名和电子邮件地址"""
        print("📝 配置 Git 用户名和电子邮件地址...")
        try:
            user_name = subprocess.run(['git', 'config', '--global', 'user.name'], capture_output=True, text=True)
            user_email = subprocess.run(['git', 'config', '--global', 'user.email'], capture_output=True, text=True)

            if not user_name.stdout.strip():
                print("❌ Git 用户名未配置")
                user_name_input = input("请输入 Git 用户名: ")
                subprocess.run(['git', 'config', '--global', 'user.name', user_name_input], check=True)
                print(f"✅ Git 用户名已配置为: {user_name_input}")

            if not user_email.stdout.strip():
                print("❌ Git 电子邮件地址未配置")
                user_email_input = input("请输入 Git 电子邮件地址: ")
                subprocess.run(['git', 'config', '--global', 'user.email', user_email_input], check=True)
                print(f"✅ Git 电子邮件地址已配置为: {user_email_input}")
        except subprocess.CalledProcessError as e:
            print(f"❌ 配置 Git 失败: {e}")
            sys.exit(1)

    def create_gitignore(self):
        """创建.gitignore文件"""
        print("📝 创建.gitignore文件...")
        try:
            with open('.gitignore', 'w', encoding='utf-8') as f:
                f.write('\n'.join(self.config['ignore_patterns']))
            print("✅ .gitignore文件已创建")
        except IOError as e:
            print(f"❌ 无法创建.gitignore文件: {e}")
            sys.exit(1)

    def is_git_repo_initialized(self):
        """检查 Git 仓库是否已初始化"""
        try:
            subprocess.run(['git', 'rev-parse', '--git-dir'], check=True, capture_output=True)
            return True
        except subprocess.CalledProcessError:
            return False

    def is_git_add_run(self):
        """检查是否已经运行过 git add ."""
        try:
            # 检查是否有未暂存的更改
            result = subprocess.run(['git', 'status', '--porcelain'], capture_output=True, text=True)
            return not result.stdout.strip()
        except subprocess.CalledProcessError:
            return False

    def init_repo(self):
        """初始化Git仓库"""
        print("🚀 初始化Git仓库...")
        try:
            if not self.is_git_repo_initialized():
                subprocess.run(['git', 'init'], check=True)
                print("✅ Git 仓库已初始化")
            else:
                print("✅ Git 仓库已存在，跳过初始化")

            if not self.is_git_add_run():
                subprocess.run(['git', 'add', '.'], check=True)
                print("✅ 文件已添加到 Git 暂存区")
            else:
                print("✅ 文件已添加到 Git 暂存区，跳过 git add .")

            subprocess.run(['git', 'commit', '-m', self.config['git']['commit_message']], check=True)
            print("✅ 提交完成")

            # 确保使用正确的初始分支名称
            initial_branch = self.config['git']['initial_branch']
            subprocess.run(['git', 'branch', '-M', initial_branch], check=True)
            print("✅ 分支名称已设置为: main")

            # 添加远程仓库前先删除已有origin
            try:
                subprocess.run(['git', 'remote', 'remove', self.config['git']['remote']['name']], check=True)
            except subprocess.CalledProcessError:
                pass  # 如果远程不存在则忽略错误
            subprocess.run(['git', 'remote', 'add',
                             self.config['git']['remote']['name'],
                             self.config['git']['remote']['url']], check=True)
            print("✅ 远程仓库已添加")

            subprocess.run(['git', 'push', '-u', 
                             self.config['git']['remote']['name'],
                             initial_branch], check=True)
            print("✅ 推送完成")
        except subprocess.CalledProcessError as e:
            print(f"❌ 执行命令失败: {' '.join(e.cmd)}")
            raise e

    def upload(self):
        """执行完整的上传流程"""
        try:
            print("🚀 开始上传流程...")
            self.check_requirements()
            self.configure_git()
            self.create_gitignore()
            self.init_repo()
            print("✅ 上传完成！")
        except Exception as e:
            print(f"❌ 上传失败: {str(e)}")
            sys.exit(1)

if __name__ == "__main__":
    uploader = RepoUploader()
    uploader.upload()
