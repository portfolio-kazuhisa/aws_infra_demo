# EC2インスタンス & Key Pair Terraform構成

この構成は、Amazon Linux 2023をベースにしたEC2インスタンスを起動し、SSH接続用のKey PairをTerraformで管理するための設定です。

## なぜKey PairとEC2が必要なのか？

Terraformでインフラをコード管理する際、EC2インスタンスへのSSH接続を可能にするKey Pairは必須です。手動で作成したKey Pairを使うと、環境ごとの再現性が損なわれるため、TerraformでKey Pairを管理することで、環境ごとの一貫性と自動化が実現できます。

また、EC2インスタンスはアプリケーションの実行環境として利用され、ALBやRoute53と連携することで、スケーラブルでアクセス可能な構成を構築できます。

## 構成概要

| リソース | 説明 |
|----------|------|
| `aws_key_pair.keypair` | SSH接続用の公開鍵を登録し、Key Pairを作成 |
| `aws_instance.app_server` | Amazon Linux 2023ベースのEC2インスタンスを起動 |
| `data.aws_ami.app` | 最新のAmazon Linux 2023 AMIをフィルタ条件で取得 |

## Key Pairの作成

```hcl
resource "aws_key_pair" "keypair" {
  key_name   = "${var.project}-${var.environment}-keypair"
  public_key = file("${path.module}/key-pair/dev-keypair.pub")

  tags = {
    Name    = "${var.project}-${var.environment}-keypair"
    Project = var.project
    Env     = var.environment
  }
}
```

Terraform管理下でKey Pairを作成することで、環境ごとのSSH接続設定をコードで管理できます。`public_key`には事前に作成した公開鍵ファイルを指定します。

## EC2インスタンスの起動

```hcl
resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.app.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = aws_key_pair.keypair.key_name
  associate_public_ip_address = true
  iam_instance_profile        = var.ec2_profile
  vpc_security_group_ids      = [var.app_sg_id, var.mng_sg_id]

  tags = {
    Name = "${var.project}-${var.environment}-mysql_client"
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    INDEX_FILE = "/var/www/html/index.html"
  })
}
```

このインスタンスは、指定されたサブネットに配置され、パブリックIPが自動割り当てされるため、インターネットからのアクセスが可能です。`user_data`を使って初期セットアップも自動化されています。

## AMIの取得

```hcl
data "aws_ami" "app" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.9.*.0-kernel-6.12-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

Amazon Linux 2023の最新AMIをフィルタ条件で取得します。AMIのバージョンやカーネル条件を指定することで、安定した環境を確保できます。

---

## 注意点

- `public_key` に指定するファイルは事前に作成しておく必要があります。
- `associate_public_ip_address = true` により、パブリックIPが割り当てられますが、セキュリティグループの設定も忘れずに。
- `user_data` による初期設定は、インスタンス初回起動時のみ実行されます。
- AMIフィルタはバージョン更新に注意し、定期的に見直すことをおすすめします。