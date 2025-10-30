####################################################
# ACM
####################################################

resource "aws_acm_certificate" "acm" {
  domain_name       = var.DomainName
  validation_method = var.validation_method

  tags = {
    Name    = "${var.project}-${var.environment}-acm"
    Project = var.project
    Env     = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }

  #リソース間の依存関係を明示的に指定するため
  #明示的に順序を制御したいのでdepends_onを使用
  #ACM証明書のDNS検証に必要なゾーンが先に作成される
  #depends_on = [aws_route53_zone.route53_zone]

  depends_on = var.route53_zone # []つけへんとエラーになる
  # →　単体の値（stringやobject）として解釈しようとして失敗

}