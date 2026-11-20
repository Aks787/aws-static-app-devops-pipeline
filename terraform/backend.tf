terraform {
  backend "s3" {
    bucket       = "bucket-for-static-web-page-deployment"
    key          = "terraform/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
