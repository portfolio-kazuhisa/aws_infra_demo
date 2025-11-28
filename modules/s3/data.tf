data "aws_prefix_list" "s3_pl" {

  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.ap-northeast-1.s3"]

  }
}