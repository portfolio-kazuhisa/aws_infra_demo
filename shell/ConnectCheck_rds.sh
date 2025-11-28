#!/bin/bash
###############################################
# !!!!!!!!!!!!!!!!!!注意!!!!!!!!!!!!!!!!!!
# セキュリティの観点から、パスワードを文字列として変数化することは推奨していません。
# パラメーターストアなどを使って取得し安全に接続することをお勧めします。
#
# 〇用途
# 個人で手軽に確認
# Git BashでDB接続確認できるように作成。
# terraform applyをした後に実行する。
###############################################
# ANSIカラーコード
COLOR='\033[0;32m'
NC='\033[0m' # 色リセット

DB_PORT=$(terraform state show module.rds.aws_db_instance.mysql_standalone | awk '$1 == "port" {print $3}')
DB_ENDPOINT=$(terraform state show module.rds.aws_db_instance.mysql_standalone | awk '$1 == "address" {print $3}' | tr -d '"')
DB_USERNAME=$(terraform state show module.rds.aws_db_instance.mysql_standalone | awk '/username/ {print $3}' | tr -d '"')
DB_PASSWORD=$(terraform state show module.rds.random_string.db_password | awk '/result/ {print $3}' | tr -d '"')

echo -e "DB_PORT     : ${COLOR}${DB_PORT}${NC}"
echo -e "DB_ENDPOINT : ${COLOR}${DB_ENDPOINT}${NC}"
echo -e "DB_USERNAME : ${COLOR}${DB_USERNAME}${NC}"
echo -e "DB_PASSWORD : ${COLOR}${DB_PASSWORD}${NC}"

echo -e "\n以下のコマンドを実行してください"
echo -e "mysql -h ${COLOR}${DB_ENDPOINT}${NC} -P ${COLOR}${DB_PORT}${NC} -u ${COLOR}${DB_USERNAME}${NC} -p"
echo -e "パスワードを求められたら、以下を入力"
echo -e "${COLOR}${DB_PASSWORD}${NC}"


