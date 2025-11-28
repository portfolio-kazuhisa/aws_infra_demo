# ALB & Target Group Terraform構成

この構成は、AWS Application Load Balancer（ALB）を構築し、EC2インスタンスをターゲットとしてトラフィックを分散させるためのTerraform設定です。

## なぜALBが必要なのか？

EC2インスタンスはスケーリングや再起動によってIPアドレスが変わる可能性があります。ALBを導入することで、安定したアクセスエンドポイントを提供し、複数のインスタンスへの負荷分散やヘルスチェックによる可用性向上が可能になります。

また、HTTPS対応により、セキュアな通信を実現できます。

## ALBの作成

```hcl
resource "aws_lb" "alb" {
  name               = "${var.project}-${var.environment}-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_sg_id]
  subnets            = [var.subnet_id_1a, var.subnet_id_1c]
}
```

ALBはインターネット向けに公開され、複数AZにまたがるサブネットに配置されます。セキュリティグループはWebアクセス用のものを指定します。

## リスナーの設定

### HTTPリスナー（ポート80）

```hcl
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}
```

HTTPリクエストはターゲットグループにフォワードされます。

### HTTPSリスナー（ポート443）

```hcl
resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.tokyo_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}
```

HTTPSリスナーではSSL証明書を指定し、セキュアな通信を実現します。コメントアウトされたポリシーは、TLS 1.3やFIPS対応など、より厳格なセキュリティ要件に対応するための選択肢です。

## ターゲットグループの作成とアタッチ

```hcl
resource "aws_lb_target_group" "alb_target_group" {
  name     = "${var.project}-${var.environment}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name    = "${var.project}-${var.environment}-app-tg"
    Project = var.project
    Env     = var.environment
  }
}
```

```hcl
resource "aws_lb_target_group_attachment" "instance" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = var.target_ec2_id
}
```

ターゲットグループはHTTPポートで構成され、指定されたVPC内のEC2インスタンスをターゲットとして登録します。

---

