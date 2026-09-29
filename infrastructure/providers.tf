# infrastructure/providers.tf

terraform {
  backend "s3" {
    bucket = "survey-api-tfstate-sujal" # Put your unique bucket name here
    key    = "state/terraform.tfstate"
    region = "ap-south-1"
  }
}