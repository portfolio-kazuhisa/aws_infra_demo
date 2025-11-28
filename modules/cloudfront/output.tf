####################################################
# output モジュールの出力結果を取り出す
# ユースケース：他の Terraform モジュールやステージへの値の受け渡し
# 　　　　　　　CI/CD や外部スクリプトへの値の引き渡し
####################################################

output "cf_s3_origin_access_identity_iam_arn" {
  value = aws_cloudfront_origin_access_identity.cf_s3_origin_access_identity.iam_arn
}