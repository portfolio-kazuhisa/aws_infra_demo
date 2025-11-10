# Terraform CI/CD Workflow

このリポジトリは、Terraform を用いた AWS インフラの自動デプロイと破棄を GitHub Actions 上で安全かつ再試行可能に実行する CI/CD パイプラインを提供します。

## 概要

このワークフローは、`deploy_mode` ファイルの変更をトリガーにして以下の処理を実行します：

- Terraform の初期化、検証、プラン、適用（CI ジョブ）
- 適用に失敗した場合、自動的に `terraform destroy` を実行（destroy ジョブ）

## トリガー条件

```yaml
on:
  push:
    paths:
      - '**/deploy_mode'
```

- `deploy_mode` ファイルが変更されたときにのみ実行されます。
- `workflow_dispatch` はコメントアウトされており、手動実行は無効です。

## 権限と環境変数

```yaml
permissions:
  id-token: write
  contents: read

env:
  AWS_REGION: ap-northeast-1
  TF_VERSION: 1.13.3
```

- OIDC による AWS 認証を使用。
- Terraform バージョンと AWS リージョンは環境変数で管理。

## CI ジョブの構成

| ステップ | 説明 |
|---------|------|
| Checkout | リポジトリのコードを取得 |
| Setup Terraform | 指定バージョンの Terraform をセットアップ |
| AWS 認証 | OIDC を用いて IAM ロールを引き受け |
| Init | `terraform init -upgrade` により Provider を最新化 |
| Validate | Terraform 構文の検証 |
| Plan | 実行プランの作成 |
| Apply | 最大3回まで再試行する `terraform apply` |

```bash
for i in {1..3}; do
  terraform apply -auto-approve && break
  echo "Retry Apply"
  sleep 60
done
```

## Destroy ジョブの構成

- `CI` ジョブが失敗した場合のみ実行されます。
- 同様に最大3回まで `terraform destroy` を再試行。

```bash
for i in {1..3}; do
  terraform destroy -auto-approve && break
  echo "Retry destroy"
  sleep 60
done
```

## 再試行ロジックの意図

- AWS API の一時的な失敗や Terraform の競合を回避するため、`apply` と `destroy` に再試行処理を導入。
- `sleep 60` により、AWS 側の整合性待ち時間を確保。

## IAM ロールの設定

GitHub Actions から AWS にアクセスするには、以下のような IAM ロールが必要です：

- OIDC プロバイダーを設定済み
- `secrets.AWS_IAM_ROLE_ARN` にロール ARN を登録

## ディレクトリ構成の前提

このワークフローは `deploy_mode` ファイルの存在を前提としています。Terraform モジュールや `main.tf` の配置は任意ですが、`working-directory` は未指定です。必要に応じてコメントアウトを解除してください。

---

## 今後の改善ポイント

- `workflow_dispatch` を有効化して手動実行を可能にする
- `terraform plan` の出力を PR コメントに投稿するステップの追加
- `apply` 成功時に Slack 通知を送るなどの通知連携

