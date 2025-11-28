resource "random_string" "s3_unique_key" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

# ---------------------------------------------
# S3 static bucket
# ---------------------------------------------
resource "aws_s3_bucket" "s3_static_bucket" {
  bucket = "${var.project}-${var.environment}-static-bucket-${random_string.s3_unique_key.result}"
}

#ヴァージョ二ングの設定
resource "aws_s3_bucket_versioning" "s3_static_bucket_versioning" {
  bucket = aws_s3_bucket.s3_static_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_static_bucket" {
  bucket                  = aws_s3_bucket.s3_static_bucket.id
  block_public_acls       = true
  block_public_policy     = true # Create
  ignore_public_acls      = true
  restrict_public_buckets = true # Modify

  #バケットポリシーを作ってから、パブリックアクセスブロックを設定する「ポリシー適用 → 403で失敗 → public_access_block作成」
  #  depends_on = [
  #    aws_s3_bucket_policy.s3_static_bucket,
  #  ]
}

#バケットポリシー
resource "aws_s3_bucket_policy" "s3_static_bucket" {
  bucket = aws_s3_bucket.s3_static_bucket.id
  policy = data.aws_iam_policy_document.s3_static_bucket.json

  #「ブロック設定を反映してから、バケットポリシーを適用」
  #まずバケットを作成
  #「パブリックアクセスブロック設定」を開く
  #そのあとバケットポリシー
  depends_on = [
    aws_s3_bucket_public_access_block.s3_static_bucket, #　←　パブリックアクセスブロックを指定
  ]
}

# 既存のS3リソースにポリシーを生成
data "aws_iam_policy_document" "s3_static_bucket" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.s3_static_bucket.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [var.cf_s3_origin_access_identity_iam_arn]
    }
  }
}