terraform {
  backend "s3" {
    bucket         = "jobtracker-terraform"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "jobtracker-locks"
  }
}