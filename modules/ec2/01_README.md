# EC2 Auto Scaling Terraform Configuration

AWS 上で EC2 インスタンスを起動し、Auto Scaling Group によるスケーリングを行うための構成です。  
Key Pair を利用して SSH 接続を可能にし、Launch Template で起動設定を定義、Auto Scaling Group によってインスタンス数を動的に調整します。さらに Target Tracking Policy により CPU 使用率を 60% 前後に維持するようにスケールイン／アウトを自動化します。

---

## Key Pair

```hcl
resource "aws_key_pair" "keypair" {
  key_name   = "${var.project}-${var.environment}-keypair"
  public_key = file("${path.module}/key-pair/dev-keypair.pub")
  ...
}
```

- SSH 接続用の公開鍵を AWS に登録。
- `tags` によりプロジェクト名や環境を明示。

---

## Launch Template

```hcl
resource "aws_launch_template" "app_lanch_template" {
  name     = "${var.project}-${var.environment}-app-lanch-template"
  image_id = data.aws_ami.app.id
  key_name = aws_key_pair.keypair.key_name
  ...
}
```

- 起動テンプレートで AMI, Key Pair, Security Group, IAM Profile を定義。
- `user_data` は **Base64 エンコード済み**のスクリプトを指定。
- `network_interfaces` によりパブリック IP の付与や SG の設定を行う。

---

## Auto Scaling Group

```hcl
resource "aws_autoscaling_group" "app_asg" {
  name             = "${var.project}-${var.environment}-app-asg"
  min_size         = 1
  max_size         = 2
  desired_capacity = 1
  ...
}
```

- サブネットを指定して複数 AZ に配置。
- `health_check_type = "ELB"` によりロードバランサー経由でヘルスチェック。
- `mixed_instances_policy` を利用し、起動テンプレートとインスタンスタイプを柔軟に指定可能。

---

## Target Tracking Policy

```hcl
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}
```

- Auto Scaling Group の平均 CPU 使用率を監視。
- **60% 前後に維持するようにスケールイン／アウト**を自動で実施。
- `min_size` により下限台数は維持されるため、完全にゼロにはならない。

---
