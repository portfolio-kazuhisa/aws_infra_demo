# aws ec2 describe-images --image-ids ami-00d1d099505d27e87
# 既存のリソースからデーターを取得する

data "aws_ami" "app" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.9.*.0-kernel-6.12-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_instances" "app_asg" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = ["portfolio-dev-app-asg"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

output "app_asg_instance_ids" {
  value = data.aws_instances.app_asg.ids
}