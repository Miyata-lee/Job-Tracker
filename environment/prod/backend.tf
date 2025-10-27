terraform {
  backend "s3" {
    bucket         = "jobtracker-terraform"
    key            = "prod/terraform.tfstate"  
    region         = "us-east-1"
    dynamodb_table = "jobtrackr-locks"
    encrypt        = true
  }
}
