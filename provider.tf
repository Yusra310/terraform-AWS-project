provider "aws" {
  region  = "us-east-1"  # Set your AWS region here
}


terraform {
  backend "s3" {
    bucket         = "statebackendbucket"   # Replace with your bucket name
    key            = "terraform-state-file/terraform.tfstate"    # Path to the state file in the bucket
    region         = "us-east-1"                    # AWS region where the S3 bucket is located
    dynamodb_table = "terraform-state-lock"
    encrypt = true
  }
}
