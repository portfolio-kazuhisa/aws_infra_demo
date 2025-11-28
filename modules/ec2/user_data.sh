#!/bin/bash
# ---------------------------------
# Amazon Linux 2 用 user-data
# ---------------------------------

set -euo pipefail

INDEX_FILE=${1:-/var/www/html/index.html}

# ログを記録
exec > /var/log/user-data.log 2>&1
echo "user-data started at: $(date -u +"%Y-%m-%d %H:%M:%SZ")"

# ---------------------------------
# MySQL クライアントのインストール
# ---------------------------------
if ! command -v mysql >/dev/null 2>&1; then
  sudo dnf install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
  sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
  sudo dnf install -y mysql --nogpgcheck
else
  echo "mysql client already installed; skipping"
fi

# ---------------------------------
# Apache (httpd) のインストールと起動
# ---------------------------------
sudo dnf update -y || true
sudo dnf install -y httpd

# 有効化と起動
sudo systemctl enable --now httpd
sudo systemctl status httpd

# index.html に作成
if [ ! -f "${INDEX_FILE}" ] ; then
  echo "<h1>Web server running on EC2</h1>" | sudo tee "${INDEX_FILE}"
  echo "Created ${INDEX_FILE}"
fi

echo "user-data finished at: $(date -u +"%Y-%m-%d %H:%M:%SZ")"