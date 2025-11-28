# ACM & Route53 Terraform Configuration

AWS上でACM証明書を発行し、Route53を使ってDNS検証を行うためのものです。

CloudFrontで使用するため、東京リージョンとバージニアリージョン両方に証明書を作成します。

## なぜACMが必要なのか

route53で名前解決を行いました。このまま接続してもhttpで接続してしまいます。
httpではssl/tlsで暗号化されていないので、セキュリティリスクが高いです。
したがって、https接続を行えるようにする必要があります。

…httpの画像を貼る。

そのためにACMが必要になってきます。
ACMは…作成中


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

- DNS検証が完了すると、ACM証明書が有効化されます。

