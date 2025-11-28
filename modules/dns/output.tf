####################################################
# output モジュールの出力結果を取り出す
# ユースケース：他の Terraform モジュールやステージへの値の受け渡し
# 　　　　　　　CI/CD や外部スクリプトへの値の引き渡し
####################################################

output "host_zone" {
  value = aws_route53_zone.route53_zone
}

output "a_record" {
  value = aws_route53_record.route53_A_record
}