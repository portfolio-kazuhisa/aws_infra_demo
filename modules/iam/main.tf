# ---------------------------------------------
# IAM Role
# ---------------------------------------------
resource "aws_iam_role" "app_iam_role" {
  name               = "${var.project}-${var.environment}-app-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" { #EC2がS3にアクセスするためのロール
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "app_iam_role_s3_PutBucketPolicy" { #S3バケットポリシー
  role = aws_iam_role.app_iam_role.name  # アタッチしたいロール名（上に書いてある）を指定する。
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess" # マネジメントコンソールのポリシーで確認
}