####################################################
# output モジュールの出力結果を取り出す
# ユースケース：他の Terraform モジュールやステージへの値の受け渡し
# 　　　　　　　CI/CD や外部スクリプトへの値の引き渡し
####################################################

#このoutputは、第三者機関にNSレコードを登録するためにわざわざコンソールでレコードを確認するのは面倒なので、自動的に見れないかなと思って作成したものです。
#考えてみれば、このoutputが出力されるのはデプロイ後になるので不要と考え、削除予定です。
#代わりにAWS CLIで取得してすぐに第三者機関に登録できるようにする仕組みを考えています。
output "ns_records_val" {
  value = distinct(module.dns.host_zone.name_servers)
}

output "cname_records_hostname" {
  value = [for dvo in module.acm.tokyo_cert.domain_validation_options : dvo.resource_record_name]
}

output "cname_records_val" {
  value = [for dvo in module.acm.tokyo_cert.domain_validation_options : dvo.resource_record_value]
}

