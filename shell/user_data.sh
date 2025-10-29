#!/bin/bash
# ---------------------------------
# install MySQL_cliant
# ---------------------------------

# ログ出力設定
exec > /var/log/user-data.log 2>&1

sudo dnf install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
sudo dnf install -y mysql --nogpgcheck

# ---------------------------------
# install web
# ---------------------------------
sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
echo "<h1>Web server running on EC2</h1>" | sudo tee /var/www/html/index.html

# ---------------------------------
# install from S3
# ---------------------------------
#BUCKET_NAME=deploy20251017 
#CWD=/home/ec2-user

#cd ${CWD}
#aws s3 cp s3://${BUCKET_NAME}/test_hello.html ${CWD}

# ---------------------------------
# install from GitHub
# ---------------------------------

# 必要なパッケージをインストール
#yum update -y
#yum install -y git

# GitHub からクローン（例：パブリックリポジトリ）
#REPO_URL="https://github.com/ユーザー名/リポジトリ名.git"
#git clone ${REPO_URL}

# 所有権を ec2-user に変更
#REPO_DIR=$(basename ${REPO_URL} .git)
#chown -R ec2-user:ec2-user ${REPO_DIR}