terraform {
  backend "s3" {
    bucket = "terraform-infrastructure-for-unified-project"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
