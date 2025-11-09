# 1.概要

このリポジトリはAWSでWEBアプリケーションを展開するためのインフラをterraformやGitHubActisonsなどで自動構築することを目的としたポートフォリオです。

※個人学習用のため若干本番で運用するには推薦できないものもありますので、コメントとして推薦事項等記載しております。

# 2.使用技術
  - **AWS**
    - VPC
    - EC2(AmazonLinux2023)
    - Route53
    - ACM
    - ELB
    - IAM
    - RDS
    - S3
  - **terraform**
  - **bash**
  - **GitHub Actions**

# 3.全体構成図

構成は高可用性とセキュリティを重視して設計されています。2つのAZに分散配置することで、障害時の冗長性を確保しています。

ELBで各AZのEC2インスタンスにトラフィックを分散します。RDSはプライベートサブネット内に配置し、外部からの直接アクセスを防いでいます。

![Architecture](png/Architecture.png)

# 4.機能一覧/非機能一覧



# 5.詳細設計

[アプリケーションサーバ（EC2）](modules/ec2/README.md)

```bash
#!/bin/bash

echo "Hello, "
aws s3 ls s3://my-bucket --recursive | grep '.tfstate'
```

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket"
  acl    = "private"
}
```

# 6.今後の課題

# 7.参考元

このポートフォリオは、*Udemy* の「AWS × Terraform 実践講座」を参考に構築しました。一部構成やコードは教材をベースにしていますが、独自に変更・拡張を加えています。