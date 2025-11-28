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
# launch template
#  起動テンプレートだとサブネットは指定できないみたい。
# ---------------------------------------------
resource "aws_launch_template" "app_lanch_template" {
  update_default_version = true #自動UPDATE
  name                   = "${var.project}-${var.environment}-app-lanch-template"
  #イメージIDはdata.tfで参取得していれる。
  image_id = data.aws_ami.app.id
  key_name = aws_key_pair.keypair.key_name
  tag_specifications {
    resource_type = "instance"
    tags = {
      name = "${var.project}-${var.environment}-app"
    }
  }

  network_interfaces {
    associate_public_ip_address = true #パブリックIPが自動で割り当て。インターネット接続可能
    security_groups = [
      var.app_sg_id,
      var.mng_sg_id
    ]
    delete_on_termination = true # ec2削除時にネットワーク削除
  }

  iam_instance_profile {
    name = var.ec2_profile
  }
  #Terraformのaws_launch_templateリソースでは、user_dataはBase64エンコード済みの文字列である必要あり
  user_data = filebase64("${path.module}/user_data.sh")
}

# ---------------------------------------------
# auto scaling
# ---------------------------------------------
resource "aws_autoscaling_group" "app_asg" {
  name = "${var.project}-${var.environment}-app-asg"

  max_size         = 2
  min_size         = 1
  desired_capacity = 1

  # ヘルスチェックの間隔　EC2が正常に起動したあとにヘルスチェックを行う。
  health_check_grace_period = 120
  health_check_type         = "ELB"

  vpc_zone_identifier = [
    var.subnet_id_1a,
    var.subnet_id_1c
  ]

  target_group_arns = [
    var.target_group_arn
  ]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.app_lanch_template.id
        version            = "$Latest"
      }
      override {
        instance_type = "t2.micro"
      }
    }
  }
}

# ターゲット追跡ポリシー CPU60パーセント基準
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.project}-${var.environment}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0   # CPU使用率を60%前後に維持
  }
}