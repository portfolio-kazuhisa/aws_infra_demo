# ---------------------------------------------
# Terraform configuration
# ---------------------------------------------
terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# ---------------------------------------------
# Provider
# ---------------------------------------------
provider "aws" {
  #profile = "terraform"
  region  = "ap-northeast-1"
}

####################################################
# module モジュールを呼び出す
# ユースケース：引数の値を指定する
# 　　　　　　　sourceでどのモジュールを呼び出すかを指定する
####################################################
module "ec2" {
  source      = "./modules/ec2"
  project     = "portfolio"
  environment = "dev"

  instance_type = "t2.micro"                     #引数の値をここで指定する
  subnet_id     = module.vpc.public_subnet_1a_id #vpc/output.tfから受け取る。
  app_sg_id     = module.sg.app_sg_id
  mng_sg_id     = module.sg.mng_sg_id
}

module "elb" {
  source      = "./modules/elb"
  project     = "portfolio"
  environment = "dev"

  target_ec2_id = module.ec2.ec2_id
  vpc_id        = module.vpc.vpc_id
  web_sg_id     = module.sg.web_sg_id
  subnet_id_1a  = module.vpc.public_subnet_1a_id #vpc/output.tfから受け取る。
  subnet_id_1c  = module.vpc.public_subnet_1c_id #vpc/output.tfから受け取る。
}

#module "rds" {
#  project = "portfolio"
#  environment = "dev"
#  source = "./modules/rds"
#}

#module "s3" {
#  source      = "./modules/s3"
#  project     = "portfolio"
#  environment = "dev"
#}

module "sg" {
  source      = "./modules/sg"
  project     = "portfolio"
  environment = "dev"

  vpc_id = module.vpc.vpc_id
}

module "dns" {
  source      = "./modules/dns"
  project     = "portfolio"
  environment = "dev"
  DomainName  = "portfolio-kazuhisa.com"

  elb = module.elb.elb
}

module "vpc" {
  source      = "./modules/vpc"
  project     = "portfolio"
  environment = "dev"
}
