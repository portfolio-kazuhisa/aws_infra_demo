####################################################
# output モジュールの出力結果を取り出す
# ユースケース：他の Terraform モジュールやステージへの値の受け渡し
# 　　　　　　　CI/CD や外部スクリプトへの値の引き渡し
####################################################
output "elb_id" {
  value = aws_lb.alb.id
}

output "elb" {
  value = aws_lb.alb
}

output "target_group_arn" {
  value = aws_lb_target_group.alb_target_group.arn
}