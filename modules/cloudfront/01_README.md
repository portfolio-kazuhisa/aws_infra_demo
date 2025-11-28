# CloudFront

AWS上でACM証明書を発行し、Route53を使ってDNS検証を行うためのものです。

CloudFrontで使用するため、東京リージョンとバージニアリージョン両方に証明書を作成します。

## なぜCloudFrontが必要なのか



## 

### 東京リージョン

```hcl
resource "aws_acm_certificate" "tokyo_cert" {
  domain_name       = "*.${var.DomainName}"
  validation_method = var.validation_method
  ...
}
```
