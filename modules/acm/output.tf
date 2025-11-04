####################################################
# output モジュールの出力結果を取り出す
# ユースケース：他の Terraform モジュールやステージへの値の受け渡し
# 　　　　　　　CI/CD や外部スクリプトへの値の引き渡し
####################################################

output "tokyo_cert" {
  value = aws_acm_certificate.tokyo_cert
}

output "virginia_cert" {
  value = aws_acm_certificate.virginia_cert
}

output "route53_acm_dns_resolve" {
  value = aws_route53_record.route53_acm_dns_resolve
}

output "cert_valid" {
  value = aws_acm_certificate_validation.cert_valid
}