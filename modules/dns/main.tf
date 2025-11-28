####################################################
# Route53 hostzone
####################################################

resource "aws_route53_zone" "route53_zone" {
  name          = var.DomainName
  force_destroy = false #terraform管理外のレコードを削除するかを指定する項目
  tags = {
    Name    = "${var.project}-${var.environment}-app-tg"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_route53_record" "route53_A_record" {
  zone_id = aws_route53_zone.route53_zone.id
  name    = "alb.${var.DomainName}"
  type    = "A"

  alias {
    name                   = var.elb.dns_name
    zone_id                = var.elb.zone_id
    evaluate_target_health = true
  }
}