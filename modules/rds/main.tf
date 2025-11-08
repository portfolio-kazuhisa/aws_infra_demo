# ---------------------------------------------
# RDS parameter group
# RDSインスタンスの動作を制御するための「設定」
# 個別で設定値を変更可能。
# ---------------------------------------------
resource "aws_db_parameter_group" "mysql_standalone_parametergroup" {
  # パラメータグループ本体を作成
  name   = "${var.project}-${var.environment}-mysql-standalone-parametergroup"
  family = "mysql8.0"

  # 新規DBのデフォルト文字コード → utf8mb4
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

# ---------------------------------------------
# RDS option group
# ---------------------------------------------
resource "aws_db_option_group" "mysql_standalone_optiongroup" {
  name                 = "${var.project}-${var.environment}-mysql-standalone-optiongroup"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

# ---------------------------------------------
# RDS subnet group
# ---------------------------------------------
resource "aws_db_subnet_group" "mysql_standalone_subnetgroup" {
  name = "${var.project}-${var.environment}-mysql-standalone-subnetgroup"
  # DB設置場所を選択
  subnet_ids = [
    var.subnet_id_1a,
    var.subnet_id_1c
  ]

  tags = {
    Name    = "${var.project}-${var.environment}-mysql-standalone-subnetgroup"
    Project = var.project
    Env     = var.environment
  }
}

# ---------------------------------------------
# RDS instance
# ---------------------------------------------
resource "random_string" "db_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "mysql_standalone" {
  # DBインスタンス識別子
  identifier = "${var.project}-${var.environment}-mysql-standalone"

  # 認証情報
  username = "admin"
  password = random_string.db_password.result #パスワードはtfstateに保存されるので、tfstateを.gitignoreに入れること。

  #基本設定
  engine                = "mysql"
  engine_version        = "8.0.42"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = false

  #AZ構成・ネットワーク関連
  multi_az               = false             #本当はAZ構成にすべき。自己学習のコスト削減のため。
  availability_zone      = "ap-northeast-1a" #マルチAZでない場合必須。terraformは判断できない。
  db_subnet_group_name   = aws_db_subnet_group.mysql_standalone_subnetgroup.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false
  port                   = 3306

  # DB名
  db_name = "${var.project}_${var.environment}_DB"

  # パラメータグループ・オプショングループアタッチ
  parameter_group_name = aws_db_parameter_group.mysql_standalone_parametergroup.name
  option_group_name    = aws_db_option_group.mysql_standalone_optiongroup.name

  backup_window              = "04:00-05:00" #いつバックアップを取るか
  backup_retention_period    = 7             #バックアップ保管期間
  maintenance_window         = "Mon:05:00-Mon:08:00"
  auto_minor_version_upgrade = false

  deletion_protection = false #誤削除防止
  skip_final_snapshot = true  #削除時バックアップ本当はtrueすべき。自己開発用にコストを削減。
  apply_immediately   = true  #即時反映

  tags = {
    Name    = "${var.project}-${var.environment}-mysql-standalone"
    Project = var.project
    Env     = var.environment
  }
}
