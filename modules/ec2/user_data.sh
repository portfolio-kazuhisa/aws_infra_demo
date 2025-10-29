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
