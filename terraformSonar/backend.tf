terraform {
  backend "s3" {
    bucket = "lgr-storing-tfstate"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}