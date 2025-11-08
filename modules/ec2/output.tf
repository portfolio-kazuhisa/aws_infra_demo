####################################################
# output モジュールの出力結果を取り出す
# ユースケース：他の Terraform モジュールやステージへの値の受け渡し
# 　　　　　　　CI/CD や外部スクリプトへの値の引き渡し
####################################################
output "ec2_id" {
  value = aws_instance.app_server.id
}

output "ec2_ami" {
  value = aws_instance.app_server.ami
}

output "ami_data" {
  value = data.aws_ami.app
}