# ---------------------------------------------
# key-pair
# ---------------------------------------------
resource "aws_key_pair" "keypair" {
  key_name   = "${var.project}-${var.environment}-keypair"
  public_key = file("${path.module}/key-pair/dev-keypair.pub")

  tags = {
    Name    = "${var.project}-${var.environment}-keypair"
    Project = var.project
    Env     = var.environment
  }
}

# ---------------------------------------------
# EC2 instance
# ---------------------------------------------
resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.app.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id #インスタンスを配置するサブネットのID
  key_name                    = aws_key_pair.keypair.key_name
  associate_public_ip_address = true #パブリックIPが自動で割り当て。インターネット接続可能

  #iamモジュールのインスタンスプロフィールをEC2にアタッチする。
  iam_instance_profile = var.ec2_profile

  #適用するセキュリティグループのID
  vpc_security_group_ids = [
    var.app_sg_id,
    var.mng_sg_id
  ]

  tags = {
    Name = "${var.project}-${var.environment}-mysql_client"
  }

  #初回実行時
  user_data = templatefile("${path.module}/user_data.sh", {
    INDEX_FILE = "/var/www/html/index.html"
  })
}
