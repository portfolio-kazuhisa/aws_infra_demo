####################################################
# ACM
####################################################

resource "aws_acm_certificate" "tokyo_cert" {
  domain_name       = "*.${var.DomainName}"
  validation_method = var.validation_method

  tags = {
    Name    = "${var.project}-${var.environment}-acm"
    Project = var.project
    Env     = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }

  #リソース間の依存関係を明示的に指定するため
  #明示的に順序を制御したいのでdepends_onを使用
  #ACM証明書のDNS検証に必要なゾーンが先に作成される
  #depends_on = [var.host_zone]

  #depends_on = aws_route53_zone.route53_zone # []つけへんとエラーになる
  # →　単体の値（stringやobject）として解釈しようとして失敗
}

####################################################
# DNS Verification for CNAME(route53)
####################################################

resource "aws_route53_record" "route53_acm_dns_resolve" {
  for_each = {
    for dvo in aws_acm_certificate.tokyo_cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id         = var.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 600
  records         = [each.value.record]
}

resource "aws_acm_certificate_validation" "cert_valid" {
  certificate_arn         = aws_acm_certificate.tokyo_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_acm_dns_resolve : record.fqdn]
}