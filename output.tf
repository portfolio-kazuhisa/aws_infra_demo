####################################################
# output モジュールの出力結果を取り出す
# ユースケース：他の Terraform モジュールやステージへの値の受け渡し
# 　　　　　　　CI/CD や外部スクリプトへの値の引き渡し
####################################################

output "ns_records_val" {
  value = distinct(module.dns.host_zone.name_servers)
}

output "cname_records_hostname" {
  value = [for dvo in module.acm.tokyo_cert.domain_validation_options : dvo.resource_record_name]
}

output "cname_records_val" {
  value = [for dvo in module.acm.tokyo_cert.domain_validation_options : dvo.resource_record_value]
}
