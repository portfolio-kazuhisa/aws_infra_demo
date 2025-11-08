# ---------------------------------------------
# IAM Role
# 本モジュールでサービスへのアタッチは行えない。
# サービスにアタッチしたい場合はサービスモジュールで指定する
# ---------------------------------------------
# EC2 は IAM ロールを直接認識できないため、
# インスタンスプロフィールを通じて、STSから一時認証情報を取得する必要がある
# 参考情報：https://qiita.com/torifukukaiou/items/eb82619303a9156a8d02
# EC2専用のロール＝インスタンスプロフィールと考える
resource "aws_iam_instance_profile" "app_ec2_profile" {
  name = aws_iam_role.app_iam_role.name
  role = aws_iam_role.app_iam_role.name
}

resource "aws_iam_role" "app_iam_role" {
  name               = "${var.project}-${var.environment}-app-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# EC2 インスタンスが IAM ロールを引き受けるための信頼ポリシー
# EC2 に IAM ロール（インスタンスプロフィール）をアタッチするには、EC2 がそのロールを引き受ける権限を持っている必要がある。
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"] # ロールを受け入れる。

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ---------------------------------------------
# role_policy_attachment
# ---------------------------------------------
# ロールにアタッチしたいポリシーを指定
resource "aws_iam_role_policy_attachment" "app_iam_role_ec2_readonly" {
  role       = aws_iam_role.app_iam_role.name                    #アタッチ対象ロール名
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess" #ARNをマネジメントコンソールで確認
}

resource "aws_iam_role_policy_attachment" "app_iam_role_ssm_managed" {
  role       = aws_iam_role.app_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "app_iam_role_ssm_readonly" {
  role       = aws_iam_role.app_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "app_iam_role_s3_readonly" {
  role       = aws_iam_role.app_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}