# ACM & Route53 Terraform Configuration

AWS上でACM証明書を発行し、Route53を使ってDNS検証を行うためのものです。

CloudFrontで使用するため、東京リージョンとバージニアリージョン両方に証明書を作成します。

## なぜACMが必要なのか

route53で名前解決を行いました。このまま接続してもhttpで接続してしまいます。
httpではssl/tlsで暗号化されていないので、セキュリティリスクが高いです。
したがって、https接続を行えるようにする必要があります。

そのためにACMが必要になってきます。
ACMはssl/tlsを使用したHTTPS通信が可能になります。
HTTPSはHTTPとは異なり「盗聴防止」「なりすまし防止」「改ざん防止」を実現してくれます。

![https](../../png/acm/https.png)

## ACM証明書の発行

### 東京リージョン

```hcl
resource "aws_acm_certificate" "tokyo_cert" {
  domain_name       = "*.${var.DomainName}"
  validation_method = var.validation_method
  ...
}
```
DNS レコードを追加して検証を行います。
今回であれば、人手を介さずに自動でDNS検証を行うため、DNSという値を変数に定義しております。Route53でレコードはすでに作成しているため、自動検証が可能になります。

```hcl
  lifecycle {
    create_before_destroy = true
  }
```

通常 Terraform は「古いリソースを削除してから新しいリソースを作成」します。
しかし create_before_destroy = true を指定すると、順序が逆になり
1. 新しいリソースを先に作成
2. 作成が成功してから 古いリソースを削除

という動きになります。

ロードバランサーの証明書や DNS レコードなど、削除してから作り直すと一時的にサービスが止まる可能性があるため、作成してから削除することによりダウンタイムを削減することができます。

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
 今回の構築ではCloudFrontを使用しますがCloudFrontの仕様で、TLS証明書はバージニア北部に存在していないと使えないっていうルールがあるため、証明書を`us-east-1`に作成しています。
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

こちらの記述に関しては、terraform consoleモードで証明書の値が確認できるので、そのコンソールからfor each文で直接動的にとるということをやっています。

この記述がないと証明書のバリデーションができません。


## 証明書検証完了

```hcl
resource "aws_acm_certificate_validation" "cert_valid" {
  certificate_arn         = aws_acm_certificate.tokyo_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_acm_dns_resolve : record.fqdn]
}
```

DNS検証が完了すると、ACM証明書が有効化されます。

