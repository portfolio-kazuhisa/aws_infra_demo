####################################################
# output モジュールの出力結果を取り出す
# ユースケース：他の Terraform モジュールやステージへの値の受け渡し
# 　　　　　　　CI/CD や外部スクリプトへの値の引き渡し
####################################################
output "s3" {
  value = aws_s3_bucket.s3_static_bucket
}
output "s3_id" {
  value = aws_s3_bucket.s3_static_bucket.id
}