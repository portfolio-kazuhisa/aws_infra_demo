# ---------------------------------------------
# EC2 instance
# ---------------------------------------------
resource "aws_instance" "app_server" {
  ami                         = "ami-0712bf5b0a7138d17"
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id #インスタンスを配置するサブネットのID
  key_name                    = "portfolio-dev-key"
  associate_public_ip_address = true #パブリックIPが自動で割り当て。インターネット接続可能
  #iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [
    #適用するセキュリティグループのID
    var.app_sg_id,
    var.mng_sg_id
  ]

  tags = {
    Name = "${var.project}-${var.environment}-mysql_client"
  }

  #初回実行時
  user_data = templatefile("${path.module}/user_data.sh", {})
}
