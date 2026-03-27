data "aws_caller_identity" "current" {}

locals {
  stream_name = "strean"
  lambda_name = "analysisparalysis"
  bucket = "dinofartingchickadee"
  account_id = data.aws_caller_identity.current.account_id
  region = "us-east-2"
  table_name = "shoebill"
}

provider "aws" {
  region = local.region

  # This block is the magic part
  default_tags {
    tags = {
      Project     = "Kinesis-Analytics"
      Environment = "Development"
      Owner       = "Data-Team"
      ManagedBy   = "Terraform"
    }
  }
}

module permission {
  source = "./modules/permission"
  stream = local.stream_name
  lambda = local.lambda_name
  bucket = local.bucket
  key = module.security.key_arn
  region = local.region
  account_id = local.account_id
  table_name = local.table_name
}

module "security" {
  source = "./modules/security"
  account_id = local.account_id
}

module "storage" {
  source = "./modules/storage"
  bucket_name = local.bucket
  kms_key = module.security.key_arn
}

module "lambda" {
  source = "./modules/compute"
  lambda_role = module.permission.lambda_role
  dynamo_tablename = local.table_name
  stream = local.stream_name
  region = local.region
  account_id = local.account_id
  stream_arn = module.stream.stream_arn
}

module "dynamo" {
  source = "./modules/datastore"
  table_name = local.table_name
  key_arn = module.security.key_arn
}

module "stream" {
  source = "./modules/kinesis"
  stream_name = local.stream_name
  key_arn = module.security.key_arn
}