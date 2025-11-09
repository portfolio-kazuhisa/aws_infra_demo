# ACM & Route53 Terraform Configuration

AWS上でACM証明書を発行し、Route53を使ってDNS検証を行うためのものです。

CloudFrontで使用するため、東京リージョンとバージニアリージョン両方に証明書を作成します。

## 構成概要

| リソース | 説明 |
|----------|------|
| `aws_acm_certificate.tokyo_cert` | 東京リージョン用のACM証明書 |
| `aws_route53_record.route53_acm_dns_resolve` | DNS 検証用のCNAMEレコード |
| `aws_acm_certificate_validation.cert_valid` | DNS 検証の完了処理 |
| `aws_acm_certificate.virginia_cert` | CloudFront用のACM証明書 |
| `provider.aws.virginia` | us-east-1用のプロバイダー設定 |


## ACM証明書の発行

### 東京リージョン

```hcl
resource "aws_acm_certificate" "tokyo_cert" {
  domain_name       = "*.${var.DomainName}"
  validation_method = var.validation_method
  ...
}
```

- `create_before_destroy` により証明書の更新時にダウンタイムを防止。
- `depends_on = [var.host_zone]` により、DNSゾーン作成後に証明書を発行。

### バージニア北部

```hcl
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

resource "aws_acm_certificate" "virginia_cert" {
  provider = aws.virginia
  domain_name = "*.${var.DomainName}"
  ...
}
```
 - CloudFrontの仕様で、TLS証明書はバージニア北部に存在していないと使えないっていうルールがある。
 - 証明書を`us-east-1`に作成する。
 >参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html

---

## DNS 検証（Route53）

```hcl
resource "aws_route53_record" "route53_acm_dns_resolve" {
  for_each = {
    for dvo in aws_acm_certificate.tokyo_cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  ...
}
```

- `for_each` を使って複数ドメインの検証レコードを動的に作成。
- `allow_overwrite = true` により既存レコードとの競合を防止。

## 証明書検証完了

```hcl
resource "aws_acm_certificate_validation" "cert_valid" {
  certificate_arn         = aws_acm_certificate.tokyo_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_acm_dns_resolve : record.fqdn]
}
```

- DNS 検証が完了すると、ACM 証明書が有効化されます。

## 注意点

- `depends_on` にリスト形式を使わないとエラーになります。Terraform は単体の値を `string` や `object` として解釈しようとするためです。
- CloudFront で使用する証明書は **必ず us-east-1 に配置**してください。
- `domain_name` にワイルドカード（`*.`）を使うことで、サブドメイン全体をカバーできます。


## 変数・出力


##  補足

- Terraform v1.6+ および AWS Provider v6.0+ に対応。
- `configuration_aliases` を使ってプロバイダーを明示的に切り替えています。


