README作成中

〇今後の課題

・共通変数を使っていないので、各モジュールで定義されている変数がバラバラ

・outputの有効的な使い方がまだできていない。モジュールとして適切に使用されているかわからない。

・GitHub Actionsでのstate管理

・RDS/パラメーターストア
・cloudfront S3の権限見直し。

〇ディレクトリ構成
├── README.md
├── main.tf
├── output.tf
├── terraform.tfstate
├── terraform.tfstate.backup
├── graph.dot
├── local_valification.sh*
├── 全体設計図.png
├── logs
│   ├── result-20251102-121521.log
│   └── result-20251102-123022.log
├── shell
│   ├── ConnectCheck_rds.sh*
│   ├── Terraform_ConsoleOperation.sh
│   └── Git_Console_Operation.sh
└── modules
    ├── acm
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── dns
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── ec2
    │   ├── main.tf
    │   ├── output.tf
    │   ├── variables.tf
    │   └── shell
    │       └── user_data.sh*
    ├── elb
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── iam
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── rds
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── s3
    │   ├── data.tf
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── sg
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    └── vpc
        ├── main.tf
        ├── output.tf
        └── variables.tf