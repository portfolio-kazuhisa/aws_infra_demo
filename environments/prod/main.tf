# ---------------------------------------------
# Terraform configuration
# ---------------------------------------------
terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #AWSプロバイダーバージョン設定（terraformのバージョンではない）
      #GitHub Actionsのプロバイダーも　initの際に -updateオプションを使うとプロバイダー更新できる
      version = "~> 6.0"
    }
  }

  # tfstateを管理するためのバックエンドS3を認識する。
  backend "s3" {
    bucket       = "prod-portfolio-tfstate-bucket" # リリース対象とは別のアカウントのS3バケットに保存することが推奨される
    key          = "prod.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}

# ---------------------------------------------
# Provider
# ---------------------------------------------
provider "aws" {
  # profile はローカル専用の設定であり、CI環境にはそのプロファイルが存在しないので、コメントアウト。
  # profile = "terraform"
  region = "ap-northeast-1"
}

####################################################
# 共通変数
####################################################
locals {
  project     = "portfolio"
  environment = "prod"
}

####################################################
# module モジュールを呼び出す
# ユースケース：引数の値を指定する
# 　　　　　　　sourceでどのモジュールを呼び出すかを指定する
####################################################
module "ec2" {
  source      = "../../modules/ec2"
  project     = local.project
  environment = local.environment

  instance_type    = "t2.micro"
  subnet_id_1a     = module.vpc.public_subnet_1a_id
  subnet_id_1c     = module.vpc.public_subnet_1c_id
  app_sg_id        = module.sg.app_sg_id
  mng_sg_id        = module.sg.mng_sg_id
  ec2_profile      = module.iam.ec2_profile
  target_group_arn = module.elb.target_group_arn
}

module "cloudfront" {
  source      = "../../modules/cloudfront"
  project     = local.project
  environment = local.environment

  domain                         = module.dns.a_record.fqdn
  elb_name                       = module.elb.elb.name
  s3_bucket_id                   = module.s3.s3_id
  s3_bucket_regional_domain_name = module.s3.s3.bucket_regional_domain_name
  zone_id                        = module.dns.host_zone.id
  virginia_cert                  = module.acm.virginia_cert.arn
}

module "elb" {
  source      = "../../modules/elb"
  project     = local.project
  environment = local.environment

  target_ec2_id  = module.ec2.ec2_id
  vpc_id         = module.vpc.vpc_id
  web_sg_id      = module.sg.web_sg_id
  subnet_id_1a   = module.vpc.public_subnet_1a_id #vpc/output.tfから受け取る。
  subnet_id_1c   = module.vpc.public_subnet_1c_id #vpc/output.tfから受け取る。
  tokyo_cert_arn = module.acm.tokyo_cert.arn
}

module "iam" {
  source      = "../../modules/iam"
  project     = local.project
  environment = local.environment
}

module "rds" {
  source      = "../../modules/rds"
  project     = local.project
  environment = local.environment

  subnet_id_1a = module.vpc.public_subnet_1a_id
  subnet_id_1c = module.vpc.public_subnet_1c_id
  rds_sg_id    = module.sg.rds_sg_id

}

module "s3" {
  source      = "../../modules/s3"
  project     = local.project
  environment = local.environment

  cf_s3_origin_access_identity_iam_arn = module.cloudfront.cf_s3_origin_access_identity_iam_arn
}

module "sg" {
  source      = "../../modules/sg"
  project     = local.project
  environment = local.environment

  vpc_id = module.vpc.vpc_id
}

module "dns" {
  source      = "../../modules/dns"
  project     = local.project
  environment = local.environment
  DomainName  = "portfolio-kazuhisa.com"

  elb = module.elb.elb
}

module "vpc" {
  source      = "../../modules/vpc"
  project     = local.project
  environment = local.environment
}

module "acm" {
  source            = "../../modules/acm"
  project     = local.project
  environment = local.environment
  validation_method = "DNS"
  DomainName        = "portfolio-kazuhisa.com"

  zone_id   = module.dns.host_zone.id
  host_zone = module.dns.host_zone
}
